#!/usr/bin/env bash
set -e

# Run all test scripts in the test directory
echo "Running all installation tests..."

# Path to the test directory (relative to this script)
TEST_DIR="$(dirname "$0")"

# Function to run all test scripts
run_all_tests() {
    local exit_code=0
    
    # Run each test script
    for test_script in "$TEST_DIR"/Test_*.sh; do
        echo "Running test: $(basename "$test_script")"
        if ! "$test_script"; then
            echo "FAILED: $(basename "$test_script")"
            exit_code=1
        else
            echo "PASSED: $(basename "$test_script")"
        fi
        
        # Clean up any leftover directories
        rm -rf "$HOME/.local/share/flux-capacitor" 
        rm -rf "$HOME/.config/flux-capacitor"
        rm -rf "/tmp/flux-capacitor-install"
        rm -rf "/tmp/flux-capacitor-config"
        rm -rf "/tmp/flux-capacitor-both"
    done
    
    return $exit_code
}

# Run the tests
if run_all_tests; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi

