#!/usr/bin/env bash
set -e

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Try to find and source the error codes file
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE=""

if [ -f "${SCRIPT_DIR}/../src/find-config.sh" ]; then
    CONFIG_FILE="$(${SCRIPT_DIR}/../src/find-config.sh)"
    source "${CONFIG_FILE}"
    if [ -f "${CONFIG_DIR}/err.codes" ]; then
        source "${CONFIG_DIR}/err.codes"
    elif [ -f "${SCRIPT_DIR}/../config/err.codes" ]; then
        source "${SCRIPT_DIR}/../config/err.codes"
    fi
else
    # Define minimal error codes if we can't find the file
    readonly EXIT_SUCCESS=0
    readonly EXIT_TEST_FAILURE=10
fi

echo -e "${CYAN}${BOLD}Running all tests...${RESET}"

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
            exit_code=${EXIT_TEST_FAILURE}
        fi
        rm -f "$output_file"


    done

    echo -e "${YELLOW}----------------------------------------${RESET}"
    return $exit_code
}

# Run the tests
if run_all_tests; then
    echo -e "${GREEN}${BOLD}All tests passed!${RESET}"
    exit ${EXIT_SUCCESS}
else
    echo -e "${RED}${BOLD}Some tests failed!${RESET}"
    exit ${EXIT_TEST_FAILURE}
fi
