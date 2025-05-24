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

# Define wrapper functions specific to install.sh
log() { log_impl "$1" "${INSTALL_LOG}"; }
warn() { warn_impl "$1" "${INSTALL_LOG}"; }
error() { error_impl "$1" "${INSTALL_LOG}"; }
banner() { banner_impl "$1" "${INSTALL_LOG}"; }

# Display help message
show_help() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -q           Disable verbose output"
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

# Check for dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v git &> /dev/null; then
        error "git is not installed. Please install git and try again."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        error "curl is not installed. Please install curl and try again."
        exit 1
    fi
    
    # Check for additional dependencies
    local missing_deps=()
    
    for dep in tmux fzf bat delta; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ] && $VERBOSE; then
        warn "Some optional dependencies are not installed: ${missing_deps[*]}"
        log "Installing missing dependencies..."
        
        # Use the install-dependency.sh script for each dependency
        for dep in "${missing_deps[@]}"; do
            "${SCRIPT_DIR}/install/install-dependency.sh" "$dep"
        done
    fi
    
    if $VERBOSE; then
        log "All dependencies are ${GREEN}installed${RESET}."
    fi
}

# Create necessary directories
create_dirs() {
    banner "Creating Directories"
    
    log "Creating configuration directory at ${BOLD}${CONFIG_DIR}${RESET}"
    mkdir -p "${CONFIG_DIR}"
    
    log "Creating installation directory at ${BOLD}${INSTALLATION_DIR}${RESET}"
    mkdir -p "${INSTALLATION_DIR}"
    
    log "Directories created ${GREEN}successfully${RESET}."
}

# Copy configuration files
copy_configs() {
    banner "Copying Configuration Files"
    
    # Handle configuration files
    if [ -f "${CONFIG_DIR}/flux.conf" ]; then
        warn "Existing configuration found. Creating backup..."
        cp "${CONFIG_DIR}/flux.conf" "${CONFIG_DIR}/flux.conf.backup"
    fi
    
    log "Copying configuration files to ${BOLD}${CONFIG_DIR}${RESET}"
    cp "${SCRIPT_DIR}/config/flux.conf" "${CONFIG_DIR}/flux.conf"
    
    # Copy tmux configuration if it exists
    if [ -f "${SCRIPT_DIR}/config/.tmux.conf" ]; then
        if $VERBOSE; then
            log "Copying tmux configuration file to ${BOLD}${HOME}${RESET}"
        fi
        cp "${SCRIPT_DIR}/config/.tmux.conf" "${HOME}/.tmux.conf"
        if $VERBOSE; then
            log "tmux configuration file copied ${GREEN}successfully${RESET}."
        fi
    elif $VERBOSE; then
        warn "tmux configuration file not found in ${SCRIPT_DIR}/config/"
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
    
    banner "Installation Complete"
    log "${GREEN}Flux Capacitor has been installed successfully!${RESET}"
    log "Configuration directory: ${BOLD}${CONFIG_DIR}${RESET}"
    log "Installation directory: ${BOLD}${INSTALLATION_DIR}${RESET}"
    log "You can now use Flux Capacitor. Enjoy!"
}

# Run the installation
main
