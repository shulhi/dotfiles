# Managed by mise bootstrap: expose tools in non-interactive Fish too.
fish_add_path -gm "$HOME/.local/bin"
if test -x "$HOME/.local/bin/mise"
    "$HOME/.local/bin/mise" activate fish --shims | source
else if type -q mise
    mise activate fish --shims | source
end
