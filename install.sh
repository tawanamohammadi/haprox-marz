#!/bin/bash

# Set execute permissions for internal scripts if not already set
chmod +x src/*.sh 2>/dev/null

# Source common functions
if [[ -f "src/common.sh" ]]; then
    source src/common.sh
else
    echo "Error: src/common.sh not found. Please run this script from the repository root."
    exit 1
fi

# Source modules
source src/haproxy.sh
source src/warp.sh

# Main Menu
show_menu() {
    print_banner
    echo -e "${YELLOW}Please select an option:${NC}"
    echo "1) 🛡️  Install HAProxy Router (SNI)"
    echo "2) 🌩️  Install Cloudflare Warp (Marzban)"
    echo "3) 🚀  Install BOTH (Full Setup)"
    echo "0) ❌  Exit"
    echo
    read -p "Enter your choice: " CHOICE
}

main() {
    check_root
    detect_os

    while true; do
        show_menu
        case $CHOICE in
            1)
                install_haproxy_logic
                read -p "Press Enter to continue..."
                ;;
            2)
                install_warp_logic
                read -p "Press Enter to continue..."
                ;;
            3)
                install_haproxy_logic
                echo
                install_warp_logic
                read -p "Press Enter to continue..."
                ;;
            0)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
