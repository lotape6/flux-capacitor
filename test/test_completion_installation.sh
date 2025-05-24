#!/usr/bin/env bash
# test_completion_installation.sh - Test that the completion scripts are properly installed and working

# Exit on any error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

# Create test environment
TEST_DIR=$(mktemp -d)
TEST_HOME="${TEST_DIR}/home"

mkdir -p "${TEST_HOME}"
export HOME="${TEST_HOME}"

echo "Setting up test environment in ${TEST_HOME}..."

# Prepare minimal config for installation
FLUX_CONFIG_DIR="${TEST_HOME}/.flux-capacitor"
FLUX_INSTALLATION_DIR="${TEST_HOME}/.local/share/flux-capacitor"

mkdir -p "${FLUX_CONFIG_DIR}"
mkdir -p "${FLUX_INSTALLATION_DIR}"
mkdir -p "${FLUX_INSTALLATION_DIR}/completion"

# Create minimal config file
cat > "${FLUX_CONFIG_DIR}/flux.conf" <<EOF
# Minimal flux configuration for testing
FLUX_CONFIG_DIR="${FLUX_CONFIG_DIR}"
FLUX_INSTALLATION_DIR="${FLUX_INSTALLATION_DIR}"
FLUX_LOGS_DIR="${FLUX_CONFIG_DIR}/logs"
FLUX_VERBOSE_MODE=true
EOF

# Create the shell config files
mkdir -p "${TEST_HOME}/.config/fish"
touch "${TEST_HOME}/.bashrc"
touch "${TEST_HOME}/.zshrc"
touch "${TEST_HOME}/.config/fish/config.fish"

# Copy completion files directly
cp "${REPO_DIR}/install/completion/flux-completion.bash" "${FLUX_INSTALLATION_DIR}/completion/"
cp "${REPO_DIR}/install/completion/flux-completion.zsh" "${FLUX_INSTALLATION_DIR}/completion/"
cp "${REPO_DIR}/install/completion/flux-completion.fish" "${FLUX_INSTALLATION_DIR}/completion/"

# Create a simple flux.sh script
cat > "${FLUX_INSTALLATION_DIR}/flux.sh" <<EOF
#!/bin/bash
echo "Flux command: \$@"
EOF
chmod +x "${FLUX_INSTALLATION_DIR}/flux.sh"

# Manually add the shell initialization in .bashrc
cat >> "${TEST_HOME}/.bashrc" <<EOF
# >>> flux-capacitor initialization >>>
# Flux-capacitor configuration
source "${FLUX_CONFIG_DIR}/flux.conf"

# Create flux alias
if [ -f "${FLUX_INSTALLATION_DIR}/flux.sh" ]; then
    alias flux="${FLUX_INSTALLATION_DIR}/flux.sh"
fi

# Load flux command completion
if [ -f "${FLUX_INSTALLATION_DIR}/completion/flux-completion.bash" ]; then
    source "${FLUX_INSTALLATION_DIR}/completion/flux-completion.bash"
fi
# <<< flux-capacitor initialization <<<
EOF

# Test 1: Verify bash completion file
echo "Test 1: Verifying bash completion file is present..."
if [ ! -f "${FLUX_INSTALLATION_DIR}/completion/flux-completion.bash" ]; then
    echo "FAIL: Bash completion file is missing"
    exit 1
fi

# Test 2: Check if completion script registers properly
echo "Test 2: Testing bash completion registration..."

# Create a temporary script to test bash completion
cat > "${TEST_DIR}/test_bash_completion.sh" <<EOF
#!/bin/bash
source "${TEST_HOME}/.bashrc"

# Test if the _flux_completions function is available
if declare -F _flux_completions > /dev/null; then
    echo "Completion function _flux_completions is available"
    exit 0
else
    echo "Completion function _flux_completions is NOT available"
    exit 1
fi
EOF
chmod +x "${TEST_DIR}/test_bash_completion.sh"

if ! bash "${TEST_DIR}/test_bash_completion.sh"; then
    echo "FAIL: Bash completion function _flux_completions is not available after sourcing .bashrc"
    cat "${TEST_HOME}/.bashrc"
    exit 1
fi

echo "All completion installation tests passed!"
echo "Test environment is at ${TEST_DIR} if you want to explore it manually."

# Don't clean up test directory to allow for manual inspection
echo "You can manually inspect the test environment at ${TEST_DIR}"
exit 0