# Shell Support

## Supported Shells

Flux Capacitor supports the following shells:

- bash
- zsh
- fish

These are the same shells that are supported by [fzf](https://github.com/junegunn/fzf) for shell integration.

## Shell Integration

When you install Flux Capacitor, the installation script will automatically detect your shell and add the necessary initialization code to your shell configuration file:

- bash: `~/.bashrc` or `~/.bash_profile`
- zsh: `~/.zshrc`
- fish: `~/.config/fish/config.fish`

## FZF Integration

If you have [fzf](https://github.com/junegunn/fzf) installed, Flux Capacitor will automatically set up fzf integration with the appropriate shell:

- bash: `eval "$(fzf --bash)"`
- zsh: `source <(fzf --zsh)`
- fish: `fzf --fish | source`

This provides key bindings and fuzzy completion for your shell.

## Command Completion

Flux Capacitor provides command completion for the `flux` command and all its subcommands in every supported shell. The completion scripts are automatically loaded during shell initialization.

- Bash completion supports completing commands and options
- Zsh completion provides detailed help for each command and option
- Fish completion integrates with the fish auto-suggestion system

For more details, see [AUTOCOMPLETION.md](AUTOCOMPLETION.md).

### Oh-My-Zsh Integration

For zsh users with Oh-My-Zsh, Flux Capacitor provides a custom plugin that can be enabled by adding `flux` to your plugins list in `~/.zshrc`.

## Configuration

The shell initialization adds the following environment variables:

```bash
# For bash/zsh
export FLUX_CONFIG_FILE="/path/to/config/file"
export FLUX_INSTALLATION_DIR="/path/to/installation"

# For fish
set -x FLUX_CONFIG_FILE "/path/to/config/file"
set -x FLUX_INSTALLATION_DIR "/path/to/installation"
```

## Custom Functions

If you want to add your own custom functions to Flux Capacitor, you can place them in the appropriate directory:

- bash/zsh: Create `.sh` files in the `functions/` directory
- fish: Create `.fish` files in the `functions/` directory

These will be automatically loaded by the shell initialization script.