#compdef flux
# flux-completion.zsh - ZSH completion for flux command

_flux() {
    local state line curcontext="$curcontext"
    local -a commands connect_options
    
    commands=(
        'connect:Create a new tmux session'
        'launch:Check if a file is a valid YAML'
        'clean:Reset the tmux server'
        'help:Show help message'
    )
    
    connect_options=(
        '-p:Pre-command to run:_command_names -e'
        '--pre-cmd:Pre-command to run:_command_names -e'
        '-P:Post-command to run:_command_names -e'
        '--post-cmd:Post-command to run:_command_names -e'
        '-n:Session name:_directories'
        '--session-name:Session name:_directories'
    )
    
    _arguments -C \
        '1: :->command' \
        '*:: :->args'
    
    case $state in
        command)
            _describe 'command' commands
            ;;
        args)
            case $line[1] in
                connect)
                    _arguments \
                        ${connect_options[@]} \
                        '*:directory:_directories'
                    ;;
                launch)
                    if (( $+commands[fzf] )); then
                        # Use fzf for interactive file selection
                        _arguments '*:yaml file:_flux_yaml_files_fzf'
                    else
                        # Regular file completion with filter for yaml files
                        _arguments '*:yaml file:_flux_yaml_files'
                    fi
                    ;;
                clean)
                    _message "No arguments for clean command"
                    ;;
                help)
                    _message "No arguments for help command"
                    ;;
            esac
            ;;
    esac
}

# Function to list YAML files using fzf
_flux_yaml_files_fzf() {
    local files
    files=($(find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | sort))
    
    if [[ ${#files} -eq 0 ]]; then
        _message "No YAML files found"
        return 1
    fi
    
    local selected
    selected=$(print -l $files | fzf --height 40% --reverse --multi --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}' --preview-window=right:60% --prompt="Select YAML files: ")
    
    if [[ -n "$selected" ]]; then
        reply=($selected)
        return 0
    fi
    
    return 1
}

# Function to list YAML files without fzf
_flux_yaml_files() {
    local files
    files=($(find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | sort))
    
    if [[ ${#files} -eq 0 ]]; then
        _message "No YAML files found"
        return 1
    fi
    
    _values 'yaml files' $files
}

# Oh-my-zsh integration (will be loaded if oh-my-zsh is installed)
if [[ -n "$ZSH_VERSION" && -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins" ]]; then
    # Create plugin directory if it doesn't exist
    mkdir -p "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/flux"
    
    # Create plugin file to be sourced by oh-my-zsh
    cat > "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/flux/flux.plugin.zsh" <<EOF
# flux plugin for oh-my-zsh

# Add flux to PATH if needed
if [[ -d "$FLUX_INSTALLATION_DIR" && ! "\$PATH" =~ "\$FLUX_INSTALLATION_DIR" ]]; then
    export PATH="\$PATH:\$FLUX_INSTALLATION_DIR"
fi

# Source completion script
[[ -f "$FLUX_INSTALLATION_DIR/completion/flux-completion.zsh" ]] && source "$FLUX_INSTALLATION_DIR/completion/flux-completion.zsh"

# Aliases
alias fcon='flux connect'
alias flc='flux launch'
alias fcl='flux clean'
EOF
    
    # Tell the user how to enable the plugin
    echo "Flux plugin installed for oh-my-zsh."
    echo "To enable it, add 'flux' to the plugins array in your ~/.zshrc file:"
    echo "plugins=(... flux ...)"
fi

# If not using the oh-my-zsh plugin, register the completion function
if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/flux" ]]; then
    _flux "$@"
fi