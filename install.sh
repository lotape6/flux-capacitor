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
mkdir -p "${FLUX_LOGS_DIR}"

# Define wrapper functions specific to install.sh
log() { log_impl "$1" "${FLUX_INSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }
warn() { warn_impl "$1" "${FLUX_INSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }
error() { error_impl "$1" "${FLUX_INSTALL_LOG}"; }
banner() { banner_impl "$1" "${FLUX_INSTALL_LOG}" "${FLUX_VERBOSE_MODE}"; }

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -q           Disable verbose output"
    echo "  -c <path>    Override default config directory (default: ${FLUX_CONFIG_DIR})"
    echo "  -i <path>    Override default installation directory (default: ${FLUX_INSTALLATION_DIR})"
    echo "  -h           Show this help message"
    echo
}



# Parse command line arguments
while getopts ":qfc:i:h" opt; do
    case ${opt} in
        q)
            FLUX_VERBOSE_MODE=false
            ;;
        c)
            FLUX_CONFIG_DIR="${OPTARG}"
            ;;
        i)
            FLUX_INSTALLATION_DIR="${OPTARG}"
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
    
    log "Creating configuration directory at ${BOLD}${FLUX_CONFIG_DIR}${RESET}"
    mkdir -p "$FLUX_CONFIG_DIR"

    log "Creating installation directory at ${BOLD}${FLUX_INSTALLATION_DIR}${RESET}"
    mkdir -p "$FLUX_INSTALLATION_DIR"
    
    log "Directories created ${GREEN}successfully${RESET}."
}

# Copy configuration files
copy_configs() {
    banner "Copying Configuration Files"
    log $FLUX_CONFIG_DIR
    # Handle configuration files
    if [ -f "${FLUX_CONFIG_DIR}/tmux.conf" ]; then
        warn "Existing configuration found. Skipping..."
    
    else
        log "Copying configuration files to ${BOLD}${FLUX_CONFIG_DIR}${RESET}"
        cp "${SCRIPT_DIR}/config/"* "${FLUX_CONFIG_DIR}/"
    fi
        
        # Copy installation files
        log "Copying installation files to ${BOLD}${FLUX_INSTALLATION_DIR}${RESET}"
        cp -r "${SCRIPT_DIR}/install/"* "${FLUX_INSTALLATION_DIR}/"
        
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
    log "Configuration directory: ${BOLD}${FLUX_CONFIG_DIR}${RESET}"
    log "Installation directory: ${BOLD}${FLUX_INSTALLATION_DIR}${RESET}"
    log "You can now use Flux Capacitor. Enjoy!"
}

# Run the installation
main
