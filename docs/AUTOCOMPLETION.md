# Autocompletion Support

Flux Capacitor provides autocompletion for the `flux` command and its subcommands in all supported shells (bash, zsh, and fish).

## Supported Features

- Completion for all main commands: `connect`, `launch`, `clean`, and `help`
- Completion for command options:
  - `connect`: `-p/--pre-cmd`, `-P/--post-cmd`, `-n/--session-name` and directory paths
  - `launch`: YAML file paths (with interactive selection via `fzf` when available)
- Special integration with oh-my-zsh for zsh users

## Installation

Autocompletion is automatically set up during the installation of Flux Capacitor. The installation script will:

1. Copy the completion scripts to the installation directory
2. Modify your shell's initialization file to source the appropriate completion script 

## Manual Setup

If you need to set up autocompletion manually, you can source the appropriate completion script for your shell:

### Bash

```bash
source /path/to/flux-installation-dir/completion/flux-completion.bash
```

### Zsh

```zsh
source /path/to/flux-installation-dir/completion/flux-completion.zsh
```

### Fish

```fish
source /path/to/flux-installation-dir/completion/flux-completion.fish
```

## Oh-My-Zsh Integration

For zsh users with Oh-My-Zsh, Flux Capacitor will automatically create a custom plugin in the Oh-My-Zsh plugins directory. To enable it:

1. Edit your `~/.zshrc` file
2. Find the `plugins=()` line
3. Add `flux` to the plugins list: `plugins=(... flux ...)`
4. Restart your shell or run `source ~/.zshrc`

The plugin provides:
- Command completion for flux and its subcommands
- Useful aliases:
  - `fcon` for `flux connect`
  - `flc` for `flux launch`
  - `fcl` for `flux clean`

## Using FZF for Enhanced Completion

When [fzf](https://github.com/junegunn/fzf) is installed, Flux Capacitor will use it to provide enhanced file completion for the `launch` command, allowing you to interactively select YAML files with a fuzzy finder.