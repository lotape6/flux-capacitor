#!/usr/bin/env bash
# utils.sh - Shared utility functions and variables for flux-capacitor

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'
ITALIC='\033[3m'

# Default flag values
VERBOSE=true
FORCE_REMOVE=false # Only used in uninstall.sh

# Display fancy ASCII art banner with colors (purple, blue, cyan, green)
show_ascii_banner() {
    if $VERBOSE; then
        echo -e "${PURPLE}${BOLD}"
        echo '        .------------------------------------.'
        echo -e "      ${PURPLE}|${BLUE}   _______   ${CYAN} _______   ${GREEN} _______       ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}  |     | |  ${CYAN}|     | |  ${GREEN}|     | |      ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}  |  F  | |  ${CYAN}|  L  | |  ${GREEN}|  X  | |      ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}  |_____| |  ${CYAN}|_____| |  ${GREEN}|_____| |      ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}    \\   /      ${CYAN}  \\ /      ${GREEN}  \\ /        ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}     \\ /        ${CYAN} V        ${GREEN} V           ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}      V         ${CYAN}         ${GREEN}              ${PURPLE}|"
        echo -e "      ${PURPLE}|${BLUE}   ${BOLD}${YELLOW}⚡${CYAN}⚡${GREEN}⚡${RESET}${PURPLE}   ${BOLD}${CYAN}F${YELLOW}L${GREEN}U${CYAN}X${RESET} ${BOLD}${PURPLE}C${BLUE}A${CYAN}P${GREEN}A${YELLOW}C${PURPLE}I${BLUE}T${CYAN}O${GREEN}R${RESET}   ${BOLD}${YELLOW}⚡${CYAN}⚡${GREEN}⚡${RESET}${PURPLE}   |"
        echo -e "      ${PURPLE}|${BOLD}${BLUE}    🚀${CYAN}🌀${GREEN}✨${YELLOW}🛸${PURPLE}   ${BOLD}${CYAN}TIME TRAVEL ENABLED!${RESET}${PURPLE}   |"
        echo -e "      ${PURPLE}|${BOLD}${BLUE}   ${YELLOW}⏳${CYAN}🔋${GREEN}💡${YELLOW}⏳${PURPLE}   ${BOLD}${CYAN}88 MPH TO THE FUTURE!${RESET}${PURPLE}   |"
        echo "        '------------------------------------'"
        echo -e "${RESET}"
        echo -e "${CYAN}${BOLD}         F L U X   -   C A P A C I T O R${RESET}\n"
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
        echo -e " ${BLUE}[LOG]${RESET} $1"
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
        echo -e "${YELLOW}[WARN]${RESET} ${YELLOW}WARNING:${RESET} $1"
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
    echo -e " ${PURPLE}${BOLD}[ERROR]${RESET} ${RED}ERROR:${RESET} $1"
}

# Print banner (highlighted important message)
# $1: Banner message
# $2: Log file path
banner_impl() {
    local timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"
    local log_file="${2}"
    local verbose="${3:-$VERBOSE}"
    
    echo -e " [] $1" >> "${log_file}"
    if $verbose; then
        echo -e "\n${PURPLE}${BOLD}\t~~~~~~~~~~~~$1~~~~~~~~~~~~ ${RESET}\n"
    fi
}