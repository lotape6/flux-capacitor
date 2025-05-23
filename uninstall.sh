#!/usr/bin/env bash
# Flux Capacitor Uninstallation Script

set -e

# Default directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/flux"
INSTALLATION_DIR="${HOME}/.local/share/flux"
LOGS_DIR="${SCRIPT_DIR}/.logs"
UNINSTALL_LOG="${LOGS_DIR}/uninstall_$(date +'%Y%m%d%H%M%S').log"

# Create logs directory if it doesn't exist
mkdir -p "${LOGS_DIR}"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# Verbose mode flag
VERBOSE=false

# Print standard log message
log() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} $1" >> "${UNINSTALL_LOG}"
    if $VERBOSE; then
        echo -e "${timestamp} $1"
    fi
}

# Print warning message (yellow)
warn() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${YELLOW}WARNING:${RESET} $1" >> "${UNINSTALL_LOG}"
    if $VERBOSE; then
        echo -e "${timestamp} ${YELLOW}WARNING:${RESET} $1"
    fi
}

# Print error message (red)
error() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${RED}ERROR:${RESET} $1" >> "${UNINSTALL_LOG}"
    # Always show errors, even without verbose flag
    echo -e "${timestamp} ${RED}ERROR:${RESET} $1"
}

# Print banner (highlighted important message)
banner() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${BOLD}${BLUE}$1${RESET}" >> "${UNINSTALL_LOG}"
    # Always show banners, even without verbose flag
    echo -e "\n${BLUE}${BOLD}===============================================${RESET}"
    echo -e "${BLUE}${BOLD} $1 ${RESET}"
    echo -e "${BLUE}${BOLD}===============================================${RESET}\n"
}

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -v           Enable verbose output"
    echo "  -c <path>    Override default config directory (default: ${CONFIG_DIR})"
    echo "  -i <path>    Override default installation directory (default: ${INSTALLATION_DIR})"
    echo "  -h           Show this help message"
    echo
}

# Parse command line arguments
while getopts ":vc:i:h" opt; do
    case ${opt} in
        v)
            VERBOSE=true
            ;;
        c)
            CONFIG_DIR="${OPTARG}"
            ;;
        i)
            INSTALLATION_DIR="${OPTARG}"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            error "Invalid option: -${OPTARG}"
            show_help
            exit 1
            ;;
        :)
            error "Option -${OPTARG} requires an argument"
            show_help
            exit 1
            ;;
    esac
done

# Check if directories exist
check_directories() {
    local missing=false
    
    if [ ! -d "${INSTALLATION_DIR}" ]; then
        warn "Installation directory not found at ${BOLD}${INSTALLATION_DIR}${RESET}"
        missing=true
    fi
    
    if [ ! -d "${CONFIG_DIR}" ]; then
        warn "Configuration directory not found at ${BOLD}${CONFIG_DIR}${RESET}"
        missing=true
    fi
    
    if $missing && [ "${CONFIG_DIR}" != "${HOME}/.config/flux" -o "${INSTALLATION_DIR}" != "${HOME}/.local/share/flux" ]; then
        warn "Using non-default directories. If you installed with custom paths, please use -c and -i options."
        echo -e "${YELLOW}${BOLD}You're using non-default directories:${RESET}"
        echo -e "  Config dir: ${BOLD}${CONFIG_DIR}${RESET}"
        echo -e "  Install dir: ${BOLD}${INSTALLATION_DIR}${RESET}"
        
        read -p "Continue with these directories? (y/N): " continue_custom
        if [[ ! "${continue_custom}" =~ ^[Yy]$ ]]; then
            log "Uninstallation cancelled."
            exit 0
        fi
    fi
}

# Remove configuration files
remove_configs() {
    if [ -d "${CONFIG_DIR}" ]; then
        banner "Configuration Files"
        
        # Ask user about config files
        echo -e "Do you want to ${YELLOW}delete${RESET} the configuration files at ${BOLD}${CONFIG_DIR}${RESET}?"
        echo -e "If you choose to keep them, they will ${GREEN}remain in place${RESET} for future use."
        read -p "Delete configuration files? (y/N): " delete_config
        
        if [[ "${delete_config}" =~ ^[Yy]$ ]]; then
            log "Backing up and removing configuration files..."
            
            # Create backup
            BACKUP_DIR="${HOME}/.config/flux_backup_$(date +'%Y%m%d%H%M%S')"
            mkdir -p "${BACKUP_DIR}"
            cp -r "${CONFIG_DIR}"/* "${BACKUP_DIR}" 2>/dev/null || true
            
            # Remove configuration
            rm -rf "${CONFIG_DIR}"
            
            log "Configuration files have been ${GREEN}backed up${RESET} to ${BOLD}${BACKUP_DIR}${RESET} and ${RED}removed${RESET}."
        else
            log "Configuration files will be ${GREEN}preserved${RESET}."
        fi
    else
        log "No configuration directory found at ${BOLD}${CONFIG_DIR}${RESET}. Skipping..."
    fi
}

# Remove installation files
remove_installation() {
    if [ -d "${INSTALLATION_DIR}" ]; then
        banner "Installation Directory"
        
        log "Removing installation files from ${BOLD}${INSTALLATION_DIR}${RESET}..."
        rm -rf "${INSTALLATION_DIR}"
        log "Installation files have been ${RED}removed${RESET}."
    else
        log "No installation directory found at ${BOLD}${INSTALLATION_DIR}${RESET}. Skipping..."
    fi
}

# Main uninstallation process
main() {
    banner "Flux Capacitor Uninstallation"
    
    log "Starting uninstallation process..."
    
    check_directories
    remove_installation
    remove_configs
    
    banner "Uninstallation Complete"
    log "${GREEN}Flux Capacitor has been uninstalled successfully!${RESET}"
    
    if [[ "${delete_config}" =~ ^[Yy]$ ]]; then
        log "Your configuration files have been backed up to: ${BOLD}${BACKUP_DIR}${RESET}"
    else
        log "Your configuration files remain at: ${BOLD}${CONFIG_DIR}${RESET}"
    fi
}

# Confirm uninstallation
echo -e "${BOLD}${YELLOW}This will uninstall Flux Capacitor.${RESET}"
echo -e "  • Installation directory will be ${RED}completely removed${RESET}"
echo -e "  • You will be asked about keeping or removing configuration files"
read -p "Continue with uninstallation? (y/N): " confirm

if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    main
else
    echo -e "${YELLOW}Uninstallation cancelled.${RESET}"
    exit 0
fi