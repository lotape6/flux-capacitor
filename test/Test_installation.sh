#!/usr/bin/env bash

set -e

echo "Running default installation ..."

CONFIG_FILE="$(./install/find-config.sh)"
# Source the configuration
source "${CONFIG_FILE}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Run installation script with VERBOSE_MODE flag
INSTALL_OUTPUT=$(${SCRIPT_DIR}/../install.sh)
echo $INSTALL_OUTPUT
# Check if installation script produced output with VERBOSE_MODE flag
if [ -z "$INSTALL_OUTPUT" ]; then
    echo "ERROR: VERBOSE_MODE installation produced no output when it should be VERBOSE_MODE"
    exit 1
fi

# Check if files were properly installed
if [ ! -d "${FLUX_INSTALLATION_DIR}" ]; then
    echo "ERROR: Installation directory was not created: ${FLUX_INSTALLATION_DIR}"
    exit 1
fi

if [ ! -d "${FLUX_CONFIG_DIR}" ]; then
    echo "ERROR: Configuration directory was not created: ${FLUX_CONFIG_DIR}"
    exit 1
fi

# Check for essential files (adjust these based on actual expected files)
if [ ! -f "$FLUX_CONFIG_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed"
    exit 1
fi

echo "Installation successful, now testing uninstallation with VERBOSE_MODE flag..."

# Run uninstallation script with -f
INSTALL_OUTPUT=$(${SCRIPT_DIR}/../uninstall.sh -q -f)

# Check if uninstallation script produced output with -f flag
if [ "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Uninstallation produced no output when it should be VERBOSE_MODE"
    exit 1
fi

# Check if directories were properly removed
if [ -d "$FLUX_INSTALLATION_DIR" ]; then
    echo "ERROR: Installation directory was not removed: $FLUX_INSTALLATION_DIR"
    exit 1
fi

if [ -d "$FLUX_CONFIG_DIR" ]; then
    echo "ERROR: Configuration directory was not removed: $FLUX_CONFIG_DIR"
    exit 1
fi

echo "Default installation test with VERBOSE_MODE flag completed successfully!"
exit 0