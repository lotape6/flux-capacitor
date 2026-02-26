#!/usr/bin/env bash
# install.sh - Installs flux-capacitor

set -e

# Flags
FORCE_INSTALL=false

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
            FORCE_INSTALL=true
            ;;
        r)
            FLUX_ROOT="${OPTARG}"
            # Update derived paths
            FLUX_LOGS_DIR="${FLUX_ROOT}/logs"
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

# Define log file path locally
FLUX_INSTALL_LOG="${FLUX_LOGS_DIR}/install_$(date +'%Y%m%d%H%M%S').log"

# Source the error code definitions
if [ -f "${CONFIG_DIR}/err.codes" ]; then
    source "${CONFIG_DIR}/err.codes"
else
    # If the file doesn't exist yet (first install), copy it first
    cp "${SCRIPT_DIR}/config/err.codes" "${CONFIG_DIR}/" 2>/dev/null || true
    source "${SCRIPT_DIR}/config/err.codes"
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


# Check for dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    # Initialize missing deps array
    missing_deps=()

    # Check for additional dependencies
    for dep in git curl tmux fzf bat delta; do
        dep_path="$(command -v "$dep" 2>/dev/null || \
                    ls "$HOME/.local/bin/$dep" 2>/dev/null || \
                    ls "$HOME/.fzf/bin/$dep" 2>/dev/null || \
                    ls "$HOME/.cargo/bin/$dep" 2>/dev/null || true)"
        if [ -z "$dep_path" ]; then
            missing_deps+=("$dep")
        fi
    done
    
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warn "Some optional dependencies are not installed: ${missing_deps[*]}"
        log "Trying to install missing optional dependencies..."
        
        # Use the install-dependency.sh script for each dependency
        for dep in "${missing_deps[@]}"; do
            # If fzf is missing, install it from GitHub
            if [ "$dep" == "fzf" ]; then
                echo "Installing fzf from GitHub..."
                git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf" 2>/dev/null || true
                "${HOME}/.fzf/install" --all 2>/dev/null || true
            else
                "${SCRIPT_DIR}/src/install-dependency.sh" "$dep"
            fi
        done
        
        # Only print success message if all dependencies were handled
        warn "Some dependencies may still be missing. Please verify manually if needed."
    else
        log "All dependencies are ${GREEN}installed${RESET}."
    fi
    
    # Check if tmux is missing - tmux is a critical dependency
    if ! command -v tmux >/dev/null 2>&1 || ! tmux -V >/dev/null 2>&1; then
        error "${RED}CRITICAL:${RESET} tmux is required but not installed or not working properly."
        error "Please ensure tmux is installed and accessible in your PATH."
        error "${RED}Installation cannot continue without tmux.${RESET}"
        tmux_err_output=$(tmux -V 2>&1 || true)
        if [ -n "$tmux_err_output" ]; then
            error "tmux error output: $tmux_err_output"
        fi
        exit "${EXIT_DEPENDENCY_MISSING}"
    fi

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

copy_files() {
    log "Copying project files to ${GREEN}${FLUX_ROOT}${RESET}..."
    
    # Create the root directory if it doesn't exist
    mkdir -p "${FLUX_ROOT}"
    
    # Copy all files from the script directory to the root directory
    cp -r "${SCRIPT_DIR}/"* "${FLUX_ROOT}/"
    
    log "Project files copied ${GREEN}successfully${RESET}."
}

# Copy configuration files
install_files() {
    banner "Copying Project Files"
    
    # Handle configuration files
    if [ -d "${HOME}/.tmux.conf" ] && [ "$FORCE_INSTALL" == "false" ]; then
        warn "Tmux configuration found in ${HOME}. Not copying."
        read -p "Do you want to overwrite it? (y/n) " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            log "Overwriting tmux configuration..."
            copy_files
        else
            log "Keeping existing tmux configuration."
        fi
    else
        log "Installing ${BOLD}flux-capacitor${RESET} in ${GREEN}${FLUX_ROOT}${RESET}..."
        mkdir -p "${FLUX_ROOT}"
        copy_files
    fi
           
    log "Project files copied ${GREEN}successfully${RESET}."
}

# Run flux-capacitor-init.sh in install mode
config_shell_support() {

    # Set up tmux configuration
    if [ -d "${HOME}/.tmux.conf" ] && [ "$FORCE_INSTALL" == "false" ]; then
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
    install_files
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
