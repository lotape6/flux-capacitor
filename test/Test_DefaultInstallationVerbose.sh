#!/usr/bin/env bash
# Test_DefaultInstallationVerbose.sh
# Test default installation and uninstallation with verbose flag

set -e

echo "Running default installation test with verbose flag..."

# Define installation directory (default location)
INSTALL_DIR="$HOME/.local/share/flux-capacitor"
CONFIG_DIR="$HOME/.config/flux-capacitor"

# Run installation script with verbose flag
INSTALL_OUTPUT=$(../install.sh -v 2>&1)

# Check if installation script produced output with verbose flag
if [ -z "$INSTALL_OUTPUT" ]; then
    echo "ERROR: Verbose installation produced no output when it should be verbose"
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

echo "Installation successful, now testing uninstallation with verbose flag..."

# Run uninstallation script with verbose flag
UNINSTALL_OUTPUT=$(../uninstall.sh -v 2>&1)

# Check if uninstallation script produced output with verbose flag
if [ -z "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Verbose uninstallation produced no output when it should be verbose"
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

echo "Default installation test with verbose flag completed successfully!"
exit 0