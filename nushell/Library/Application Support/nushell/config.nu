$env.config.show_banner = false
# $env.config.edit_mode = "emacs"
$env.config.bracketed_paste = true
$env.config.shell_integration.osc133 = true
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.case_sensitive = false
$env.config.table.mode = "ascii_rounded"

# $env.config.history.max_size = 100_000
# $env.config.history.sync_on_enter = true
# $env.config.history.file_format = "sqlite"

alias rm = rip --graveyard ~/.local/share/trash

source $"($nu.cache-dir)/carapace.nu"
source ~/.zoxide.nu
source ~/.local/share/atuin/init.nu

def fg [] {
  let jobs = job list
  if ($jobs | is-empty) { 
      print "no jobs"
      return 
  }
  $jobs | first | get id | job unfreeze
}

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

