#!/usr/bin/env bash
# Test_CustomInstallation1.sh
# Test custom installation with different directories and force uninstallation

set -e

echo "Running custom installation test with different directories..."

# Define custom directories
CUSTOM_INSTALL_DIR="/tmp/flux-capacitor-install"
CUSTOM_CONFIG_DIR="/tmp/flux-capacitor-config"

# Run installation script with custom directories
INSTALL_OUTPUT=$(./install.sh -i "$CUSTOM_INSTALL_DIR" -c "$CUSTOM_CONFIG_DIR" 2>&1)

# Check if installation script produced any output - it should be empty
if [ -n "$INSTALL_OUTPUT" ]; then
    echo "ERROR: Installation produced output when it should be silent:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Check if files were properly installed in custom locations
if [ ! -d "$CUSTOM_INSTALL_DIR" ]; then
    echo "ERROR: Custom installation directory was not created: $CUSTOM_INSTALL_DIR"
    exit 1
fi

if [ ! -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "ERROR: Custom configuration directory was not created: $CUSTOM_CONFIG_DIR"
    exit 1
fi

# Check for essential files in custom locations
if [ ! -f "$CUSTOM_CONFIG_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed in custom location"
    exit 1
fi

echo "Custom installation successful, now testing uninstallation with force flag..."

# Run uninstallation script with force flag and custom directories
UNINSTALL_OUTPUT=$(./uninstall.sh -f -i "$CUSTOM_INSTALL_DIR" -c "$CUSTOM_CONFIG_DIR" 2>&1)

# Check if uninstallation script produced any output - it should be empty with -f
if [ -n "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Forced uninstallation produced output when it should be silent:"
    echo "$UNINSTALL_OUTPUT"
    exit 1
fi

# Check if directories were properly removed
if [ -d "$CUSTOM_INSTALL_DIR" ]; then
    echo "ERROR: Custom installation directory was not removed: $CUSTOM_INSTALL_DIR"
    exit 1
fi

if [ -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "ERROR: Custom configuration directory was not removed: $CUSTOM_CONFIG_DIR"
    exit 1
fi

echo "Custom installation test with force uninstallation completed successfully!"
exit 0