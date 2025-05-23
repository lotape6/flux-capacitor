#!/usr/bin/env bash
set -e

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${CYAN}${BOLD}Running all installation tests...${RESET}"

# Path to the test directory (relative to this script)
TEST_DIR="$(dirname "$0")"

# Function to run all test scripts
run_all_tests() {
    local exit_code=0

    for test_script in "$TEST_DIR"/Test_*.sh; do
        test_name="$(basename "$test_script")"
        echo -e "${YELLOW}----------------------------------------${RESET}"
        echo -e "${BOLD}Running test:${RESET} ${CYAN}${test_name}${RESET}"

        # Capture output and error
        output_file=$(mktemp)
        if "$test_script" >"$output_file" 2>&1; then
            echo -e "${GREEN}PASSED:${RESET} ${test_name}"
        else
            echo -e "${RED}FAILED:${RESET} ${test_name}"
            echo -e "${RED}--- Output/Error ---${RESET}"
            cat "$output_file" | sed "s/^/${RED}/;s/$/${RESET}/"
            exit_code=1
        fi
        rm -f "$output_file"

        # Clean up any leftover directories
        rm -rf "$HOME/.local/share/flux-capacitor"
        rm -rf "$HOME/.config/flux-capacitor"
        rm -rf "/tmp/flux-capacitor-install"
        rm -rf "/tmp/flux-capacitor-config"
        rm -rf "/tmp/flux-capacitor-both"
    done

    echo -e "${YELLOW}----------------------------------------${RESET}"
    return $exit_code
}

# Run the tests
if run_all_tests; then
    echo -e "${GREEN}${BOLD}All tests passed!${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}Some tests failed!${RESET}"
    exit 1
fi
