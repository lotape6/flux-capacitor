#!/usr/bin/env bash
# install.sh - Installs flux-capacitor

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

# Source the error code definitions
if [ -f "${CONFIG_DIR}/err_codes" ]; then
    source "${CONFIG_DIR}/err_codes"
else
    # If the file doesn't exist yet (first install), copy it first
    cp "${SCRIPT_DIR}/config/err_codes" "${CONFIG_DIR}/" 2>/dev/null || true
    source "${SCRIPT_DIR}/config/err_codes"
fi

# Define wrapper functions specific to install.sh
log() { log_impl "$1" "${INSTALL_LOG}" "${VERBOSE_MODE}"; }
warn() { warn_impl "$1" "${INSTALL_LOG}" "${VERBOSE_MODE}"; }
error() { error_impl "$1" "${INSTALL_LOG}"; }
banner() { banner_impl "$1" "${INSTALL_LOG}" "${VERBOSE_MODE}"; }

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -q           Disable VERBOSE_MODE output"
    echo "  -c <path>    Override default config directory (default: ${CONFIG_DIR})"
    echo "  -i <path>    Override default installation directory (default: ${INSTALLATION_DIR})"
    echo "  -h           Show this help message"
    echo
}



# Parse command line arguments
while getopts ":qfc:i:h" opt; do
    case ${opt} in
        q)
            VERBOSE_MODE=false
            ;;
        c)
            CONFIG_DIR="${OPTARG}"
            ;;
        i)
            INSTALLATION_DIR="${OPTARG}"
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

# Check for dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    # Check for additional dependencies
    for dep in git curl tmux fzf bat delta; do
        dep_path="$(whereis "$dep" | cut -d : -f 2- | tr -s ' ')"
        if [ -z "$dep_path" ]; then
            missing_deps+=("$dep")
        fi
    done
    if [ ${#missing_deps[@]} -gt 0 ] && $VERBOSE_MODE; then
        warn "Some optional dependencies are not installed: ${missing_deps[*]}"
        log "Installing missing dependencies..."
        
        # Use the install-dependency.sh script for each dependency
        for dep in "${missing_deps[@]}"; do
            "${SCRIPT_DIR}/install/install-dependency.sh" "$dep"
        done
    fi
    
    if $VERBOSE_MODE; then
        log "All dependencies are ${GREEN}installed${RESET}."
    fi
}

# Create necessary directories
create_dirs() {
    banner "Creating Directories"
    
    log "Creating configuration directory at ${BOLD}${CONFIG_DIR}${RESET}"
    mkdir -p "$CONFIG_DIR"
    
    log "Creating installation directory at ${BOLD}${INSTALLATION_DIR}${RESET}"
    mkdir -p "$INSTALLATION_DIR"
    
    log "Directories created ${GREEN}successfully${RESET}."
}

# Copy configuration files
copy_configs() {
    banner "Copying Configuration Files"
    log $CONFIG_DIR
    # Handle configuration files
    if [ -f "${CONFIG_DIR}/tmux.conf" ]; then
        warn "Existing configuration found. Skipping..."
    
    else
        log "Copying configuration files to ${BOLD}${CONFIG_DIR}${RESET}"
        cp "${SCRIPT_DIR}/config/"* "${CONFIG_DIR}/"
    fi
        
        # Copy installation files
        log "Copying installation files to ${BOLD}${INSTALLATION_DIR}${RESET}"
        cp -r "${SCRIPT_DIR}/install/"* "${INSTALLATION_DIR}/"
        
        log "Configuration and installation files copied ${GREEN}successfully${RESET}."
}

# Main installation process
main() {
    banner "Flux Capacitor Installation"
    show_ascii_banner
     
    log "Starting installation process..."
    
    check_dependencies
    create_dirs
    copy_configs
    
    # Run flux-capacitor-init.sh in install mode
    if [ -f "${SCRIPT_DIR}/install/flux-capacitor-init.sh" ]; then
        log "Adding shell initialization snippets..."
        "${SCRIPT_DIR}/install/flux-capacitor-init.sh" -i
        log "Shell initialization snippets added ${GREEN}successfully${RESET}."
    fi
    
    banner "Installation Complete"
    log "${GREEN}Flux Capacitor has been installed successfully!${RESET}"
    log "Configuration directory: ${BOLD}${CONFIG_DIR}${RESET}"
    log "Installation directory: ${BOLD}${INSTALLATION_DIR}${RESET}"
    log "You can now use Flux Capacitor. Enjoy!"
}

# Run the installation
main
