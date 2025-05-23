#!/usr/bin/env bash
# install.sh - Installs flux-capacitor

set -e

# Default directories
INSTALL_DIR="$HOME/.local/share/flux-capacitor"
CONFIG_DIR="$HOME/.config/flux-capacitor"
VERBOSE=false

# Parse command line arguments
while getopts "i:c:vf" opt; do
  case $opt in
    i)
      INSTALL_DIR="$OPTARG"
      ;;
    c)
      CONFIG_DIR="$OPTARG"
      ;;
    v)
      VERBOSE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Create directories
if $VERBOSE; then
  echo "Creating installation directory: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  echo "Creating configuration directory: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
else
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$CONFIG_DIR"
fi

# Create placeholder files for testing
if $VERBOSE; then
  echo "Installing files..."
  echo "Installing flux-capacitor to $INSTALL_DIR/flux-capacitor"
  echo "#!/bin/sh" > "$INSTALL_DIR/flux-capacitor"
  echo "echo 'Flux Capacitor v1.0'" >> "$INSTALL_DIR/flux-capacitor"
  chmod +x "$INSTALL_DIR/flux-capacitor"
  
  echo "Installing configuration to $CONFIG_DIR/flux.conf"
  echo "# Flux Capacitor Configuration" > "$CONFIG_DIR/flux.conf"
  echo "POWER_LEVEL=1.21" >> "$CONFIG_DIR/flux.conf"
else
  echo "#!/bin/sh" > "$INSTALL_DIR/flux-capacitor"
  echo "echo 'Flux Capacitor v1.0'" >> "$INSTALL_DIR/flux-capacitor"
  chmod +x "$INSTALL_DIR/flux-capacitor"
  
  echo "# Flux Capacitor Configuration" > "$CONFIG_DIR/flux.conf"
  echo "POWER_LEVEL=1.21" >> "$CONFIG_DIR/flux.conf"
fi

if $VERBOSE; then
  echo "Installation completed successfully!"
fi

exit 0
=======
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/flux"
INSTALLATION_DIR="${HOME}/.local/share/flux"
LOGS_DIR="${SCRIPT_DIR}/.logs"
INSTALL_LOG="${LOGS_DIR}/install_$(date +'%Y%m%d%H%M%S').log"

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
    echo -e "${timestamp} $1" >> "${INSTALL_LOG}"
    if $VERBOSE; then
        echo -e "${timestamp} $1"
    fi
}

# Print warning message (yellow)
warn() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${YELLOW}WARNING:${RESET} $1" >> "${INSTALL_LOG}"
    if $VERBOSE; then
        echo -e "${timestamp} ${YELLOW}WARNING:${RESET} $1"
    fi
}

# Print error message (red)
error() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${RED}ERROR:${RESET} $1" >> "${INSTALL_LOG}"
    # Always show errors, even without verbose flag
    echo -e "${timestamp} ${RED}ERROR:${RESET} $1"
}

# Print banner (highlighted important message)
banner() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    echo -e "${timestamp} ${BOLD}${BLUE}$1${RESET}" >> "${INSTALL_LOG}"
    if $VERBOSE; then
        echo -e "\n${BLUE}${BOLD}===============================================${RESET}"
        echo -e "${BLUE}${BOLD} $1 ${RESET}"
        echo -e "${BLUE}${BOLD}===============================================${RESET}\n"
    fi
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
    
    log "All dependencies are ${GREEN}installed${RESET}."
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
    
    # Copy installation files
    log "Copying installation files to ${BOLD}${INSTALLATION_DIR}${RESET}"
    cp -r "${SCRIPT_DIR}/install/"* "${INSTALLATION_DIR}/"
    
    log "Configuration and installation files copied ${GREEN}successfully${RESET}."
}

# Main installation process
main() {
    banner "Flux Capacitor Installation"
    
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
