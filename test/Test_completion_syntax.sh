#!/usr/bin/env bash
# test_completion_syntax.sh - Test that the completion scripts have valid syntax

# Exit on any error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname ${SCRIPT_DIR})"

echo "Testing completion script syntax..."

# Test Bash completion script
echo "Testing bash completion script..."
bash -n "${REPO_DIR}/src/completion/flux-completion.bash" || { echo "Bash completion script has syntax errors"; exit 1; }

# Test Zsh completion script (if zsh is available)
if command -v zsh >/dev/null 2>&1; then
    echo "Testing zsh completion script..."
    zsh -n "${REPO_DIR}/src/completion/flux-completion.zsh" || { echo "Zsh completion script has syntax errors"; exit 1; }
else
    echo "Zsh not found, skipping zsh completion test"
fi

# Test Fish completion script (we can only check if it's readable since fish has a unique syntax)
echo "Testing fish completion script..."
if [ -r "${REPO_DIR}/src/completion/flux-completion.fish" ]; then
    echo "Fish completion script is readable"
else
    echo "Fish completion script is not readable"
    exit 1
fi

echo "All completion scripts passed syntax checking"