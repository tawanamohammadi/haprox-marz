#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Global variables
BACKUP_DIR="${BACKUP_DIR:-.backup}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logging functions with timestamps
log_info() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] [INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] [ERROR]${NC} $1"
}

log_success() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')] [SUCCESS]${NC} $1"
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
    echo -e "${MAGENTA}Version: 2.0.0 | Enhanced Edition${NC}"
    echo
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
        log_info "Detected OS: $OS"
    else
        log_error "Cannot detect OS. Please run on Ubuntu/Debian."
        exit 1
    fi
}

# Dependency checking
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warn "Missing dependencies: ${missing[*]}"
        return 1
    fi
    
    log_info "All dependencies satisfied: ${deps[*]}"
    return 0
}

install_packages() {
    local packages=("$@")
    log_info "Installing dependencies: ${packages[*]}"
    
    if command -v apt-get &> /dev/null; then
        apt-get update -y || { log_error "Failed to update package list"; return 1; }
        apt-get install -y "${packages[@]}" || { log_error "Failed to install packages"; return 1; }
    elif command -v yum &> /dev/null; then
        yum update -y || { log_error "Failed to update package list"; return 1; }
        yum install -y "${packages[@]}" || { log_error "Failed to install packages"; return 1; }
    else
        log_error "Unsupported package manager."
        return 1
    fi
    
    log_success "Dependencies installed successfully"
    return 0
}

# Backup and Restore functions
backup_file() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        log_warn "File does not exist, skipping backup: $file_path"
        return 0
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$PROJECT_ROOT/$BACKUP_DIR/$timestamp"
    
    mkdir -p "$backup_path" || { log_error "Failed to create backup directory"; return 1; }
    
    cp -p "$file_path" "$backup_path/" || { log_error "Failed to backup file: $file_path"; return 1; }
    
    log_success "Backed up: $file_path -> $backup_path/$(basename "$file_path")"
    echo "$timestamp" > "$PROJECT_ROOT/$BACKUP_DIR/latest"
    
    return 0
}

restore_backup() {
    local timestamp="$1"
    
    if [[ -z "$timestamp" ]]; then
        if [[ -f "$PROJECT_ROOT/$BACKUP_DIR/latest" ]]; then
            timestamp=$(cat "$PROJECT_ROOT/$BACKUP_DIR/latest")
            log_info "Using latest backup: $timestamp"
        else
            log_error "No backup timestamp provided and no latest backup found"
            return 1
        fi
    fi
    
    local backup_path="$PROJECT_ROOT/$BACKUP_DIR/$timestamp"
    
    if [[ ! -d "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        return 1
    fi
    
    log_info "Restoring from backup: $timestamp"
    
    for backup_file in "$backup_path"/*; do
        if [[ -f "$backup_file" ]]; then
            local filename=$(basename "$backup_file")
            local restore_path=""
            
            # Determine restore path based on filename
            case "$filename" in
                haproxy.cfg)
                    restore_path="/etc/haproxy/haproxy.cfg"
                    ;;
                warp.conf)
                    restore_path="/etc/wireguard/warp.conf"
                    ;;
                core.json)
                    restore_path="/var/lib/marzban/core.json"
                    ;;
                *)
                    log_warn "Unknown file in backup, skipping: $filename"
                    continue
                    ;;
            esac
            
            if [[ -n "$restore_path" ]]; then
                cp -p "$backup_file" "$restore_path" || { log_error "Failed to restore: $filename"; return 1; }
                log_success "Restored: $filename -> $restore_path"
            fi
        fi
    done
    
    log_success "Backup restoration complete"
    return 0
}

list_backups() {
    local backup_root="$PROJECT_ROOT/$BACKUP_DIR"
    
    if [[ ! -d "$backup_root" ]]; then
        log_info "No backups found"
        return 0
    fi
    
    echo -e "${CYAN}Available backups:${NC}"
    local count=0
    for backup_dir in "$backup_root"/*/; do
        if [[ -d "$backup_dir" ]]; then
            local timestamp=$(basename "$backup_dir")
            local file_count=$(find "$backup_dir" -type f | wc -l)
            echo "  - $timestamp ($file_count files)"
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        log_info "No backups found"
    fi
}

# Validation functions
validate_domain() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        log_error "Domain cannot be empty"
        return 1
    fi
    
    # Basic domain validation regex
    if [[ ! "$domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        log_error "Invalid domain format: $domain"
        return 1
    fi
    
    return 0
}

validate_port() {
    local port="$1"
    
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        log_error "Port must be a number: $port"
        return 1
    fi
    
    if [[ $port -lt 1 || $port -gt 65535 ]]; then
        log_error "Port must be between 1 and 65535: $port"
        return 1
    fi
    
    return 0
}

check_port_free() {
    local port="$1"
    
    if command -v ss &> /dev/null; then
        if ss -tuln | grep -q ":$port "; then
            log_error "Port $port is already in use"
            return 1
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$port "; then
            log_error "Port $port is already in use"
            return 1
        fi
    else
        log_warn "Cannot check port availability (ss/netstat not found)"
        return 0
    fi
    
    log_info "Port $port is available"
    return 0
}

# Utility functions
confirm_action() {
    local message="$1"
    local response
    
    read -p "$(echo -e ${YELLOW}$message [y/N]: ${NC})" response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    return 1
}

show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
