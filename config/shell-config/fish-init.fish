# Flux-capacitor configuration
set -x FLUX_CONFIG_FILE "${CONFIG_FILE}"
set -x FLUX_ROOT "${FLUX_ROOT}"

# Add keybindings here
# Example: bind \\cg 'flux-command'

# Session switcher keybinding (Alt+S)
if test -f "${FLUX_ROOT}/src/session-switch-functions.sh"
    source "${FLUX_ROOT}/src/session-switch-functions.sh"
    bind \\es 'switch_session; commandline -f repaint'
end

# Create flux alias
if test -f "${FLUX_ROOT}/src/flux.sh"
    alias flux="${FLUX_ROOT}/src/flux.sh"
end

# Load flux command completion
if test -f "${FLUX_ROOT}/src/completion/flux-completion.fish"
    source "${FLUX_ROOT}/src/completion/flux-completion.fish"
end

# FZF initialization (if installed)
if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end