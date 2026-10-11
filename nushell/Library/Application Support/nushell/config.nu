$env.ZELLIJ_AUTO_EXIT = "true"
$env.ZELLIJ_AUTO_ATTACH = false
$env.PNPM_HOME = ($env.HOME + "/.local/pnpm")
$env.EDITOR = "kak"
$env.DO_NOT_TRACK = "1"
$env.HOMEBREW_NO_AUTO_UPDATE = "1"
$env.XDG_DATA_HOME = ($env.HOME + "/.local/share")
$env.TWS_NOTES = ($env.HOME + "/Documents/Notes")
$env.CARAPACE_MATCH = 1
$env.CARAPACE_HIDDEN = 1
$env.CARAPACE_BRIDGES = 'zsh,bash'

$env.PATH = ($env.PATH | prepend [
    ($env.HOME + "/.cargo/bin"),
    ($env.HOME + "/.local/bin"),
    "/opt/homebrew/bin",
    ($env.HOME + "/.local/share/mise/shims"),
    $env.PNPM_HOME,
    ($env.HOME + "/go/bin"),
    ($env.HOME + "/Library/Application Support/carapace/bin"),
    ($env.HOME + "/.orbstack/bin"),
] | uniq)

$env.config.show_banner = false
$env.config.bracketed_paste = true
$env.config.shell_integration.osc133 = true
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.case_sensitive = false
$env.config.table.mode = "ascii_rounded"
$env.config.buffer_editor = "kak"
$env.config.rm.always_trash = true

const integrations = {
    atuin: [init nu]
    zoxide: [init nushell]
    carapace: [_carapace nushell]
    carapace-bridge: [_carapace nushell]
}
let integration_loader = ($nu.user-autoload-dirs | first | path join "dotfiles-integrations.nu")

def refresh-integrations [] {
    mkdir $nu.cache-dir ($integration_loader | path dirname)
    for integration in ($integrations | transpose tool args) {
        let result = (^($integration.tool) ...$integration.args | complete)
        if $result.exit_code != 0 {
            error make {msg: $"($integration.tool): ($result.stderr | str trim)"}
        }
        if not ($result.stdout | nu-check) {
            error make {msg: $"Invalid initialization script from ($integration.tool)"}
        }
        $result.stdout | save --force ($nu.cache-dir | path join $"($integration.tool).nu")
    }
    $integrations | columns
    | each { |tool| 'source ($nu.cache-dir | path join "' + $tool + '.nu")' }
    | append 'use ($nu.cache-dir | path join "mise.nu")'
    | str join (char nl)
    | save --force $integration_loader
}

alias backup = borgmatic --stats --progress --config ~/.config/borgmatic.d/removable.yaml
alias backup-t7 = borgmatic --config ~/.config/borgmatic.d/removable.yaml --repository T7 --verbosity 1 create --progress --stats
alias backup-t7-list = borgmatic --config ~/.config/borgmatic.d/removable.yaml --repository T7 --verbosity 1 create --stats --list

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != $env.PWD and ($cwd | path exists) {
        cd $cwd
    }
    rm -fp $tmp
}

def morning [] {
    print "==> mise and managed tools"
    try { mise self-update -y }
    try { mise upgrade -y }

    print ""
    print "==> rustup"
    try { rustup update }

    print ""
    print "==> pi (all)"
    try { pi update --all }

    print ""
    print "==> kak (plug.kak)"
    try { kak -ui dummy -e 'set-option global plug_block_ui true; plug-update; quit!' }

    refresh-integrations
}

def fg [] {
    let jobs = job list
    if ($jobs | is-empty) {
        print "no jobs"
        return
    }
    $jobs | first | get id | job unfreeze
}

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
    $env.GPG_TTY = (^tty | str trim)
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

if not ($integration_loader | path exists) or ($integrations | columns | any { |tool|
    not (($nu.cache-dir | path join $"($tool).nu") | path exists)
}) {
    refresh-integrations
}
^mise activate nu | save --force ($nu.cache-dir | path join "mise.nu")

if $nu.is-interactive and not ("ZELLIJ" in $env) {
    if (($env | get -o ZELLIJ_AUTO_ATTACH | default "false") == "true") {
        ^zellij attach -c
    } else {
        ^zellij
    }
    if $env.ZELLIJ_AUTO_EXIT == "true" {
        exit
    }
}
