#!/bin/bash

source src/common.sh

run_diagnostics() {
    print_banner
    print_line
    echo -e "${CYAN}🔍 System Diagnostics${NC}"
    print_line
    echo

    # System Info
    echo -e "${YELLOW}📊 System Information:${NC}"
    echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo

    # Port Checks
    echo -e "${YELLOW}🔌 Port Status:${NC}"
    local ports=(443 8000 1001 1002 1003 1004 1005)
    for port in "${ports[@]}"; do
        if ss -tuln 2>/dev/null | grep -q ":$port " || netstat -tuln 2>/dev/null | grep -q ":$port "; then
            echo -e "  Port $port: ${RED}IN USE${NC}"
            if command -v ss &>/dev/null; then
                ss -tulnp | grep ":$port " | head -n1
            fi
        else
            echo -e "  Port $port: ${GREEN}FREE${NC}"
        fi
    done
    echo

    # Service Status
    echo -e "${YELLOW}⚙️  Service Status:${NC}"
    
    # HAProxy
    if systemctl is-active --quiet haproxy 2>/dev/null; then
        echo -e "  HAProxy: ${GREEN}RUNNING${NC}"
        if [[ -f /etc/haproxy/haproxy.cfg ]]; then
            echo "    Config: /etc/haproxy/haproxy.cfg"
            if haproxy -c -f /etc/haproxy/haproxy.cfg &>/dev/null; then
                echo -e "    Validation: ${GREEN}VALID${NC}"
            else
                echo -e "    Validation: ${RED}INVALID${NC}"
            fi
        fi
    else
        echo -e "  HAProxy: ${RED}NOT RUNNING${NC}"
    fi
    
    # Wireguard
    if systemctl is-active --quiet wg-quick@warp 2>/dev/null; then
        echo -e "  Wireguard (warp): ${GREEN}RUNNING${NC}"
        if [[ -f /etc/wireguard/warp.conf ]]; then
            echo "    Config: /etc/wireguard/warp.conf"
        fi
    else
        echo -e "  Wireguard (warp): ${RED}NOT RUNNING${NC}"
    fi
    
    # Marzban (if exists)
    if systemctl list-units --full -all | grep -q marzban; then
        if systemctl is-active --quiet marzban 2>/dev/null; then
            echo -e "  Marzban: ${GREEN}RUNNING${NC}"
        else
            echo -e "  Marzban: ${RED}NOT RUNNING${NC}"
        fi
    fi
    echo

    # Configuration Files
    echo -e "${YELLOW}📄 Configuration Files:${NC}"
    local configs=(
        "/etc/haproxy/haproxy.cfg"
        "/etc/wireguard/warp.conf"
        "/var/lib/marzban/core.json"
        "/root/warp_xray_outbound.json"
        "/root/warp_routing_rule.json"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            local size=$(du -h "$config" | cut -f1)
            echo -e "  ${GREEN}✓${NC} $config ($size)"
        else
            echo -e "  ${RED}✗${NC} $config (not found)"
        fi
    done
    echo

    # Warp Connectivity Test
    if [[ -f /root/warp_xray_outbound.json ]] || systemctl is-active --quiet wg-quick@warp 2>/dev/null; then
        echo -e "${YELLOW}🌐 Warp Connectivity Test:${NC}"
        
        if command -v curl &>/dev/null; then
            echo -n "  Testing connection... "
            
            # Test with kernel method
            if systemctl is-active --quiet wg-quick@warp 2>/dev/null; then
                if timeout 5 curl -s --interface warp https://cloudflare.com/cdn-cgi/trace | grep -q "warp=on"; then
                    echo -e "${GREEN}SUCCESS${NC}"
                    echo "  Warp is working correctly!"
                else
                    echo -e "${YELLOW}PARTIAL${NC}"
                    echo "  Warp interface exists but may not be routing correctly"
                fi
            else
                echo -e "${YELLOW}SKIPPED${NC}"
                echo "  (Xray method detected, test via Marzban panel)"
            fi
        else
            echo "  curl not available, skipping connectivity test"
        fi
        echo
    fi

    # Backups
    echo -e "${YELLOW}💾 Backups:${NC}"
    if [[ -d "$PROJECT_ROOT/.backup" ]]; then
        local backup_count=$(find "$PROJECT_ROOT/.backup" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        echo "  Total backups: $backup_count"
        if [[ $backup_count -gt 0 ]]; then
            echo "  Latest backup: $(cat "$PROJECT_ROOT/.backup/latest" 2>/dev/null || echo "unknown")"
        fi
    else
        echo "  No backups found"
    fi
    echo

    # Dependencies
    echo -e "${YELLOW}📦 Dependencies:${NC}"
    local deps=(curl wget jq haproxy wgcf ss netstat)
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep (not installed)"
        fi
    done
    echo

    print_line
    echo -e "${GREEN}Diagnostics complete!${NC}"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_root
    run_diagnostics
fi
