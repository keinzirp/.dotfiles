export const integrations = {
    atuin: [init nu]
    zoxide: [init nushell]
    carapace: [_carapace nushell]
}

export def refresh-integrations [] {
    let integration_loader = ($nu.user-autoload-dirs | first | path join "dotfiles-integrations.nu")
    mkdir $nu.cache-dir ($integration_loader | path dirname)
    for integration in ($integrations | transpose tool args) {
        let result = (^($integration.tool) ...$integration.args | complete)
        if $result.exit_code != 0 {
            error make {msg: $"($integration.tool): ($result.stderr | str trim)"}
        }
        let script = ($result.stdout | str replace --all '{|spans|' '{|place| let spans = $place.command;')
        if not ($script | nu-check) {
            error make {msg: $"Invalid initialization script from ($integration.tool)"}
        }
        $script | save --force ($nu.cache-dir | path join $"($integration.tool).nu")
    }
    $integrations | columns
    | each { |tool| 'source ($nu.cache-dir | path join "' + $tool + '.nu")' }
    | append 'use ($nu.cache-dir | path join "mise.nu")'
    | str join (char nl)
    | save --force $integration_loader
}
