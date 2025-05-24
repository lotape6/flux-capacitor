#!/usr/bin/env bash
# utils.sh - Shared utility functions and variables for flux-capacitor

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# Default flag values
VERBOSE=true
FORCE_REMOVE=false # Only used in uninstall.sh

# Display ASCII art banner
show_ascii_banner() {
    if $VERBOSE; then
        echo -e "${PURPLE}${BOLD}"
        echo '   _______________________'
        echo '  /                       \'
        echo ' /   ___________________   \'
        echo '|   |                   |   |'
        echo '|   |    _     _        |   |'
        echo '|   |   | |   | |       |   |'
        echo '|   |   | |___| |       |   |'
        echo '|   |   |  ___  |  ⚡   |   |'
        echo '|   |   | |   | |       |   |'
        echo '|   |   |_|   |_|       |   |'
        echo '|   |___________________|   |'
        echo ' \   F L U X - C A P      /'
        echo '  \_______________________/'
        echo -e "${RESET}"
    fi
}

# Print standard log message
# $1: Message to log
# $2: Log file path
log_impl() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    local log_file="${2}"
    local verbose="${3:-$VERBOSE}"
    
    echo -e "${timestamp} $1" >> "${log_file}"
    if $VERBOSE; then
        echo -e "${timestamp} $1"
    fi
}

# Print warning message (yellow)
# $1: Warning message
# $2: Log file path
warn_impl() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    local log_file="${2}"
    local verbose="${3:-$VERBOSE}"

    echo -e "${timestamp} WARNING: $1" >> "${log_file}"
    if $verbose; then
        echo -e "${timestamp} ${YELLOW}WARNING:${RESET} $1"
    fi
}

# Print error message (red)
# $1: Error message
# $2: Log file path
error_impl() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    local log_file="${2}"

    echo -e "${timestamp} ERROR: $1" >> "${log_file}"
    # Always show errors, even without verbose flag
    echo -e "${timestamp} ${RED}ERROR:${RESET} $1"
}

# Print banner (highlighted important message)
# $1: Banner message
# $2: Log file path
banner_impl() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    local log_file="${2}"
    local verbose="${3:-$VERBOSE}"
    
    echo -e "${timestamp} $1" >> "${log_file}"
    if $verbose; then
        echo -e "\n${PURPLE}${BOLD}===============================================${RESET}"
        echo -e "${PURPLE}${BOLD} $1 ${RESET}"
        echo -e "${PURPLE}${BOLD}===============================================${RESET}\n"
    fi
}