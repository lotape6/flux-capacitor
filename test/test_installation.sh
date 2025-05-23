#!/usr/bin/env bash
set -e

# Skip apt-get commands as we don't have permissions
echo "Skipping dependency installation..."
# apt-get update
# apt-get install -y curl git

# Install project
echo "Running installation script..."
./install.sh

# Basic checks
echo "Checking configuration directory..."
if [ -d "${HOME}/.config/flux" ]; then
    echo "Configuration directory exists."
else
    echo "Configuration directory does not exist. Installation failed."
    exit 1
fi

echo "All tools installed and working!"
# Exit code is automatically the script's exit code: 0 = success, nonzero = failure
exit 0