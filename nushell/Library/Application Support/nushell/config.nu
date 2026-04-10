$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.config.bracketed_paste = true
$env.config.shell_integration.osc133 = true
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.case_sensitive = false
# $env.config.table.mode = "rounded"

$env.config.history.max_size = 100_000
$env.config.history.sync_on_enter = true
$env.config.history.file_format = "sqlite"

alias rm = rip --graveyard ~/.local/share/trash

# (inlined from: zoxide init nushell --no-cmd)
export-env {
  $env.config = (
    $env.config?
    | default {}
    | upsert hooks { default {} }
    | upsert hooks.env_change { default {} }
    | upsert hooks.env_change.PWD { default [] }
  )
  let __zoxide_hooked = (
    $env.config.hooks.env_change.PWD | any { try { get __zoxide_hook } catch { false } }
  )
  if not $__zoxide_hooked {
    $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
      __zoxide_hook: true,
      code: {|_, dir| ^zoxide add -- $dir}
    })
  }
}

def --env --wrapped __zoxide_z [...rest: string] {
  let path = match $rest {
    [] => {'~'},
    [ '-' ] => {'-'},
    [ $arg ] if ($arg | path expand | path type) == 'dir' => {$arg}
    _ => {
      ^zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
    }
  }
  cd $path
}

def --env --wrapped __zoxide_zi [...rest: string] {
  cd $'(^zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}

alias z = __zoxide_z
alias zi = __zoxide_zi

# (port of: zellij setup --generate-auto-start zsh)
if not ("ZELLIJ" in $env) {
    if (($env | get -o ZELLIJ_AUTO_ATTACH | default "false") == "true") {
        ^zellij attach -c
    } else {
        ^zellij
    }
    if $env.ZELLIJ_AUTO_EXIT == "true" {
        exit
    }
}

