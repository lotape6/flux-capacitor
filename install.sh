#!/usr/bin/env bash
# Flux Capacitor Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/flux"
INSTALL_LOG="${SCRIPT_DIR}/install.log"

# Print message with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "${INSTALL_LOG}"
}

# Check for dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v git &> /dev/null; then
        log "Error: git is not installed. Please install git and try again."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        log "Error: curl is not installed. Please install curl and try again."
        exit 1
    fi
    
    log "All dependencies are installed."
}

# Create necessary directories
create_dirs() {
    log "Creating configuration directories..."
    mkdir -p "${CONFIG_DIR}"
    log "Directories created successfully."
}

# Copy configuration files
copy_configs() {
    log "Copying configuration files..."
    if [ -f "${CONFIG_DIR}/flux.conf" ]; then
        log "Existing configuration found. Creating backup..."
        cp "${CONFIG_DIR}/flux.conf" "${CONFIG_DIR}/flux.conf.backup"
    fi
    
    cp "${SCRIPT_DIR}/config/flux.conf" "${CONFIG_DIR}/flux.conf"
    log "Configuration files copied successfully."
}

# Main installation process
main() {
    log "Starting Flux Capacitor installation..."
    
    check_dependencies
    create_dirs
    copy_configs
    
    log "Flux Capacitor has been installed successfully!"
    log "You can now use Flux Capacitor. Enjoy!"
}

# Run the installation
main