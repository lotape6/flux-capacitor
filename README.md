# Flux Capacitor
A learning project completely inspired by [sesh](https://github.com/joshmedeski/sesh) - Yet another collection of shell tools and configurations to throw your mouse through the window.

<p align="center">
  <img src="resources/flux.gif" alt="animated" />
</p>

## Build Status

| Workflow           | Status (master) |
|--------------------|-----------------|
| Basic Integration  | ![Basic Integration](https://github.com/lotape6/flux-capacitor/actions/workflows/BasicIntegration.yml/badge.svg?branch=master) |
| Daily Integration  | ![Daily Integration](https://github.com/lotape6/flux-capacitor/actions/workflows/DailyIntegration.yml/badge.svg?branch=master) |

## Table of Contents
- [Build Status](#build-status)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Quick Install](#quick-install)
  - [Post-Installation](#post-installation)
  - [Uninstall](#uninstall)
- [Overview](#overview)
  - [Features](#features)
- [Acknowledgments](#acknowledgments)
- [Configuration](#configuration)
  - [Basic Configuration](#basic-configuration)
  - [Advanced Options](#advanced-options)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
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
# Installation
git clone https://github.com/lotape6/flux-capacitor.git
cd flux-capacitor
./install.sh  
```

## Post-Installation
You can tune your flux-capacitor settings by modifying the configuration file.


<p align="center">
  <img src="resources/tune.gif" alt="post-installation"/>
</p>

```bash
nano ~/.config/flux/flux.conf
```
## Uninstall:

```bash
~/.local/share/flux/uninstall.sh 
```

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

<details>
<summary>🚀 Quick tmux session access</summary>

### Available Commands

| Command | Description |
|---------|-------------|
| `connect` | Create a new tmux session |
| `session-switch` | Interactive tmux session switcher |
| `launch` | Check if a file is a valid YAML |
| `clean` | Reset the tmux server |
| `help` | Show this help message |

### Additional Features

| Feature | Description | Status |
|---------|-------------|--------|
| completion | Command-line autocompletion | ❌ Not working |
| key-bindings | Custom keyboard shortcuts | ❌ Not working |

</details>

## Acknowledgments

🚀 **This project is completely inspired by [sesh](https://github.com/joshmedeski/sesh)** 🚀

Huge kudos to [@joshmedeski](https://github.com/joshmedeski), the creator of sesh, who already lives in the future! 🕰️ 

The aim of this project is to get used to AI copilot agents by replicating sesh functionality and later extending it. However, if you're looking for a production-ready session manager, **we highly recommend installing and using the original [sesh](https://github.com/joshmedeski/sesh) instead** - it's the real deal that this project aspires to be.

This Flux Capacitor is just our time machine to learn from the best! ⚡

## Configuration

### Basic Configuration
```bash
# Example configuration - coming soon!
cp config/flux.conf ~/.config/flux/
```

### Advanced Options

| Option | Description | Default |
| --- | --- | --- |
| `ENABLE_COLOR` | Enable colorized output | `true` |
| `VERBOSE_MODE` | Enable verbose logging | `true` |
| `CONFIG_DIR` | Configuration directory | `${HOME}/.config/flux` |
| `INSTALLATION_DIR` | Installation directory | `${HOME}/.local/share/flux` |
| `LOGS_DIR` | Logs directory | `${SCRIPT_DIR}/.logs` |
| `INSTALL_LOG` | Install log file | `${LOGS_DIR}/install_$(date +'%Y%m%d%H%M%S').log` |
| `UNINSTALL_LOG` | Uninstall log file | `${LOGS_DIR}/uninstall_$(date +'%Y%m%d%H%M%S').log` |
| `CUSTOM_TOOLS_PATH` | Custom tools path (optional) | - |
| `CUSTOM_CONFIG_PATH` | Custom config path (optional) | - |

<p align="center">
  <img src="https://media.giphy.com/media/xsF1FSDbjguis/giphy.gif" alt="configuration"/>
</p>

## Contributing

Found a bug? Think you can make this better? Well, hop in your DeLorean and contribute at 88mph! 

Whether you're a human developer with too much caffeine or an AI with excessive compute, we welcome your pull requests! Just remember:

* Bugs aren't features, they're time paradoxes waiting to be resolved
* Code doesn't have to be perfect, just 1.21 gigawatts better than before
* Even HAL 9000 had to start somewhere (though please don't lock us out of the airlock)

So go ahead, fork this repo faster than you can say "Great Scott!" and help us make terminal life so good, mice will become collectibles!

## Disclaimer

⚠️ **WARNING: USE AT YOUR OWN RISK!** ⚠️

This project was created with the help of AI code agents as a learning exercise, completely inspired by the amazing [sesh](https://github.com/joshmedeski/sesh) project. While it might make your terminal experience more efficient, it comes with absolutely no warranty or guarantees.

* This software is provided "as is" without warranty of any kind
* The author is not responsible for any damage, data loss, or spontaneous dance parties caused by using this software
* No time machines were harmed during the development of this project
* Never trust nobody, especially this disclaimer
* **For production use, please consider the original [sesh](https://github.com/joshmedeski/sesh) instead!**

<p align="center">
  <img src="https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif" alt="warning"/>
</p>


## References
- **[sesh](https://github.com/joshmedeski/sesh)** - The original and superior session manager that inspired this project
- [Modern Unix collection of alternative commands](https://github.com/ibraheemdev/modern-unix)


## ToDos

- [ ] Add bell ring after command termination mechanism:
  - [ ] Bell ring on after command execution
  - [ ] Keybinding for togling mechanism
- [ ] Add tmux-logging alike mechanism. 