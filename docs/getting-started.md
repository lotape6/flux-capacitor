# Getting Started with Flux Capacitor

This guide will help you get up and running with Flux Capacitor.

## Prerequisites

- Git
- Curl
- Bash

## Installation

```bash
# Clone the repository
git clone https://github.com/lotape6/flux-capacitor.git
cd flux-capacitor

# Run the installation script
./install.sh
```

The installation script (`install.sh`) will:
1. Check for required dependencies
2. Create necessary directories for configuration and installation
3. Copy configuration files and installation files

You can customize the installation using these options:

| Option | Description |
|--------|-------------|
| `-v` | Enable VERBOSE_MODE output |
| `-c <path>` | Override default config directory (default: `$HOME/.config/flux`) |
| `-i <path>` | Override default installation directory (default: `$HOME/.local/share/flux`) |
| `-h` | Show help message |

Examples:
```bash
# Install with VERBOSE_MODE output
./install.sh -v

# Install with custom directories
./install.sh -c ~/custom-config -i ~/custom-install

# Show help message
./install.sh -h
```

If any required dependencies are missing, the installation will display error messages and exit.

## Uninstallation

To remove Flux Capacitor from your system, use the uninstall script:

```bash
./uninstall.sh
```

By default, the uninstallation script will:
1. Ask for confirmation before proceeding
2. Remove the installation directory completely
3. Prompt whether to remove configuration files
4. Create a backup of configuration files if you choose to delete them

You can customize the uninstallation using these options:

| Option | Description |
|--------|-------------|
| `-v` | Enable VERBOSE_MODE output |
| `-f` | Force removal without prompts |
| `-c <path>` | Override default config directory (default: `$HOME/.config/flux`) |
| `-i <path>` | Override default installation directory (default: `$HOME/.local/share/flux`) |
| `-h` | Show help message |

Examples:
```bash
# Uninstall with VERBOSE_MODE output
./uninstall.sh -v

# Force uninstall without confirmation prompts
./uninstall.sh -f

# Uninstall from custom directories
./uninstall.sh -c ~/custom-config -i ~/custom-install
```

**Note**: Using the `-f` flag will remove configuration files without confirmation. Without this flag, you'll be prompted to choose whether to remove configuration files or keep them.

## Basic Usage

After installation, you can start using Flux Capacitor:

```bash
# Coming soon
```

## Configuration

Edit your configuration in `$HOME/.config/flux/flux.conf` to customize your experience.

## Troubleshooting

If you encounter issues, check the following:

1. Ensure all dependencies are installed
2. Verify your configuration file is properly formatted
3. Check system compatibility

For more help, consult the full documentation or open an issue on GitHub.