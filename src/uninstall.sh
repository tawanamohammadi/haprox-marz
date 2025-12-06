#!/bin/bash

source src/common.sh

uninstall_all() {
    print_banner
    print_line
    echo -e "${RED}⚠️  UNINSTALLER${NC}"
    print_line
    echo
    echo -e "${YELLOW}This will remove:${NC}"
    echo "  - HAProxy and its configuration"
    echo "  - Wireguard Warp and its configuration"
    echo "  - Generated Warp files"
    echo "  - wgcf binary"
    echo
    echo -e "${RED}WARNING: This action cannot be undone!${NC}"
    echo -e "${YELLOW}Backups will be preserved in .backup/ directory${NC}"
    echo

    if ! confirm_action "Are you sure you want to uninstall everything?"; then
        log_info "Uninstall cancelled"
        return 0
    fi

    echo
    log_info "Starting uninstallation process..."
    echo

    # Backup before removal
    log_info "Creating final backup..."
    [[ -f /etc/haproxy/haproxy.cfg ]] && backup_file /etc/haproxy/haproxy.cfg
    [[ -f /etc/wireguard/warp.conf ]] && backup_file /etc/wireguard/warp.conf
    [[ -f /var/lib/marzban/core.json ]] && backup_file /var/lib/marzban/core.json

    # Stop services
    log_info "Stopping services..."
    
    if systemctl is-active --quiet haproxy 2>/dev/null; then
        systemctl stop haproxy
        systemctl disable haproxy
        log_success "HAProxy stopped and disabled"
    fi
    
    if systemctl is-active --quiet wg-quick@warp 2>/dev/null; then
        systemctl stop wg-quick@warp
        systemctl disable wg-quick@warp
        log_success "Wireguard Warp stopped and disabled"
    fi

    # Remove HAProxy
    log_info "Removing HAProxy..."
    if command -v apt-get &>/dev/null; then
        apt-get remove -y haproxy 2>/dev/null
        apt-get autoremove -y 2>/dev/null
    elif command -v yum &>/dev/null; then
        yum remove -y haproxy 2>/dev/null
    fi
    
    rm -f /etc/haproxy/haproxy.cfg
    log_success "HAProxy removed"

    # Remove Wireguard config
    log_info "Removing Wireguard configuration..."
    rm -f /etc/wireguard/warp.conf
    log_success "Wireguard config removed"

    # Remove wgcf
    log_info "Removing wgcf..."
    rm -f /usr/bin/wgcf
    rm -rf /opt/warp-config
    log_success "wgcf removed"

    # Remove generated files
    log_info "Removing generated files..."
    rm -f /root/warp_xray_outbound.json
    rm -f /root/warp_routing_rule.json
    rm -rf /opt/marzban-warp
    log_success "Generated files removed"

    # Ask about Marzban config cleanup
    echo
    if [[ -f /var/lib/marzban/core.json ]]; then
        if confirm_action "Do you want to remove Warp from Marzban config?"; then
            log_info "Backing up and cleaning Marzban config..."
            backup_file /var/lib/marzban/core.json
            
            # Remove warp outbound
            jq 'del(.outbounds[] | select(.tag == "warp"))' /var/lib/marzban/core.json > /var/lib/marzban/core.json.tmp
            mv /var/lib/marzban/core.json.tmp /var/lib/marzban/core.json
            
            # Remove warp routing rules
            jq 'del(.routing.rules[] | select(.outboundTag == "warp"))' /var/lib/marzban/core.json > /var/lib/marzban/core.json.tmp
            mv /var/lib/marzban/core.json.tmp /var/lib/marzban/core.json
            
            if jq empty /var/lib/marzban/core.json 2>/dev/null; then
                log_success "Warp removed from Marzban config"
                echo -e "${YELLOW}⚠️  Please restart Marzban for changes to take effect${NC}"
            else
                log_error "Failed to clean Marzban config, restoring backup..."
                restore_backup
            fi
        fi
    fi

    echo
    print_line
    echo -e "${GREEN}✅ Uninstallation complete!${NC}"
    echo
    echo -e "${CYAN}Backups are preserved in: $PROJECT_ROOT/.backup/${NC}"
    echo -e "${CYAN}To restore, run: ./install.sh --rollback${NC}"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_root
    uninstall_all
fi
