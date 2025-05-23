# Flux Capacitor
Yet another collection of shell tools and configurations to throw your mouse through the window.

<p align="center">
  <img src="resources/flux.gif" alt="animated" />
</p>

## Build Status

| Platform | Status |
| --- | --- |
| Ubuntu 22.04 | ![Build Status](https://github.com/lotape6/flux-capacitor/workflows/Basic%20Integration/badge.svg?branch=master) |
| macOS | ![Build Status](https://img.shields.io/badge/build-WIP-yellow) |
| Windows | ![Build Status](https://img.shields.io/badge/build-WIP-yellow) |

## Table of Contents
- [Installation](#installation)
- [Overview](#overview)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [TODOs](#todos)
- [References](#references)

## Installation

### Prerequisites
- Git
- Curl
- tmux
- fzf
- bat
- delta
- Basic willpower to continue using terminal

### Quick Install
```bash
# Soon there will be a fancy install.sh script. For now:
git clone https://github.com/lotape6/flux-capacitor.git
cd flux-capacitor
# More steps to come when the installation script exists!
```

<p align="center">
  <img src="https://media.giphy.com/media/3o7btNhMBytxAM6YBa/giphy.gif" alt="installing" width="300px"/>
</p>

## Overview

Flux Capacitor is a collection of terminal tools that will make your command-line experience so good you might actually throw your mouse out the window. Who needs point-and-click when you have keyboard shortcuts that require three hands?

### Features

<details>
<summary>⚡ Super Fast Navigation</summary>
<p align="center">
  <img src="https://media.giphy.com/media/3o7TKEP6YngkCKFofC/giphy.gif" alt="navigation demo" width="500px"/>
</p>
Coming soon: Navigate directories faster than light itself!
</details>

<details>
<summary>🔍 Enhanced Search</summary>
<p align="center">
  <img src="https://media.giphy.com/media/3orieS4jfHJaKwkeli/giphy.gif" alt="search demo" width="500px"/>
</p>
Coming soon: Find files you didn't even know you had!
</details>

<details>
<summary>🖥️ Terminal Customization</summary>
<p align="center">
  <img src="https://media.giphy.com/media/l3q2IYN87QjIg51kc/giphy.gif" alt="customization demo" width="500px"/>
</p>
Coming soon: Make your terminal so pretty you'll want to frame screenshots of it!
</details>

## Configuration

### Basic Configuration
```bash
# Example configuration - coming soon!
cp config/flux.conf ~/.config/flux/
```

### Advanced Options

| Option | Description | Default |
| --- | --- | --- |
| `FLUX_SPEED` | Controls the speed of operation (1-88) | `42` |
| `FLUX_THEME` | UI theme for the tools | `"neon"` |
| `FLUX_POWER` | Power level in gigawatts | `1.21` |

<p align="center">
  <img src="https://media.giphy.com/media/xsF1FSDbjguis/giphy.gif" alt="configuration" width="300px"/>
</p>

## Contributing

We welcome contributions to make Flux Capacitor even more awesome! 🚀

### Development Guidelines

- **Bash Scripting**: Follow our comprehensive [Bash Scripting Guidelines](docs/BASH_GUIDELINES.md) for writing maintainable and robust scripts
- **Documentation**: Keep docs up-to-date and write clear, helpful comments
- **Testing**: Test your changes before submitting (and maybe test them twice, just like the flux capacitor needs)
- **Style**: Maintain the existing humorous but helpful tone

### Guidelines for Code Agents

- PRs must include a detailed description of changes and rationale.
- All code must pass linting and tests.
- PRs should reference related issues or feature requests.
- Auto-generated code must be clearly marked.
- Large changes should be broken down into smaller PRs.

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/awesome-new-thing`
3. Read the [Bash Guidelines](docs/BASH_GUIDELINES.md) for coding standards
4. Make your changes (with great power comes great responsibility)
5. Test thoroughly with the existing test suite
6. Submit a pull request

Whether you're fixing bugs, adding features, or improving documentation, every contribution helps make terminal life better for everyone!

## Disclaimer

⚠️ **WARNING: USE AT YOUR OWN RISK!** ⚠️

This project was created with the help of AI code agents as a learning exercise. While it might make your terminal experience more efficient, it comes with absolutely no warranty or guarantees.

* This software is provided "as is" without warranty of any kind
* The author is not responsible for any damage, data loss, or spontaneous dance parties caused by using this software
* No time machines were harmed during the development of this project
* Never trust nobody, especially this disclaimer

<p align="center">
  <img src="https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif" alt="warning" width="300px"/>
</p>

## TODOs

- [ ] Refactor uninstall according to https://github.com/lotape6/flux-capacitor/blob/master/docs/BASH_GUIDELINES.md
- [ ] WIP

## References
- [Modern Unix collection of alternative commands](https://github.com/ibraheemdev/modern-unix)
