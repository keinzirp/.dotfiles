typeset -U path
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/opt/homebrew/bin:$HOME/.local/share/mise/shims:$PATH:$HOME/.local/pnpm:$HOME/go/bin"
export XDG_CONFIG_HOME=$HOME/.config
eval "$(mise -C "$HOME" env -s zsh)"

PROMPT='%F{green}%n@%m%f:%F{blue}%1~%f %# '
export GPG_TTY=$(tty)

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt share_history
setopt append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt globdots

eval "$(zoxide init zsh --no-cmd)"
alias z="__zoxide_z"
alias zi="__zoxide_zi"
alias rm="rip --graveyard ~/.local/share/trash"


autoload -Uz compinit
compinit
source <(mise completion zsh)
source <(fzf --zsh)
source <(COMPLETE=zsh jj)

eval "$(mise activate zsh)"
source <(zellij setup --generate-auto-start zsh)
