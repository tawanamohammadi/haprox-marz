#!/bin/bash

source src/common.sh

install_haproxy_logic() {
    print_line
    echo -e "${GREEN}🚀 HAProxy TLS Router Auto Installer${NC}"
    print_line

    # Install HAProxy if missing
    if ! command -v haproxy >/dev/null 2>&1; then
        log_info "Installing HAProxy..."
        install_packages haproxy
    else
        log_info "HAProxy already installed"
    fi

    # User Inputs
    echo
    echo -e "${YELLOW}Please enter the domains for your services (SNI routing):${NC}"
    read -p "📥 Panel domain (e.g. panel.example.com): " DOMAIN_PANEL
    read -p "📥 VLESS+WS domain: " DOMAIN_WS
    read -p "📥 VMESS+TCP domain: " DOMAIN_TCP
    read -p "📥 XHTTP domain (e.g. for Trojan): " DOMAIN_XHTTP
    read -p "📥 Hysteria domain: " DOMAIN_HYSTERIA
    read -p "📥 Reality domain: " DOMAIN_REALITY
    
    echo
    echo -e "${YELLOW}Please enter local ports (press Enter for default):${NC}"
    read -p "📍 Local port for panel [8000]: " PORT_PANEL
    PORT_PANEL=${PORT_PANEL:-8000}
    read -p "📍 Port for VLESS+WS [1001]: " PORT_WS
    PORT_WS=${PORT_WS:-1001}
    read -p "📍 Port for VMESS+TCP [1002]: " PORT_TCP
    PORT_TCP=${PORT_TCP:-1002}
    read -p "📍 Port for XHTTP [1003]: " PORT_XHTTP
    PORT_XHTTP=${PORT_XHTTP:-1003}
    read -p "📍 Port for Hysteria [1004]: " PORT_HYSTERIA
    PORT_HYSTERIA=${PORT_HYSTERIA:-1004}
    read -p "📍 Port for Reality [1005]: " PORT_REALITY
    PORT_REALITY=${PORT_REALITY:-1005}
    
    print_line
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

    log_info "Restarting HAProxy service..."
    systemctl restart haproxy
    systemctl enable haproxy

    print_line
    echo -e "${GREEN}✅ HAProxy installation and configuration complete!${NC}"
    echo -e "${CYAN}➡️  Config file: /etc/haproxy/haproxy.cfg${NC}"
}
