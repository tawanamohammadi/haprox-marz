#!/bin/bash

source src/common.sh

install_haproxy_logic() {
    print_line
    echo -e "${GREEN}🚀 HAProxy TLS Router Auto Installer${NC}"
    print_line

    # Check dependencies
    if ! check_dependencies curl; then
        install_packages curl
    fi

    # Install HAProxy if missing
    if ! command -v haproxy > /dev/null 2>&1; then
        log_info "Installing HAProxy..."
        install_packages haproxy
    else
        log_info "HAProxy already installed ($(haproxy -v | head -n1))"
    fi

    # Check if port 443 is free
    echo
    log_info "Checking port 443 availability..."
    if ! check_port_free 443; then
        log_error "Port 443 is in use. Please free it before continuing."
        if confirm_action "Do you want to see what's using port 443?"; then
            ss -tulnp | grep :443 || netstat -tulnp | grep :443
        fi
        return 1
    fi

    # User Inputs with validation
    echo
    echo -e "${YELLOW}Please enter the domains for your services (SNI routing):${NC}"
    
    while true; do
        read -p "📥 Panel domain (e.g. panel.example.com): " DOMAIN_PANEL
        validate_domain "$DOMAIN_PANEL" && break
    done
    
    while true; do
        read -p "📥 VLESS+WS domain: " DOMAIN_WS
        validate_domain "$DOMAIN_WS" && break
    done
    
    while true; do
        read -p "📥 VMESS+TCP domain: " DOMAIN_TCP
        validate_domain "$DOMAIN_TCP" && break
    done
    
    while true; do
        read -p "📥 XHTTP domain (e.g. for Trojan): " DOMAIN_XHTTP
        validate_domain "$DOMAIN_XHTTP" && break
    done
    
    while true; do
        read -p "📥 Hysteria domain: " DOMAIN_HYSTERIA
        validate_domain "$DOMAIN_HYSTERIA" && break
    done
    
    while true; do
        read -p "📥 Reality domain: " DOMAIN_REALITY
        validate_domain "$DOMAIN_REALITY" && break
    done
    
    echo
    echo -e "${YELLOW}Please enter local ports (press Enter for default):${NC}"
    
    while true; do
        read -p "📍 Local port for panel [8000]: " PORT_PANEL
        PORT_PANEL=${PORT_PANEL:-8000}
        validate_port "$PORT_PANEL" && break
    done
    
    while true; do
        read -p "📍 Port for VLESS+WS [1001]: " PORT_WS
        PORT_WS=${PORT_WS:-1001}
        validate_port "$PORT_WS" && break
    done
    
    while true; do
        read -p "📍 Port for VMESS+TCP [1002]: " PORT_TCP
        PORT_TCP=${PORT_TCP:-1002}
        validate_port "$PORT_TCP" && break
    done
    
    while true; do
        read -p "📍 Port for XHTTP [1003]: " PORT_XHTTP
        PORT_XHTTP=${PORT_XHTTP:-1003}
        validate_port "$PORT_XHTTP" && break
    done
    
    while true; do
        read -p "📍 Port for Hysteria [1004]: " PORT_HYSTERIA
        PORT_HYSTERIA=${PORT_HYSTERIA:-1004}
        validate_port "$PORT_HYSTERIA" && break
    done
    
    while true; do
        read -p "📍 Port for Reality [1005]: " PORT_REALITY
        PORT_REALITY=${PORT_REALITY:-1005}
        validate_port "$PORT_REALITY" && break
    done
    
    print_line
    
    # Backup existing config
    if [[ -f /etc/haproxy/haproxy.cfg ]]; then
        log_info "Backing up existing HAProxy configuration..."
        backup_file /etc/haproxy/haproxy.cfg
    fi
    
    log_info "Generating HAProxy config at /etc/haproxy/haproxy.cfg..."

    cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    daemon
    maxconn 2048
    tune.ssl.default-dh-param 2048

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 10s
    timeout client  1m
    timeout server  1m

frontend fe_tls
    bind *:443
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }

    use_backend be_panel    if { req.ssl_sni -i ${DOMAIN_PANEL} }
    use_backend be_ws       if { req.ssl_sni -i ${DOMAIN_WS} }
    use_backend be_tcp      if { req.ssl_sni -i ${DOMAIN_TCP} }
    use_backend be_xhttp    if { req.ssl_sni -i ${DOMAIN_XHTTP} }
    use_backend be_hysteria if { req.ssl_sni -i ${DOMAIN_HYSTERIA} }
    use_backend be_reality  if { req.ssl_sni -i ${DOMAIN_REALITY} }

    default_backend be_panel

backend be_panel
    mode tcp
    server panel 127.0.0.1:${PORT_PANEL} check

backend be_ws
    mode tcp
    server ws 127.0.0.1:${PORT_WS} check

backend be_tcp
    mode tcp
    server tcp 127.0.0.1:${PORT_TCP} check

backend be_xhttp
    mode tcp
    server xhttp 127.0.0.1:${PORT_XHTTP} check

backend be_hysteria
    mode tcp
    server hysteria 127.0.0.1:${PORT_HYSTERIA} check

backend be_reality
    mode tcp
    server reality 127.0.0.1:${PORT_REALITY} check
EOF

    # Validate config
    if haproxy -c -f /etc/haproxy/haproxy.cfg > /dev/null 2>&1; then
        log_success "HAProxy configuration is valid"
    else
        log_error "HAProxy configuration validation failed!"
        haproxy -c -f /etc/haproxy/haproxy.cfg
        return 1
    fi

    log_info "Restarting HAProxy service..."
    systemctl restart haproxy
    
    if systemctl is-active --quiet haproxy; then
        systemctl enable haproxy > /dev/null 2>&1
        log_success "HAProxy is running and enabled"
    else
        log_error "HAProxy failed to start"
        systemctl status haproxy
        return 1
    fi

    print_line
    echo -e "${GREEN}✅ HAProxy installation and configuration complete!${NC}"
    echo -e "${CYAN}➡️  Config file: /etc/haproxy/haproxy.cfg${NC}"
    echo -e "${CYAN}➡️  Status: systemctl status haproxy${NC}"
    echo
    echo -e "${YELLOW}📋 Configuration Summary:${NC}"
    echo "  Panel:    ${DOMAIN_PANEL} -> 127.0.0.1:${PORT_PANEL}"
    echo "  VLESS+WS: ${DOMAIN_WS} -> 127.0.0.1:${PORT_WS}"
    echo "  VMESS+TCP: ${DOMAIN_TCP} -> 127.0.0.1:${PORT_TCP}"
    echo "  XHTTP:    ${DOMAIN_XHTTP} -> 127.0.0.1:${PORT_XHTTP}"
    echo "  Hysteria: ${DOMAIN_HYSTERIA} -> 127.0.0.1:${PORT_HYSTERIA}"
    echo "  Reality:  ${DOMAIN_REALITY} -> 127.0.0.1:${PORT_REALITY}"
}
