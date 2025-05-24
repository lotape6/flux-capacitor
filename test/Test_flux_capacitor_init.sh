#!/usr/bin/env bash
# Test_flux_capacitor_init.sh - Tests for flux-capacitor-init.sh script

set -e

# Path to the flux-capacitor-init.sh script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="${SCRIPT_DIR}/../install/flux-capacitor-init.sh"

# Setup test environment
TEST_HOME=$(mktemp -d)
TEST_CONFIG_FILES=(".bashrc" ".zshrc" ".config/fish/config.fish" ".tcshrc" ".kshrc" ".profile")

# Create test shell config files
for config_file in "${TEST_CONFIG_FILES[@]}"; do
    mkdir -p "$(dirname "${TEST_HOME}/${config_file}")"
    touch "${TEST_HOME}/${config_file}"
done

# Original HOME backup
ORIGINAL_HOME="${HOME}"

# Function to cleanup test environment
cleanup() {
    export HOME="${ORIGINAL_HOME}"
    rm -rf "${TEST_HOME}"
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

echo "Testing flux-capacitor-init.sh script..."

# Test 1: Init mode (default)
echo "Test 1: Testing init mode (default)..."

# Run the script in init mode to get output
INIT_OUTPUT=$(HOME="${TEST_HOME}" "${INIT_SCRIPT}")

# Check if output contains expected initialization content
if echo "${INIT_OUTPUT}" | grep -q "flux-capacitor initialization"; then
    echo "✓ Init mode generates appropriate output"
else
    echo "✗ Init mode failed to generate expected output"
    echo "${INIT_OUTPUT}"
    exit 1
fi

# Test 2: Install mode
echo "Test 2: Testing install mode..."

# Run the script in install mode
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i

# Check if the snippet was added to the shell config file
# We'll check for .bashrc as it's the default for most systems
if grep -q "flux-capacitor initialization" "${TEST_HOME}/.bashrc"; then
    echo "✓ Install mode successfully added snippet to shell config"
else
    echo "✗ Install mode failed to add snippet to shell config"
    cat "${TEST_HOME}/.bashrc"
    exit 1
fi

# Test 3: Uninstall mode
echo "Test 3: Testing uninstall mode..."

# Run the script in uninstall mode
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u

# Check if the snippet was removed from the shell config file
if grep -q "flux-capacitor initialization" "${TEST_HOME}/.bashrc"; then
    echo "✗ Uninstall mode failed to remove snippet from shell config"
    cat "${TEST_HOME}/.bashrc"
    exit 1
else
    echo "✓ Uninstall mode successfully removed snippet from shell config"
fi

# Test 4: Idempotent operations
echo "Test 4: Testing idempotent install and uninstall..."

# Run install twice
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i

# Check that only one snippet was added
START_TAG="# >>> flux-capacitor initialization >>>"
SNIPPET_COUNT=$(grep -c "${START_TAG}" "${TEST_HOME}/.bashrc")
if [ "${SNIPPET_COUNT}" -eq 1 ]; then
    echo "✓ Install mode is idempotent"
else
    echo "✗ Install mode added multiple snippets when run twice"
    cat "${TEST_HOME}/.bashrc"
    exit 1
fi

# Run uninstall twice
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u
HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u

# Check that snippet is completely removed
if grep -q "flux-capacitor initialization" "${TEST_HOME}/.bashrc"; then
    echo "✗ Multiple uninstall operations left snippets in place"
    cat "${TEST_HOME}/.bashrc"
    exit 1
else
    echo "✓ Uninstall mode is idempotent"
fi

# Test 5: Help option
echo "Test 5: Testing help option..."

# Run the script with help option
HELP_OUTPUT=$(HOME="${TEST_HOME}" "${INIT_SCRIPT}" -h)

# Check if help output contains expected content
if echo "${HELP_OUTPUT}" | grep -q "Usage:"; then
    echo "✓ Help option displays usage information"
else
    echo "✗ Help option failed to show usage information"
    echo "${HELP_OUTPUT}"
    exit 1
fi

echo "All tests for flux-capacitor-init.sh passed successfully!"
exit 0