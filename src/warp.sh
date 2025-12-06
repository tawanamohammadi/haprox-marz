#!/bin/bash

source "$BASE_DIR/src/common.sh"

WGCF_VERSION="2.2.22"
TMPDIR=$(mktemp -d -t marz-warp-XXXXXXXX)

cleanup_tmp() {
    rm -rf "${TMPDIR}"
}
trap cleanup_tmp EXIT

install_warp_logic() {
    print_line
    echo -e "${GREEN}🌩️ Cloudflare Warp Auto Setup (Enhanced)${NC}"
    print_line

    # Detect Arch
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64) arch="amd64" ;; 
        aarch64) arch="arm64" ;; 
        *) log_error "Unsupported architecture: $arch"; exit 1 ;; 
    esac

    # Dependencies
    log_info "Checking and installing dependencies..."
    if command -v apt-get &> /dev/null; then
         install_packages wget curl jq wireguard wireguard-tools resolvconf lsb-release
    else
         install_packages wget curl jq wireguard-tools
    fi

    # User Input
    echo
    echo -e "${BLUE}Choose setup method:${NC}"
    echo "1) Xray core method (recommended)"
    echo "2) Wireguard kernel method"
    read -p "Enter your choice (1 or 2): " SETUP_METHOD

    read -p "Do you have a Warp+ license key? (y/n): " USE_WARP_PLUS
    if [[ "$USE_WARP_PLUS" == "y" || "$USE_WARP_PLUS" == "Y" ]]; then
        read -s -p "Enter your Warp+ license key: " WARP_PLUS_KEY
        echo
    fi

    read -p "Route ALL traffic through Warp? (y/n): " ROUTE_ALL_TRAFFIC

    # Install WGCF with retry
    log_info "Downloading wgcf..."
    local wgcf_url="https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_${arch}"
    local wgcf_tmp="${TMPDIR}/wgcf"
    local retry_count=0
    local max_retries=3
    
    while [ $retry_count -lt $max_retries ]; do
        if command -v curl &>/dev/null; then
            if curl -fsSL "$wgcf_url" -o "$wgcf_tmp"; then
                break
            fi
        else
            if wget -qO "$wgcf_tmp" "$wgcf_url"; then
                break
            fi
        fi
        
        ((retry_count++))
        if [ $retry_count -lt $max_retries ]; then
            log_warn "Download failed, retrying ($retry_count/$max_retries)..."
            sleep 2
        else
            log_error "Failed to download wgcf after $max_retries attempts"
            exit 1
        fi
    done
    
    chmod +x "$wgcf_tmp"
    mv "$wgcf_tmp" /usr/bin/wgcf
    chmod 755 /usr/bin/wgcf
    log_success "wgcf installed successfully"

    # Generate Config
    log_info "Generating Wireguard configuration..."
    mkdir -p /opt/warp-config
    cd /opt/warp-config || exit 1
    
    # Register account (ignore error if already registered)
    wgcf register --accept-tos > /dev/null 2>&1 || true
    
    if ! wgcf generate; then
        log_error "Failed to generate wgcf profile. 429 Too Many Requests? Try again later."
        exit 1
    fi

    # Apply Warp+
    if [[ "$USE_WARP_PLUS" == "y" || "$USE_WARP_PLUS" == "Y" ]]; then
        log_info "Applying Warp+ license..."
        if [[ -f wgcf-account.toml ]]; then
            sed -i "s/^license_key.*/license_key = \"$WARP_PLUS_KEY\"/" wgcf-account.toml
            if ! wgcf update; then
                 log_warn "Failed to update Warp+ license. Continuing with free account..."
            else
                 wgcf generate
                 log_success "Warp+ license applied"
            fi
        fi
    fi

    chmod 600 wgcf-profile.conf

    # Process Output based on method
    EXTRACTED_PRIVATE_KEY=$(grep -E "^PrivateKey" wgcf-profile.conf | cut -d'=' -f2- | xargs)
    EXTRACTED_ADDRESSES=$(grep -E "^Address" wgcf-profile.conf | cut -d'=' -f2- | xargs | tr ' ' ',')
    
    if [[ "$SETUP_METHOD" == "1" ]]; then
        # Xray Method
        local ipv4=$(echo "$EXTRACTED_ADDRESSES" | cut -d',' -f1 | cut -d'/' -f1)
        local ipv6=$(echo "$EXTRACTED_ADDRESSES" | cut -d',' -f2 | cut -d'/' -f1)
        
        mkdir -p /opt/marzban-warp
        
        # Generate JSON using jq for safety
        log_info "Generating Warp outbound JSON..."
        jq -n \
            --arg key "$EXTRACTED_PRIVATE_KEY" \
            --arg ipv4 "$ipv4" \
            --arg ipv6 "$ipv6" \
            '{
                tag: "warp",
                protocol: "wireguard",
                settings: {
                    secretKey: $key,
                    address: [($ipv4 + "/32"), ($ipv6 + "/128")],
                    peers: [{
                        publicKey: "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        endpoint: "engage.cloudflareclient.com:2408"
                    }],
                    reserved: [0, 0, 0],
                    mtu: 1280
                }
            }' > /opt/marzban-warp/warp_xray_outbound.json
        
        cp /opt/marzban-warp/warp_xray_outbound.json /root/
        log_success "Xray outbound generated at /root/warp_xray_outbound.json"

    else
        # Kernel Method
        log_info "Setting up Wireguard Kernel..."
        mkdir -p /etc/wireguard
        
        # Backup existing warp.conf if it exists
        if [[ -f /etc/wireguard/warp.conf ]]; then
            backup_file /etc/wireguard/warp.conf
        fi
        
        cp wgcf-profile.conf /etc/wireguard/warp.conf
        # Fix Table=off
        if ! grep -q "Table" /etc/wireguard/warp.conf; then
             sed -i '/\[Interface\]/a Table = off' /etc/wireguard/warp.conf
        fi
        chmod 600 /etc/wireguard/warp.conf
        systemctl enable --now wg-quick@warp
        log_success "Wireguard service started"
    fi

    # Routing Rules
    log_info "Creating routing rules..."
    if [[ "$ROUTE_ALL_TRAFFIC" == "y" || "$ROUTE_ALL_TRAFFIC" == "Y" ]]; then
        jq -n '{outboundTag: "warp", type: "field"}' > /root/warp_routing_rule.json
    else
        # Default basic rules
        jq -n '{
            outboundTag: "warp",
            domain: ["geosite:google", "geosite:openai", "geosite:netflix"],
            type: "field"
        }' > /root/warp_routing_rule.json
    fi
    log_success "Routing rules saved to /root/warp_routing_rule.json"

    # Safe Marzban Integration
    echo
    if confirm_action "Do you want to automatically integrate Warp into Marzban config?"; then
        read -p "Enter Marzban core config path [/var/lib/marzban/core.json]: " MARZBAN_CONFIG_PATH
        MARZBAN_CONFIG_PATH=${MARZBAN_CONFIG_PATH:-/var/lib/marzban/core.json}
        
        if [[ -f "$MARZBAN_CONFIG_PATH" ]]; then
            log_info "Backing up Marzban config..."
            backup_file "$MARZBAN_CONFIG_PATH"
            
            log_info "Integrating Warp into Marzban config..."
            
            # Read the outbound and routing rule
            local warp_outbound=$(cat /root/warp_xray_outbound.json)
            local warp_routing=$(cat /root/warp_routing_rule.json)
            
            # Check if warp outbound already exists
            if jq -e '.outbounds[] | select(.tag == "warp")' "$MARZBAN_CONFIG_PATH" > /dev/null 2>&1; then
                log_warn "Warp outbound already exists in config, skipping outbound addition"
            else
                # Add warp outbound
                jq --argjson outbound "$warp_outbound" '.outbounds += [$outbound]' "$MARZBAN_CONFIG_PATH" > "${MARZBAN_CONFIG_PATH}.tmp"
                mv "${MARZBAN_CONFIG_PATH}.tmp" "$MARZBAN_CONFIG_PATH"
                log_success "Added Warp outbound to config"
            fi
            
            # Add routing rule
            if jq -e '.routing.rules[] | select(.outboundTag == "warp")' "$MARZBAN_CONFIG_PATH" > /dev/null 2>&1; then
                log_warn "Warp routing rule already exists, skipping"
            else
                jq --argjson rule "$warp_routing" '.routing.rules += [$rule]' "$MARZBAN_CONFIG_PATH" > "${MARZBAN_CONFIG_PATH}.tmp"
                mv "${MARZBAN_CONFIG_PATH}.tmp" "$MARZBAN_CONFIG_PATH"
                log_success "Added Warp routing rule to config"
            fi
            
            # Validate JSON
            if jq empty "$MARZBAN_CONFIG_PATH" 2>/dev/null; then
                log_success "Marzban config is valid JSON"
                echo
                echo -e "${GREEN}✅ Warp successfully integrated into Marzban!${NC}"
                echo -e "${YELLOW}⚠️  Please restart Marzban for changes to take effect:${NC}"
                echo -e "${CYAN}   marzban restart${NC}"
            else
                log_error "Generated config is invalid JSON! Restoring backup..."
                restore_backup
                return 1
            fi
        else
            log_error "Marzban config not found at: $MARZBAN_CONFIG_PATH"
            log_info "You can manually integrate using the files in /root/"
        fi
    else
        log_info "Skipping automatic integration"
    fi

    # Generate combined snippet for reference
    mkdir -p /opt/marzban-warp
    if [[ -f /root/warp_xray_outbound.json ]]; then
        jq -n \
            --argjson outbound "$(cat /root/warp_xray_outbound.json)" \
            --argjson rule "$(cat /root/warp_routing_rule.json)" \
            '{
                outbounds: [$outbound],
                routing: {
                    rules: [$rule]
                }
            }' > /opt/marzban-warp/marzban_snippets.json
    fi
    
    cat > /opt/marzban-warp/POST_INSTALL.txt <<-EOF
Marzban Integration Guide

✅ Automatic integration completed!

If you need to manually integrate:
1) Open Marzban Panel → Core Settings
2) Add "warp" outbound from: /root/warp_xray_outbound.json
3) Add routing rule from: /root/warp_routing_rule.json
4) Save and restart core

Optional: Combined JSON snippet at /opt/marzban-warp/marzban_snippets.json
EOF

    print_line
    echo -e "${GREEN}✅ Warp setup completed!${NC}"
    echo
    echo -e "${CYAN}📁 Generated files:${NC}"
    echo "  - /root/warp_xray_outbound.json"
    echo "  - /root/warp_routing_rule.json"
    echo "  - /opt/marzban-warp/marzban_snippets.json"
    echo "  - /opt/marzban-warp/POST_INSTALL.txt"
}
