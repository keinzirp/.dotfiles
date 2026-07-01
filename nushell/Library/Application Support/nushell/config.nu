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

# Run once to register: plugin add ~/.cargo/bin/nu_plugin_polars
# plugin use polars

alias rm = rip --graveyard ~/.local/share/trash
alias tw = timew
alias backup = borgmatic --stats --progress --config ~/.config/borgmatic.d/removable.yaml
alias backup-t7 = borgmatic --config ~/.config/borgmatic.d/removable.yaml --repository T7 --verbosity 1 create --progress --stats
alias backup-t7-list = borgmatic --config ~/.config/borgmatic.d/removable.yaml --repository T7 --verbosity 1 create --stats --list

# until I can figure out why atuin doesn't new history logs properly.
source ~/.local/share/atuin/init.nu 
source $"($nu.cache-dir)/carapace.nu"

# Fall back to nushell's built-in file completer (which shows dotfiles) when
# carapace returns nothing. Tracks https://github.com/nushell/nushell/issues/14595.
let carapace_completer = $env.config.completions.external.completer
$env.config.completions.external.completer = {|spans|
    do $carapace_completer $spans | default [] | if ($in | is-empty) { null } else { $in }
}

source ~/.zoxide.nu

use "~/Library/Application Support/nushell/modules/jj-agents.nu" *

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

