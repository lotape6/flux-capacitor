#!/usr/bin/env bash
# Test_DefaultInstallation.sh
# Test default installation and uninstallation

set -e

echo "Running default installation test..."

# Define installation directory (default location)
INSTALL_DIR="$HOME/.local/share/flux-capacitor"
CONFIG_DIR="$HOME/.config/flux-capacitor"

# Run installation script with output redirected to capture any messages
INSTALL_OUTPUT=$(./install.sh 2>&1)

# Check if installation script produced any output - it should be empty
if [ -n "$INSTALL_OUTPUT" ]; then
    echo "ERROR: Installation produced output when it should be silent:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Check if files were properly installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo "ERROR: Installation directory was not created: $INSTALL_DIR"
    exit 1
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "ERROR: Configuration directory was not created: $CONFIG_DIR"
    exit 1
fi

# Check for essential files (adjust these based on actual expected files)
if [ ! -f "$CONFIG_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed"
    exit 1
fi

echo "Installation successful, now testing uninstallation..."

# Run uninstallation script and capture output
UNINSTALL_OUTPUT=$(./uninstall.sh 2>&1)

# Check if uninstallation script produced the expected confirmation messages
if [ -z "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Uninstallation did not produce confirmation messages"
    exit 1
fi

# Check if directories were properly removed
if [ -d "$INSTALL_DIR" ]; then
    echo "ERROR: Installation directory was not removed: $INSTALL_DIR"
    exit 1
fi

if [ -d "$CONFIG_DIR" ]; then
    echo "ERROR: Configuration directory was not removed: $CONFIG_DIR"
    exit 1
fi

echo "Default installation test completed successfully!"
exit 0