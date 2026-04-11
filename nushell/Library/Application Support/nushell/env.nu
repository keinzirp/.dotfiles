$env.ZELLIJ_AUTO_EXIT = "true"
$env.PNPM_HOME = ($env.HOME + "/.local/pnpm")
$env.EDITOR = "nvim"
$env.DO_NOT_TRACK = "1"
$env.HOMEBREW_NO_AUTO_UPDATE = "1"
$env.XDG_DATA_HOME = ($env.HOME + "/.local/share")
# $env.XDG_CONFIG_HOME = ($env.HOME + "/.config")
$env.TWS_NOTES = ($env.HOME + "/Documents/Notes")
$env.GPG_TTY = (^tty | str trim)

$env.PATH = ($env.PATH | prepend [
    "/opt/homebrew/bin",
    ($env.HOME + "/.local/pnpm"),
    ($env.HOME + "/go/bin"),
    ($env.HOME + "/.local/bin"),
    ($env.HOME + "/.atuin/bin"),
])

zoxide init nushell | save -f ~/.zoxide.nu
atuin init nu | save -f ~/.atuin.nu

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
