#!/usr/bin/env bash
set -e

# Install project
echo "Running installation script..."
"${BASH_SOURCE%/*}/../install.sh" -v

# Basic checks
echo "Checking configuration directory..."
if [ -d "${HOME}/.config/flux" ]; then
    echo "Configuration directory exists."
else
    echo "Configuration directory does not exist. Installation failed."
    exit 1
fi

echo "Checking installation directory..."
if [ -d "${HOME}/.local/share/flux" ]; then
    echo "Installation directory exists."
else
    echo "Installation directory does not exist. Installation failed."
    exit 1
fi

echo "All tools installed and working!"
# Exit code is automatically the script's exit code: 0 = success, nonzero = failure
exit 0
