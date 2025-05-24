#!/usr/bin/env sh
# flux-capacitor-init.sh - Shell initialization script for flux-capacitor
#
# Supports only bash, zsh, and fish shells (same as fzf)
#
# Usage:
#   ./flux-capacitor-init.sh        - Init mode: Output shell-specific initialization snippet
#   ./flux-capacitor-init.sh -i     - Install mode: Add init snippet to shell config
#   ./flux-capacitor-init.sh -u     - Uninstall mode: Remove init snippet from shell config

# Use POSIX sh syntax for maximum compatibility

# Exit on error
set -e

# Get script directory without Bash-specific features
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")
REPO_DIR=$(dirname "${SCRIPT_DIR}")

# Find the flux config file
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_DIR=$(realpath "${SCRIPT_DIR}")
    REPO_DIR=$(realpath "${REPO_DIR}")
fi

# Source utils if available (non-critical)
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    . "${SCRIPT_DIR}/utils.sh"
fi

# Default mode is init
MODE="init"

# Function to show usage instructions
show_usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo
    echo "Options:"
    echo "  -i           Install mode: Add init snippet to shell config"
    echo "  -u           Uninstall mode: Remove init snippet from shell config"
    echo "  -h           Show this help message"
    echo
}

# Parse command line arguments
while getopts "iuh" opt; do
    case ${opt} in
        i)
            MODE="install"
            ;;
        u)
            MODE="uninstall"
            ;;
        h)
            show_usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            show_usage
            exit 1
            ;;
    esac
done

# Check if a string is in a file
is_string_in_file() {
    grep -q "$1" "$2" 2>/dev/null
    return $?
}

# Detect the user's shell
# Only supporting bash, zsh, and fish (same as fzf)
detect_shell() {
    # Try to use the SHELL environment variable first
    if [ -n "${SHELL}" ]; then
        SHELL_NAME=$(basename "${SHELL}")
        case "${SHELL_NAME}" in
            bash|zsh|fish)
                echo "${SHELL_NAME}"
                return
                ;;
        esac
    fi
    
    # Fall back to checking the parent process
    if command -v ps >/dev/null 2>&1; then
        PARENT_PID=$(ps -p $$ -o ppid=)
        PARENT_CMD=$(ps -p "${PARENT_PID}" -o comm= 2>/dev/null || echo "unknown")
        PARENT_BASE=$(basename "${PARENT_CMD}" 2>/dev/null || echo "unknown")
        
        case "${PARENT_BASE}" in
            bash|zsh|fish)
                echo "${PARENT_BASE}"
                return
                ;;
        esac
    fi
    
    # Default to bash if we can't detect
    echo "bash"
}

# Get config file path for the specified shell
# Only supporting bash, zsh, and fish (same as fzf)
get_config_file() {
    SHELL_TYPE=$1
    
    case "${SHELL_TYPE}" in
        bash)
            if [ -f "${HOME}/.bashrc" ]; then
                echo "${HOME}/.bashrc"
            elif [ -f "${HOME}/.bash_profile" ]; then
                echo "${HOME}/.bash_profile"
            else
                echo "${HOME}/.bashrc"  # Default if none exists
            fi
            ;;
        zsh)
            echo "${HOME}/.zshrc"
            ;;
        fish)
            echo "${HOME}/.config/fish/config.fish"
            ;;
        *)
            # Default to bash
            echo "${HOME}/.bashrc"
            ;;
    esac
}

# Generate init snippet for the specified shell
# Only supporting bash, zsh, and fish (same as fzf)
create_snippet() {
    SHELL_TYPE=$1
    CONFIG_FILE=$("${REPO_DIR}/install/find-config.sh" 2>/dev/null || echo "${REPO_DIR}/config/flux.conf")
    
    # Source the config to get FLUX_CONFIG_DIR
    # shellcheck disable=SC1090
    . "$CONFIG_FILE" 2>/dev/null || true
    
    # Common initialization snippet comment marker
    SNIPPET_START="# >>> flux-capacitor initialization >>>"
    SNIPPET_END="# <<< flux-capacitor initialization <<<"
    
    case "${SHELL_TYPE}" in
        bash)
            cat <<EOF
${SNIPPET_START}
# Flux-capacitor configuration
source "${CONFIG_FILE}"

# Add keybindings here
# Example: bind '\\C-g:flux-command'

# Set up tmux configuration
if [ -f "${FLUX_CONFIG_DIR}/.tmux.conf" ] && command -v tmux >/dev/null 2>&1; then
    ln -sf "${FLUX_CONFIG_DIR}/.tmux.conf" "\${HOME}/.tmux.conf"
fi

# Create flux alias
if [ -f "${FLUX_INSTALLATION_DIR}/flux.sh" ]; then
    alias flux="${FLUX_INSTALLATION_DIR}/flux.sh"
fi

# Load flux command completion
if [ -f "${FLUX_INSTALLATION_DIR}/completion/flux-completion.bash" ]; then
    source "${FLUX_INSTALLATION_DIR}/completion/flux-completion.bash"
fi

# FZF initialization (if installed)
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi
${SNIPPET_END}
EOF
            ;;
        zsh)
            cat <<EOF
