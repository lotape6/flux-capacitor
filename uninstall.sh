#!/usr/bin/env bash
# uninstall.sh - Uninstalls flux-capacitor

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared utilities
source "${SCRIPT_DIR}/install/utils.sh"

# Find the config file
CONFIG_FILE="$(${SCRIPT_DIR}/install/find-config.sh)"

# Set SCRIPT_DIR before sourcing the config file
export SCRIPT_DIR

# Source the configuration
source "${CONFIG_FILE}"

# Create logs directory if it doesn't exist
mkdir -p "${LOGS_DIR}"

# Flags
FORCE_REMOVE=false

# Define wrapper functions specific to uninstall.sh
log() { log_impl "$1" "${UNINSTALL_LOG}"; }
warn() { warn_impl "$1" "${UNINSTALL_LOG}"; }
error() { error_impl "$1" "${UNINSTALL_LOG}"; }
banner() { banner_impl "$1" "${UNINSTALL_LOG}"; }

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -q           Disable verbose output"
    echo "  -f           Force removal without prompts"
    echo "  -c <path>    Override default config directory (default: ${CONFIG_DIR})"
    echo "  -i <path>    Override default installation directory (default: ${INSTALLATION_DIR})"
    echo "  -h           Show this help message"
    echo
}



# Parse command line arguments
while getopts ":qfc:i:h" opt; do
    case ${opt} in
        q)
            VERBOSE=false
            ;;
        f)
            FORCE_REMOVE=true
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



# Remove configuration files
remove_configs() {
    if [ -d "${CONFIG_DIR}" ]; then
        banner "Configuration Files"
        
        keep_config="y"
        # Ask user about config files unless force mode is enabled
        if ! $FORCE_REMOVE; then
            echo -e "Do you want to ${GREEN}keep${RESET} the configuration files at ${BOLD}${CONFIG_DIR}${RESET} just in case? 🤔🗃️"
            echo -e "If you choose to keep them, they will ${GREEN}remain in place${RESET} for future use."
            read -p "Keep configuration files? (Y/n): " keep_config
        else
            keep_config="n" # In force mode, always delete configs
        fi

        if [[ ! "${keep_config}" =~ ^[Nn]$ ]]; then
            log "Configuration files will be ${GREEN}preserved${RESET}."
        else
            log "Backing up and removing configuration files..."
            
            # Create backup
            BACKUP_DIR="${HOME}/.config/flux_backup_$(date +'%Y%m%d%H%M%S')"
            mkdir -p "${BACKUP_DIR}"
            cp -r "${CONFIG_DIR}"/* "${BACKUP_DIR}" 2>/dev/null || true
            
            # Remove configuration
            rm -rf "${CONFIG_DIR}"
            
            log "Configuration files have been ${GREEN}backed up${RESET} to ${BOLD}${BACKUP_DIR}${RESET} and ${RED}removed${RESET}."
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
    
    # Only remove installation if directory exists
    if [ -d "${INSTALLATION_DIR}" ]; then
      remove_installation
    else
      log "Skipping removal of installation directory; not found at ${INSTALLATION_DIR}."
    fi

    # Only remove configs if directory exists
    if [ -d "${CONFIG_DIR}" ]; then
      remove_configs
    else
      log "Skipping removal of configuration directory; not found at ${CONFIG_DIR}."
    fi
    
    banner "Uninstallation Complete"
    log "${GREEN}Flux Capacitor has been uninstalled successfully!${RESET}"
}

# Confirm uninstallation if not in force mode
if ! $FORCE_REMOVE; then
    show_ascii_banner
    echo -e "${BOLD}${YELLOW}This will uninstall Flux Capacitor.${RESET}"
    echo -e "  • Installation directory will be ${RED}completely removed${RESET}"
    read -p "Are you absolutely sure you want to disrupt the space-time continuum? (y/N): " confirm
    
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Your timeline will never be the same... proceeding anyway.${RESET}"
        main
    else
        echo -e "${GREEN}Phew! The universe is safe for now.${RESET}"
        exit 0
    fi
else
    # In force mode, run main without confirmation
    main
fi
