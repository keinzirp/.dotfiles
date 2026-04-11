$env.ZELLIJ_AUTO_EXIT = "true"
$env.PNPM_HOME = ($env.HOME + "/.local/pnpm")
$env.EDITOR = "nvim"
$env.DO_NOT_TRACK = "1"
$env.HOMEBREW_NO_AUTO_UPDATE = "1"
$env.XDG_DATA_HOME = ($env.HOME + "/.local/share")
# $env.XDG_CONFIG_HOME = ($env.HOME + "/.config")
$env.TWS_NOTES = ($env.HOME + "/Documents/Notes")
$env.GPG_TTY = (^tty | str trim)
$env.config.buffer_editor = "/opt/homebrew/bin/nvim"
$env.ZELLIJ_AUTO_ATTACH = false
$env.config.rm.always_trash = true

source "~/.cargo/env.nu"

$env.PATH = ($env.PATH | prepend [
    "/opt/homebrew/bin",
    ($env.HOME + "/.local/pnpm"),
    ($env.HOME + "/go/bin"),
    ($env.HOME + "/.local/bin"),
    ($env.HOME + "/.atuin/bin"),
    ($env.HOME + "/.nvm/versions/node/v24.14.0/bin"),
])

zoxide init nushell | save -f ~/.zoxide.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