${SNIPPET_START}
# Flux-capacitor configuration
. "${CONFIG_FILE}"

# Add keybindings here
# Example: bindkey '^G' flux-command

# Set up tmux configuration
if [ -f "${FLUX_CONFIG_DIR}/.tmux.conf" ] && command -v tmux >/dev/null 2>&1; then
    ln -sf "${FLUX_CONFIG_DIR}/.tmux.conf" "\${HOME}/.tmux.conf"
fi

# Create flux alias
if [ -f "${FLUX_INSTALLATION_DIR}/flux.sh" ]; then
    alias flux="${FLUX_INSTALLATION_DIR}/flux.sh"
fi

# Load flux command completion
if [ -f "${FLUX_INSTALLATION_DIR}/completion/flux-completion.zsh" ]; then
    source "${FLUX_INSTALLATION_DIR}/completion/flux-completion.zsh"
fi

# FZF initialization (if installed)
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi
${SNIPPET_END}
EOF
            ;;
        fish)
            cat <<EOF
${SNIPPET_START}
# Flux-capacitor configuration
set -x FLUX_CONFIG_FILE "${CONFIG_FILE}"
set -x FLUX_INSTALLATION_DIR "${SCRIPT_DIR}"

# Add keybindings here
# Example: bind \\cg 'flux-command'

# Set up tmux configuration
if test -f "${FLUX_CONFIG_DIR}/.tmux.conf"; and command -v tmux >/dev/null 2>&1
    ln -sf "${FLUX_CONFIG_DIR}/.tmux.conf" "\$HOME/.tmux.conf"
end

# Create flux alias
if test -f "${FLUX_INSTALLATION_DIR}/flux.sh"
    alias flux="${FLUX_INSTALLATION_DIR}/flux.sh"
end

# Load flux command completion
if test -f "${FLUX_INSTALLATION_DIR}/completion/flux-completion.fish"
    source "${FLUX_INSTALLATION_DIR}/completion/flux-completion.fish"
end

# FZF initialization (if installed)
if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end
${SNIPPET_END}
EOF
            ;;
        *)
            # Default to bash
            create_snippet "bash"
            ;;
    esac
}

# Add snippet to shell config
add_snippet_to_config() {
    SHELL_TYPE=$1
    CONFIG_FILE=$(get_config_file "${SHELL_TYPE}")
    
    # Create directory if it doesn't exist (especially for fish)
    CONFIG_DIR=$(dirname "${CONFIG_FILE}")
    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    fi
    
    # Create file if it doesn't exist
    if [ ! -f "${CONFIG_FILE}" ]; then
        touch "${CONFIG_FILE}"
    fi
    
    # Check if snippet is already present
    SNIPPET_START="# >>> flux-capacitor initialization >>>"
    SNIPPET_END="# <<< flux-capacitor initialization <<<"
    
    if is_string_in_file "${SNIPPET_START}" "${CONFIG_FILE}"; then
        echo "Flux-capacitor initialization snippet already exists in ${CONFIG_FILE}"
        return 0
    fi
    
    echo "Adding flux-capacitor initialization snippet to ${CONFIG_FILE}"
    
    # Add snippet to the end of the file
    create_snippet "${SHELL_TYPE}" >> "${CONFIG_FILE}"
    
    echo "Flux-capacitor initialization snippet added to ${CONFIG_FILE}"
}

# Remove snippet from shell config
remove_snippet_from_config() {
    SHELL_TYPE=$1
    CONFIG_FILE=$(get_config_file "${SHELL_TYPE}")
    
    # Check if file exists
    if [ ! -f "${CONFIG_FILE}" ]; then
        echo "Shell config file ${CONFIG_FILE} not found"
        return 0
    fi
    
    # Check if snippet is present
    SNIPPET_START="# >>> flux-capacitor initialization >>>"
    SNIPPET_END="# <<< flux-capacitor initialization <<<"
    
    if ! is_string_in_file "${SNIPPET_START}" "${CONFIG_FILE}"; then
        echo "No flux-capacitor initialization snippet found in ${CONFIG_FILE}"
        return 0
    fi
    
    echo "Removing flux-capacitor initialization snippet from ${CONFIG_FILE}"
    
    # Create a temporary file
    TEMP_FILE=$(mktemp)
    
    # Remove the snippet
    sed "/${SNIPPET_START}/,/${SNIPPET_END}/d" "${CONFIG_FILE}" > "${TEMP_FILE}"
    
    # Copy back to original file
    cat "${TEMP_FILE}" > "${CONFIG_FILE}"
    
    # Remove temp file
    rm "${TEMP_FILE}"
    
    echo "Flux-capacitor initialization snippet removed from ${CONFIG_FILE}"
}

# Main logic based on mode
main() {
    # Get the current shell
    CURRENT_SHELL=$(detect_shell)
    
    case "${MODE}" in
        init)
            # Just output the snippet for the current shell
            create_snippet "${CURRENT_SHELL}"
            ;;
        install)
            # Add snippet to the shell config file
            add_snippet_to_config "${CURRENT_SHELL}"
            ;;
        uninstall)
            # Remove snippet from the shell config file
            remove_snippet_from_config "${CURRENT_SHELL}"
            ;;
    esac
}

# Run the main function
main