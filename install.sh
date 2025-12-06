#!/bin/bash

# Set BASE_DIR for sourcing
export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
source src/diagnostics.sh
source src/uninstall.sh

# Help message
show_help() {
    cat << EOF
HAProxy & Marzban Automation Suite - Enhanced Edition v2.0.0

Usage: sudo ./install.sh [OPTIONS]

OPTIONS:
    --help              Show this help message
    --haproxy           Install HAProxy only
    --warp              Install Warp only
    --both              Install both HAProxy and Warp
    --diagnostics       Run system diagnostics
    --rollback [TIME]   Restore from backup (optional: specify timestamp)
    --list-backups      List available backups
    --uninstall         Uninstall all components
    
EXAMPLES:
    sudo ./install.sh                    # Interactive menu
    sudo ./install.sh --haproxy          # Install HAProxy only
    sudo ./install.sh --both             # Install both components
    sudo ./install.sh --diagnostics      # Run diagnostics
    sudo ./install.sh --rollback         # Restore latest backup
    sudo ./install.sh --rollback 20250106_120000  # Restore specific backup

For more information, visit: https://github.com/tawanamohammadi/haprox-marz
EOF
}

# Main Menu
show_menu() {
    print_banner
    echo -e "${YELLOW}Please select an option:${NC}"
    echo "1) 🛡️  Install HAProxy Router (SNI)"
    echo "2) 🌩️  Install Cloudflare Warp (Marzban)"
    echo "3) 🚀  Install BOTH (Full Setup)"
    echo "4) 🔍  Run Diagnostics"
    echo "5) 💾  List Backups"
    echo "6) ⏮️  Rollback (Restore Backup)"
    echo "7) 🗑️  Uninstall"
    echo "0) ❌  Exit"
    echo
    read -p "Enter your choice: " CHOICE
}

main() {
    check_root
    detect_os

    # Parse CLI arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --haproxy)
                print_banner
                install_haproxy_logic
                exit $?
                ;;
            --warp)
                print_banner
                install_warp_logic
                exit $?
                ;;
            --both)
                print_banner
                install_haproxy_logic
                echo
                install_warp_logic
                exit $?
                ;;
            --diagnostics)
                run_diagnostics
                exit $?
                ;;
            --rollback)
                print_banner
                if [[ -n "$2" ]]; then
                    restore_backup "$2"
                else
                    restore_backup
                fi
                exit $?
                ;;
            --list-backups)
                print_banner
                list_backups
                exit $?
                ;;
            --uninstall)
                uninstall_all
                exit $?
                ;;
            *)
                echo -e "${RED}Error: Unknown option '$1'${NC}"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    fi

    # Interactive menu mode
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
            4)
                run_diagnostics
                read -p "Press Enter to continue..."
                ;;
            5)
                clear
                print_banner
                list_backups
                echo
                read -p "Press Enter to continue..."
                ;;
            6)
                clear
                print_banner
                list_backups
                echo
                read -p "Enter backup timestamp (or press Enter for latest): " BACKUP_TIME
                restore_backup "$BACKUP_TIME"
                read -p "Press Enter to continue..."
                ;;
            7)
                uninstall_all
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
