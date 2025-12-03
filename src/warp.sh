#!/bin/bash

source src/common.sh

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
        curl -fsSL "$wgcf_url" -o "$wgcf_tmp"
    else
        wget -qO "$wgcf_tmp" "$wgcf_url"
    fi
    
    chmod +x "$wgcf_tmp"
    mv "$wgcf_tmp" /usr/bin/wgcf
    chmod 755 /usr/bin/wgcf

    # Generate Config
    log_info "Generating Wireguard configuration..."
    mkdir -p /opt/warp-config
    cd /opt/warp-config || exit 1
    
    wgcf register --accept-tos >/dev/null 2>&1 || true
    wgcf generate

    # Apply Warp+
    if [[ "$USE_WARP_PLUS" == "y" || "$USE_WARP_PLUS" == "Y" ]]; then
        log_info "Applying Warp+ license..."
        sed -i "s/^license_key.*/license_key = \"$WARP_PLUS_KEY\"/" wgcf-account.toml
        wgcf update
        wgcf generate
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

    print_line
    echo -e "${GREEN}✅ Warp setup completed!${NC}"
}
