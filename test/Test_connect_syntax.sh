#!/usr/bin/env bash
# test_connect_syntax.sh - Test that the connect.sh script has valid syntax

# Exit on any error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname ${SCRIPT_DIR})"

echo "Testing connect.sh script syntax..."

# Test connect.sh syntax
echo "Testing connect.sh syntax..."
bash -n "${REPO_DIR}/src/connect.sh" || { echo "connect.sh has syntax errors"; exit 1; }

echo "connect.sh passed syntax checking"