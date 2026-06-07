export ZELLIJ_AUTO_EXIT=true
export PNPM_HOME=$HOME/.local/pnpm
export GO_HOME=$HOME/go/bin
MANUAL=$HOME/.local/bin
export PATH="$PATH:$PNPM_HOME:$GO_HOME:$MANUAL"
source <(zellij setup --generate-auto-start zsh)

EDITOR=nvim
PROMPT='%F{green}%n@%m%f:%F{blue}%1~%f %# '
export DO_NOT_TRACK=1
HOMEBREW_NO_AUTO_UPDATE=1
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export GPG_TTY=$(tty)
export TWS_NOTES="$HOME/Documents/Notes"

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt share_history
setopt append_history
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt globdots

eval "$(zoxide init zsh --no-cmd)"
alias z="__zoxide_z"
alias zi="__zoxide_zi"
alias rm="rip --graveyard ~/.local/share/trash"


export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

source <(fzf --zsh)
source <(COMPLETE=zsh jj)


# . "$HOME/.atuin/bin/env"
#
# eval "$(atuin init zsh)"
