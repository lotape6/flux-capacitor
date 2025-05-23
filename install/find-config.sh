#!/usr/bin/env bash
# find-config.sh - Locates the flux.conf configuration file

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

# Default installation path (1st priority)
INSTALLATION_PATH="${HOME}/.local/share/flux"
DEFAULT_CONFIG_PATH="${HOME}/.config/flux/flux.conf"

# Home directory path (2nd priority)
HOME_CONFIG_PATH="${HOME}/flux.conf"

# Repository config path (3rd priority - fallback)
REPO_CONFIG_PATH="${REPO_DIR}/config/flux.conf"

# Function to check if a file exists and is readable
file_exists_and_readable() {
    [ -f "$1" ] && [ -r "$1" ]
}

# Search for the configuration file
find_config_file() {
    # Check default installation path first
    if file_exists_and_readable "${DEFAULT_CONFIG_PATH}"; then
        echo "${DEFAULT_CONFIG_PATH}"
        return 0
    fi
    
    # Check home directory next
    if file_exists_and_readable "${HOME_CONFIG_PATH}"; then
        echo "${HOME_CONFIG_PATH}"
        return 0
    fi
    
    # Fall back to the repo config
    if file_exists_and_readable "${REPO_CONFIG_PATH}"; then
        echo "${REPO_CONFIG_PATH}"
        return 0
    fi
    
    # If no config file is found, return the repo config path anyway
    # This will be used to create a new config file
    echo "${REPO_CONFIG_PATH}"
    return 1
}

# Main function
main() {
    find_config_file
    return $?
}

# If the script is being executed directly, run the main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
    exit $?
fi