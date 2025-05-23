#!/usr/bin/env bash
# Flux Capacitor Uninstallation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/flux"
UNINSTALL_LOG="${SCRIPT_DIR}/uninstall.log"

# Print message with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "${UNINSTALL_LOG}"
}

# Remove configuration files
remove_configs() {
    log "Checking for configuration files..."
    
    if [ -d "${CONFIG_DIR}" ]; then
        log "Found configuration directory. Backing up and removing..."
        
        # Create backup
        BACKUP_DIR="${HOME}/.config/flux_backup_$(date +'%Y%m%d%H%M%S')"
        mkdir -p "${BACKUP_DIR}"
        cp -r "${CONFIG_DIR}"/* "${BACKUP_DIR}"
        
        # Remove configuration
        rm -rf "${CONFIG_DIR}"
        
        log "Configuration files have been backed up to ${BACKUP_DIR} and removed."
    else
        log "No configuration directory found. Skipping..."
    fi
}

# Main uninstallation process
main() {
    log "Starting Flux Capacitor uninstallation..."
    
    remove_configs
    
    log "Flux Capacitor has been uninstalled successfully!"
    log "Your configuration files have been backed up. If you want to completely"
    log "remove all traces of Flux Capacitor, you can delete the backup directory."
    
    echo -e "\nTo complete the uninstallation, you can delete the Flux Capacitor directory:"
    echo "rm -rf ${SCRIPT_DIR}"
}

# Confirm uninstallation
echo "This will uninstall Flux Capacitor and remove your configuration."
echo "Your configuration will be backed up before removal."
read -p "Continue? (y/N): " confirm

if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    main
else
    echo "Uninstallation cancelled."
    exit 0
fi