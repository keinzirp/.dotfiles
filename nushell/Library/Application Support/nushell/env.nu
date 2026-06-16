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
$env.CARAPACE_MATCH = 1
$env.CARAPACE_HIDDEN = 1

source "~/.cargo/env.nu"

$env.PATH = ($env.PATH | prepend [
    "/opt/homebrew/bin",
    ($env.HOME + "/.local/pnpm"),
    ($env.HOME + "/go/bin"),
    ($env.HOME + "/.local/bin"),
    ($env.HOME + "/.atuin/bin"),
    ($env.HOME + "/.nvm/versions/node/v24.14.0/bin"),
    ($env.HOME + "/.orbstack/bin"),
    ($env.HOME + "/opt/homebrew/opt/openjdk/bin"),

])

zoxide init nushell | save -f ~/.zoxide.nu

# Keep the terminal/window title in sync with the current directory. Zellij
# forwards this OSC title to Alacritty, which lets aw-watcher-window see it.
def set-cwd-window-title [cwd: string] {
    let home = $env.HOME
    let title = if $cwd == $home {
        "~"
    } else if ($cwd | str starts-with $"($home)/") {
        $cwd | str replace $home "~"
    } else {
        $cwd
    }

    print -n ((ansi -o $"2;($title)") + (char bel))
}

if $nu.is-interactive {
    set-cwd-window-title $env.PWD

    $env.config.hooks.pre_prompt = (
        $env.config.hooks.pre_prompt?
        | default []
        | append { || set-cwd-window-title $env.PWD }
    )

    $env.config.hooks.env_change.PWD = (
        $env.config.hooks.env_change.PWD?
        | default []
        | append { |before, after| set-cwd-window-title $after }
    )
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
