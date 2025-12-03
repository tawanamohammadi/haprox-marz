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
    echo -e "${GREEN}🌩️ Cloudflare Warp Auto Setup (Hardened)${NC}"
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

    # Install WGCF
    log_info "Downloading wgcf..."
    local wgcf_url="https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_${arch}"
    local wgcf_tmp="${TMPDIR}/wgcf"
    
    if command -v curl &>/dev/null; then
        if ! curl -fsSL "$wgcf_url" -o "$wgcf_tmp"; then
             log_error "Failed to download wgcf. Check internet connection."
             exit 1
        fi
    else
        if ! wget -qO "$wgcf_tmp" "$wgcf_url"; then
             log_error "Failed to download wgcf. Check internet connection."
             exit 1
        fi
    fi
    
    chmod +x "$wgcf_tmp"
    mv "$wgcf_tmp" /usr/bin/wgcf
    chmod 755 /usr/bin/wgcf

    # Generate Config
    log_info "Generating Wireguard configuration..."
    mkdir -p /opt/warp-config
    cd /opt/warp-config || exit 1
    
    # Register account (ignore error if already registered)
    wgcf register --accept-tos >/dev/null 2>&1 || true
    
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
        cat > /opt/marzban-warp/warp_xray_outbound.json <<-EOF
{
  "tag": "warp",
  "protocol": "wireguard",
  "settings": {
    "secretKey": "${EXTRACTED_PRIVATE_KEY}",
    "address": ["${ipv4}/32", "${ipv6}/128"],
    "peers": [
      {
        "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
        "endpoint": "engage.cloudflareclient.com:2408"
      }
    ],
    "reserved": [0, 0, 0],
    "mtu": 1280
  }
}
EOF
        cp /opt/marzban-warp/warp_xray_outbound.json /root/
        log_info "Xray outbound generated at /root/warp_xray_outbound.json"

    else
        # Kernel Method
        log_info "Setting up Wireguard Kernel..."
        mkdir -p /etc/wireguard
        cp wgcf-profile.conf /etc/wireguard/warp.conf
        # Fix Table=off
        if ! grep -q "Table" /etc/wireguard/warp.conf; then
             sed -i '/\[Interface\]/a Table = off' /etc/wireguard/warp.conf
        fi
        chmod 600 /etc/wireguard/warp.conf
        systemctl enable --now wg-quick@warp
        log_info "Wireguard service started."
    fi

    # Routing Rules
    log_info "Creating routing rules..."
    if [[ "$ROUTE_ALL_TRAFFIC" == "y" || "$ROUTE_ALL_TRAFFIC" == "Y" ]]; then
        echo '{"outboundTag": "warp", "type": "field"}' > /root/warp_routing_rule.json
    else
        # Default basic rules
         cat > /root/warp_routing_rule.json <<-EOF
{
    "outboundTag": "warp",
    "domain": ["geosite:google", "geosite:openai", "geosite:netflix"],
    "type": "field"
}
EOF
    fi
    log_info "Routing rules saved to /root/warp_routing_rule.json"

    mkdir -p /opt/marzban-warp
    cat > /opt/marzban-warp/marzban_snippets.json <<-EOF
{
  "outbounds": [
    $(cat /root/warp_xray_outbound.json)
  ],
  "routing": {
    "rules": [
      $(cat /root/warp_routing_rule.json)
    ]
  }
}
EOF
    cat > /opt/marzban-warp/POST_INSTALL.txt <<-EOF
Marzban Integration Guide

1) Open Marzban Panel → Core Settings
2) Add "warp" outbound from: /root/warp_xray_outbound.json
3) Add routing rule from: /root/warp_routing_rule.json
4) Save and restart core

Optional: Combined JSON snippet at /opt/marzban-warp/marzban_snippets.json
EOF

    echo
    echo -e "${GREEN}Next steps:${NC}"
    echo "- Open Marzban Core Settings and paste the generated outbound and routing rule"
    echo "- Combined snippet: /opt/marzban-warp/marzban_snippets.json"
    echo "- Detailed guide: /opt/marzban-warp/POST_INSTALL.txt"

    read -p "Auto attempt to integrate into a local config file path? (y/n): " AUTO_INTEGRATE
    if [[ "$AUTO_INTEGRATE" == "y" || "$AUTO_INTEGRATE" == "Y" ]]; then
        read -p "Enter Marzban core config path (e.g., /etc/marzban/core.json): " MARZBAN_CONFIG_PATH
        if [[ -n "$MARZBAN_CONFIG_PATH" && -f "$MARZBAN_CONFIG_PATH" ]]; then
            cp /opt/marzban-warp/marzban_snippets.json /opt/marzban-warp/marzban_snippets.backup.json || true
            echo "Backup of snippet saved at /opt/marzban-warp/marzban_snippets.backup.json"
            echo "Please manually merge outbounds and routing into $MARZBAN_CONFIG_PATH to avoid breaking existing config."
        else
            echo "Config path not found. Skipping auto integration."
        fi
    fi

    print_line
    echo -e "${GREEN}✅ Warp setup completed!${NC}"
}
