#!/usr/bin/env bash
# flux-completion.bash - Bash completion for flux command

_flux_completions() {
    local cur prev commands connect_options
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="connect launch clean help"
    connect_options="-p --pre-cmd -P --post-cmd -n --session-name -e --env-file"

    # Handle subcommand completions
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
        return 0
    fi

    # Handle options for specific subcommands
    case "${COMP_WORDS[1]}" in
        connect)
            # If the previous word is an option that requires an argument
            if [[ "${prev}" == "-p" || "${prev}" == "--pre-cmd" || 
                  "${prev}" == "-P" || "${prev}" == "--post-cmd" || 
                  "${prev}" == "-n" || "${prev}" == "--session-name" ]]; then
                # In a real environment, we might suggest appropriate completions here
                COMPREPLY=()
            elif [[ "${prev}" == "-e" || "${prev}" == "--env-file" ]]; then
                # Suggest files for environment file option
                COMPREPLY=( $(compgen -f -- "${cur}") )
            # Otherwise, suggest options or directories
            elif [[ "${cur}" == -* ]]; then
                COMPREPLY=( $(compgen -W "${connect_options}" -- "${cur}") )
            else
                COMPREPLY=( $(compgen -d -- "${cur}") )
            fi
            return 0
            ;;
        launch)
            # Suggest YAML files for the launch command
            if [[ "${cur}" == -* ]]; then
                COMPREPLY=()
            else
                # Use find to locate yaml files if fzf is available
                if command -v fzf >/dev/null 2>&1; then
                    # When user presses Tab, a file selector will be shown with fzf
                    # We'll add a message to inform the user
                    echo -e "\nPress Tab again to see YAML files or enter path:"
                    # Use 'bat' for preview if available, otherwise fall back to cat
                    if command -v bat >/dev/null 2>&1; then
                        COMPREPLY=( $(find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | grep -i "${cur}" | sort | fzf --height 40% --reverse --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}' --preview-window=right:60% 2>/dev/null) )
                    else
                        COMPREPLY=( $(find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | grep -i "${cur}" | sort | fzf --height 40% --reverse 2>/dev/null) )
                    fi
                else
                    # Without fzf, use regular bash completion for files with yml or yaml extension
                    local yaml_files=$(find . -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | sed 's|^\./||' | grep -i "${cur}" | sort)
                    COMPREPLY=( $(compgen -W "${yaml_files}" -- "${cur}") )
                fi
            fi
            return 0
            ;;
        *)
            COMPREPLY=()
            return 0
            ;;
    esac
}

# Register the completion function
complete -F _flux_completions flux