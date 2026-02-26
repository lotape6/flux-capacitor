#!/usr/bin/env bash
# Test_flux_capacitor_init.sh - Tests for flux-capacitor-init.sh script

set -e

log() {
    # Prepend as many \t as number is set in $2
    local indent=""
    for ((i = 0; i < $(( ${2:-0} )); i++)); do
        indent+="\t"
    done
    echo -e "${indent}\e[1;36m$1\e[0m" 2
}

# Path to the flux-capacitor-init.sh script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SCRIPT="${SCRIPT_DIR}/../src/flux-capacitor-init.sh"

# Setup test environment
TEST_HOME=$(mktemp -d)
TEST_CONFIG_FILES=(".bashrc" ".zshrc" ".config/fish/config.fish")

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

log "Testing flux-capacitor-init.sh script..." 1

# Test 1: Init mode (default)
log "Test 1: Testing init mode (default)..." 1

# Run the script in init mode to get output
INIT_OUTPUT=$(HOME="${TEST_HOME}" "${INIT_SCRIPT}")

# Check if output contains expected initialization content
if echo "${INIT_OUTPUT}" | grep -q "flux-capacitor initialization"; then
    log "✓ Init mode generates appropriate output" 2
else
    log "✗ Init mode failed to generate expected output" 2
    log "${INIT_OUTPUT}" 2
    exit 1
fi

# Test 2: Install mode
log "Test 2: Testing install mode..." 1

# Run the script in install mode with bash as the shell to ensure predictable config file
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i

# Check if the snippet was added — check all possible config files
SNIPPET_FOUND=false
START_TAG="# >>> flux-capacitor initialization >>>"
for config_file in "${TEST_HOME}/.bashrc" "${TEST_HOME}/.zshrc" "${TEST_HOME}/.config/fish/config.fish"; do
    if [ -f "${config_file}" ] && grep -q "flux-capacitor initialization" "${config_file}"; then
        SNIPPET_FOUND=true
        DETECTED_CONFIG="${config_file}"
        break
    fi
done

if $SNIPPET_FOUND; then
    log "✓ Install mode successfully added snippet to shell config (${DETECTED_CONFIG##*/})" 2
else
    log "✗ Install mode failed to add snippet to any shell config" 2
    for config_file in "${TEST_HOME}/.bashrc" "${TEST_HOME}/.zshrc"; do
        echo "--- ${config_file} ---"; cat "${config_file}" 2>/dev/null || echo "(empty)"
    done
    exit 1
fi

# Test 3: Uninstall mode
log "Test 3: Testing uninstall mode..." 1

# Run the script in uninstall mode
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u

# Check if the snippet was removed
if grep -q "flux-capacitor initialization" "${DETECTED_CONFIG}" 2>/dev/null; then
    log "✗ Uninstall mode failed to remove snippet from shell config" 2
    cat "${DETECTED_CONFIG}"
    exit 1
else
    log "✓ Uninstall mode successfully removed snippet from shell config" 2
fi

# Test 4: Idempotent operations
log "Test 4: Testing idempotent install and uninstall..." 1

# Run install twice
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -i

# Check that only one snippet was added
SNIPPET_COUNT=$(grep -c "${START_TAG}" "${DETECTED_CONFIG}")
if [ "${SNIPPET_COUNT}" -eq 1 ]; then
    log "✓ Install mode is idempotent" 2
else
    log "✗ Install mode added multiple snippets when run twice" 2
    cat "${DETECTED_CONFIG}"
    exit 1
fi

# Run uninstall twice
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u
SHELL=/bin/bash HOME="${TEST_HOME}" "${INIT_SCRIPT}" -u

# Check that snippet is completely removed
if grep -q "flux-capacitor initialization" "${DETECTED_CONFIG}" 2>/dev/null; then
    log "✗ Multiple uninstall operations left snippets in place" 2
    cat "${DETECTED_CONFIG}"
    exit 1
else
    log "✓ Uninstall mode is idempotent" 2
fi

# Test 5: Help option
log "Test 5: Testing help option..." 1

# Run the script with help option
HELP_OUTPUT=$(HOME="${TEST_HOME}" "${INIT_SCRIPT}" -h)

# Check if help output contains expected content
if echo "${HELP_OUTPUT}" | grep -q "Usage:"; then
    log "✓ Help option displays usage information" 2
else
    log "✗ Help option failed to show usage information" 2
    log "${HELP_OUTPUT}" 2
    exit 1
fi

log "All tests for flux-capacitor-init.sh passed successfully!" 1
exit 0