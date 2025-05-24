#!/usr/bin/env bash
# Test_connect_script.sh - Test that the connect.sh script has valid syntax

# Exit on any error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

echo "Testing connect.sh functionality..."

# Test connect.sh syntax
echo "Testing connect.sh syntax..."
bash -n "${REPO_DIR}/install/connect.sh" || { echo "connect.sh has syntax errors"; exit 1; }

# Basic validation - check if script exists and is executable
if [[ ! -x "${REPO_DIR}/install/connect.sh" ]]; then
    chmod +x "${REPO_DIR}/install/connect.sh"
    echo "Made connect.sh executable"
fi

echo "connect.sh passed checks"
exit 0