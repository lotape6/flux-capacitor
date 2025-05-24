#!/usr/bin/env bash
# install.sh - Installs flux-capacitor

set -e

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

# Create logs directory if it doesn't exist
mkdir -p "${FLUX_LOGS_DIR}"

# Source the error code definitions
if [ -f "${CONFIG_DIR}/err_codes" ]; then
    source "${CONFIG_DIR}/err_codes"
else
    # If the file doesn't exist yet (first install), copy it first
    cp "${SCRIPT_DIR}/config/err_codes" "${CONFIG_DIR}/" 2>/dev/null || true
    source "${SCRIPT_DIR}/config/err_codes"
fi

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
    echo "  -r <path>    Override default root directory (default: ${FLUX_ROOT})"
    echo "  -h           Show this help message"
    echo
}



# Parse command line arguments
while getopts ":qr:h" opt; do
    case ${opt} in
        q)
            FLUX_VERBOSE_MODE=false
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
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warn "Some optional dependencies are not installed: ${missing_deps[*]}"
        log "Installing missing dependencies..."
        
        # Use the install-dependency.sh script for each dependency
        for dep in "${missing_deps[@]}"; do
            # If fzf is missing, install it from GitHub
            if [ "$dep" == "fzf" ]; then
                echo "Installing fzf from GitHub..."
                git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf" 2>/dev/null
                "${HOME}/.fzf/install" 2>/dev/null || true
            else
                "${SCRIPT_DIR}/src/install-dependency.sh" "$dep"
            fi
        done
    fi
    
    
    log "All dependencies are ${GREEN}installed${RESET}."
    
}

# Install Tmux Plugin Manager
install_tpm() {
    log "Installing Tmux Plugin Manager (TPM)..."
    
    TPM_DIR="${HOME}/.tmux/plugins/tpm"
    
    if [ -d "${TPM_DIR}" ]; then
        log "TPM is already installed at ${GREEN}${TPM_DIR}${RESET}."
    else
        log "Cloning TPM repository to ${GREEN}${TPM_DIR}${RESET}..."
        mkdir -p "${HOME}/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}" 2>/dev/null || {
            error "Failed to clone TPM repository."
            return 1
        }
        log "TPM installed ${GREEN}successfully${RESET}."
    fi
}

# Create necessary directories
create_dirs() {
    banner "Creating Directories"
    
    log "Creating root directory at ${BOLD}${FLUX_ROOT}${RESET}"
    mkdir -p "$FLUX_ROOT"
    mkdir -p "$FLUX_ROOT/config"
    mkdir -p "$FLUX_ROOT/src"
    mkdir -p "$FLUX_ROOT/src/completion"
    mkdir -p "$FLUX_LOGS_DIR"
    
    log "Directories created ${GREEN}successfully${RESET}."
}

# Copy configuration files
copy_configs() {
    banner "Copying Project Files"
    
    # Handle configuration files
    shopt -s dotglob nullglob
    
    log "Copying configuration files to ${BOLD}${FLUX_ROOT}/config${RESET}"
    cp -r "${SCRIPT_DIR}/config/"* "${FLUX_ROOT}/config/"
    
    # Copy src files (former installation files)
    log "Copying source files to ${BOLD}${FLUX_ROOT}/src${RESET}"
    cp -r "${SCRIPT_DIR}/src/"* "${FLUX_ROOT}/src/"
    
    # Copy other directories
    if [ -d "${SCRIPT_DIR}/docs" ]; then
        log "Copying documentation to ${BOLD}${FLUX_ROOT}/docs${RESET}"
        mkdir -p "${FLUX_ROOT}/docs"
        cp -r "${SCRIPT_DIR}/docs/"* "${FLUX_ROOT}/docs/" 2>/dev/null || true
    fi
    
    if [ -d "${SCRIPT_DIR}/resources" ]; then
        log "Copying resources to ${BOLD}${FLUX_ROOT}/resources${RESET}"
        mkdir -p "${FLUX_ROOT}/resources"
        cp -r "${SCRIPT_DIR}/resources/"* "${FLUX_ROOT}/resources/" 2>/dev/null || true
    fi
    
    if [ -d "${SCRIPT_DIR}/test" ]; then
        log "Copying tests to ${BOLD}${FLUX_ROOT}/test${RESET}"
        mkdir -p "${FLUX_ROOT}/test"
        cp -r "${SCRIPT_DIR}/test/"* "${FLUX_ROOT}/test/" 2>/dev/null || true
    fi
    
    shopt -u dotglob nullglob
    
    log "Project files copied ${GREEN}successfully${RESET}."
}

# Run flux-capacitor-init.sh in install mode
config_shell_support() {

    # Set up tmux configuration
    if [ -f "${FLUX_ROOT}/config/.tmux.conf" ]; then
        warn "Tmux configuration found."
        read -p "Do you want to overwrite it? (y/n) " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            log "Overwriting tmux configuration..."
            ln -sf "${FLUX_ROOT}/config/.tmux.conf" "${HOME}/.tmux.conf"
        else
            log "Keeping existing tmux configuration."
        fi
    else
        log "Symlink created from ${GREEN}${FLUX_ROOT}/config/.tmux.conf${RESET} to ${GREEN}${HOME}/.tmux.conf${RESET}"
        ln -sf "${FLUX_ROOT}/config/.tmux.conf" "${HOME}/.tmux.conf"
    fi


    if [ -f "${SCRIPT_DIR}/src/flux-capacitor-init.sh" ]; then
        log "Adding shell initialization snippets..."
        "${SCRIPT_DIR}/src/flux-capacitor-init.sh" -i
        log "Shell initialization snippets added ${GREEN}successfully${RESET}."
    fi
}

# Main installation process
main() {
    banner "Flux Capacitor Installation"
    show_ascii_banner
     
    log "Starting installation process..."
    
    check_dependencies
    create_dirs
    copy_configs
    config_shell_support
    install_tpm

    banner "Installation Complete"
    log "${GREEN}Flux Capacitor has been installed successfully!${RESET}"
    log "Root directory: ${BOLD}${FLUX_ROOT}${RESET}"
    # 🎉 Fancy ASCII Art Celebration 🎉
    echo -e "${GREEN}"
    echo -e "${RESET}"
    echo -e "🚀 ${BOLD}${GREEN}Flux Capacitor has been installed!${RESET} 🚀"
    echo
    log "${BOLD}Do not forget to update your shell configuration files!${RESET}"
    echo
    echo -e "${GREEN}✨ Enjoy your new productivity superpowers! ✨${RESET}"
}

# Run the installation
main
