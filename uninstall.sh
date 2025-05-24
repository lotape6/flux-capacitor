#!/usr/bin/env bash
# uninstall.sh - Uninstalls flux-capacitor

set -e

# Flags
FORCE_REMOVE=false

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared utilities
source "${SCRIPT_DIR}/src/utils.sh"

# Find the config file
CONFIG_FILE="$(${SCRIPT_DIR}/src/find-config.sh)"

# Set SCRIPT_DIR before sourcing the config file
export SCRIPT_DIR

# Source the configuration
source "${CONFIG_FILE}"


# Parse command line arguments
while getopts ":qfr:h" opt; do
    case ${opt} in
        q)
            FLUX_VERBOSE_MODE=false
            ;;
        f)
            FORCE_REMOVE=true
            ;;
        r)
            FLUX_ROOT="${OPTARG}"
            # Update derived paths
            FLUX_LOGS_DIR="${FLUX_ROOT}/logs"
            FLUX_INSTALL_LOG="${FLUX_LOGS_DIR}/install_$(date +'%Y%m%d%H%M%S').log"
            FLUX_UNINSTALL_LOG="${FLUX_LOGS_DIR}/uninstall_$(date +'%Y%m%d%H%M%S').log"
            ;;
        h)
            show_help
            exit ${EXIT_SUCCESS}
            ;;
        \?)
            error "Invalid option: -${OPTARG}"
            show_help
            exit ${EXIT_INVALID_OPTION}
            ;;
        :)
            error "Option -${OPTARG} requires an argument"
            show_help
            exit ${EXIT_INVALID_OPTION}
            ;;
    esac
done

# Create logs directory if it doesn't exist
mkdir -p "${FLUX_LOGS_DIR}"

# Source the error code definitions
if [ -f "${CONFIG_DIR}/err.codes" ]; then
    source "${CONFIG_DIR}/err.codes"
else
    # If the file doesn't exist yet, source from script dir
    source "${SCRIPT_DIR}/config/err.codes"
fi

# Define wrapper functions specific to uninstall.sh
log() { log_impl "$1" "${FLUX_UNINSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }
warn() { warn_impl "$1" "${FLUX_UNINSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }
error() { error_impl "$1" "${FLUX_UNINSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }
banner() { banner_impl "$1" "${FLUX_UNINSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -q           Disable verbose output"
    echo "  -f           Force removal without prompts"
    echo "  -r <path>    Override default root directory (default: ${FLUX_ROOT})"
    echo "  -h           Show this help message"
    echo
}


# Remove flux root directory and all its contents
remove_flux_root() {
    if [ -d "${FLUX_ROOT}" ]; then
        banner "Flux Root Directory"
        
        keep_config="y"
        # Ask user about config files unless force mode is enabled
        if ! $FORCE_REMOVE; then
            echo -e "Do you want to ${GREEN}keep${RESET} the flux root directory at ${BOLD}${FLUX_ROOT}${RESET} just in case? 🤔🗃️"
            echo -e "If you choose to keep it, it will ${GREEN}remain in place${RESET} for future use."
            read -p "Keep flux root directory? (Y/n): " keep_config
        else
            keep_config="n" # In force mode, always delete
        fi

        if [[ ! "${keep_config}" =~ ^[Nn]$ ]]; then
            log "Flux root directory will be ${GREEN}preserved${RESET}."
        else
            log "Backing up and removing flux root directory..."
            
            # Create backup
            BACKUP_DIR="${HOME}/.flux_backup_$(date +'%Y-%m-%d_%H:%M:%S')"
            mkdir -p "${BACKUP_DIR}"
            cp -r "${FLUX_ROOT}"/* "${BACKUP_DIR}" 2>/dev/null || true
            
            # Save the log file before removing the directory
            if [ -f "${FLUX_UNINSTALL_LOG}" ]; then
                cp "${FLUX_UNINSTALL_LOG}" .
                FLUX_UNINSTALL_LOG="$(basename ${FLUX_UNINSTALL_LOG})"
            fi
            
            # Remove flux root
            rm -rf "${FLUX_ROOT}"
            
            log "Flux root has been ${GREEN}backed up${RESET} to ${BOLD}${BACKUP_DIR}${RESET} and ${RED}removed${RESET}."
            log "Logs can be found at ${BOLD}${FLUX_UNINSTALL_LOG}${RESET}."
        fi

    else
        log "No flux root directory found at ${BOLD}${FLUX_ROOT}${RESET}. Skipping..."
    fi
}

# Main uninstallation process
main() {
    banner "Flux Capacitor Uninstallation"
    
    log "Starting uninstallation process..."
    
    log "Removing shell initialization snippets..."
    if [ -f "${FLUX_ROOT}/src/flux-capacitor-init.sh" ]; then
        "${FLUX_ROOT}/src/flux-capacitor-init.sh" -u
        log "Shell initialization snippets removed ${GREEN}successfully${RESET}."
    else
        log "No shell initialization script found at ${FLUX_ROOT}/src/flux-capacitor-init.sh."
        warn "Do not forget to remove any manual entries in your shell config files!"
    fi

    # Only remove flux root if directory exists
    if [ -d "${FLUX_ROOT}" ]; then
      remove_flux_root
       banner "Uninstallation Complete"
       log "${GREEN}Flux Capacitor has been uninstalled successfully!${RESET}"
    else
      warn "Skipping removal of flux root directory; not found at ${FLUX_ROOT}."
    fi
}

# Confirm uninstallation if not in force mode
if ! $FORCE_REMOVE; then
    show_ascii_banner
    echo -e "${BOLD}${YELLOW}This will uninstall Flux Capacitor.${RESET}"
    echo -e "  • Flux root directory will be ${RED}completely removed${RESET}"
    read -p "Are you absolutely sure you want to disrupt the space-time continuum? (y/N): " confirm
    
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Your timeline will never be the same... proceeding anyway.${RESET}"
        main
    else
        echo -e "${GREEN}Phew! The universe is safe for now.${RESET}"
        exit ${EXIT_SUCCESS}
    fi
else
    # In force mode, run main without confirmation
    main
fi
