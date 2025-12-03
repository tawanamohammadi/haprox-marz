#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_line() {
    echo -e "${CYAN}=========================================${NC}"
}

# Banner
print_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔═════════════════════════════════════════════════╗"
    echo "║      Marzban & HAProxy Automation Suite         ║"
    echo "║           Secure. Fast. Reliable.               ║"
    echo "╚═════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# System checks
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        log_error "Cannot detect OS. Please run on Ubuntu/Debian."
        exit 1
    fi
}

install_packages() {
    local packages=("$@")
    log_info "Installing dependencies: ${packages[*]}"
    
    if command -v apt-get &> /dev/null; then
        apt-get update -y
        apt-get install -y "${packages[@]}"
    elif command -v yum &> /dev/null; then
        yum update -y
        yum install -y "${packages[@]}"
    else
        log_error "Unsupported package manager."
        exit 1
    fi
}
