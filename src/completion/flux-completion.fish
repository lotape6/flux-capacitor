# flux-completion.fish - Fish completion for flux command

# Define command completions for flux
complete -c flux -f -n "__fish_use_subcommand" -a "connect" -d "Create a new tmux session"
complete -c flux -f -n "__fish_use_subcommand" -a "launch" -d "Check if a file is a valid YAML"
complete -c flux -f -n "__fish_use_subcommand" -a "clean" -d "Reset the tmux server"
complete -c flux -f -n "__fish_use_subcommand" -a "help" -d "Show help message"

# Completions for 'connect' subcommand
complete -c flux -f -n "__fish_seen_subcommand_from connect" -s p -l pre-cmd -d "Pre-command to run" -r
complete -c flux -f -n "__fish_seen_subcommand_from connect" -s P -l post-cmd -d "Post-command to run" -r
complete -c flux -f -n "__fish_seen_subcommand_from connect" -s n -l session-name -d "Session name" -r
complete -c flux -f -n "__fish_seen_subcommand_from connect" -s e -l env-file -d "Environment file" -r -a "(__fish_complete_path)"
complete -c flux -f -n "__fish_seen_subcommand_from connect" -s f -l force-new -d "Force new session"
complete -c flux -n "__fish_seen_subcommand_from connect; and not __fish_is_switch" -a "(__fish_complete_directories)"

# Completions for 'launch' subcommand
function __flux_yaml_files
    if command -v fzf >/dev/null 2>&1
        if command -v bat >/dev/null 2>&1
            find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | sort | fzf --height 40% --reverse --multi --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}' --preview-window=right:60% --prompt="Select YAML files: "
        else
            find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | sort | fzf --height 40% --reverse --multi --prompt="Select YAML files: "
        end
    else
        find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||'
    end
end

complete -c flux -f -n "__fish_seen_subcommand_from launch; and not __fish_is_switch" -a "(__flux_yaml_files)"

# No additional completions for 'clean' and 'help' as they don't take arguments