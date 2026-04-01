export ZELLIJ_AUTO_EXIT=true
source <(zellij setup --generate-auto-start zsh)

TERM=tmux-256color
EDITOR=nvim
PROMPT='%F{green}%n@%m%f:%F{blue}%1~%f %# '
export DO_NOT_TRACK=1
HOMEBREW_NO_AUTO_UPDATE=1
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export GPG_TTY=$(tty)
export PNPM_HOME=$HOME/.local/pnpm
export GO_HOME=$HOME/go/bin
MANUAL=$HOME/.local/bin
export TWS_NOTES="$HOME/Documents/Notes"
export PATH="$PATH:$PNPM_HOME:$GO_HOME:$MANUAL"

setopt share_history
setopt globdots

eval "$(zoxide init zsh --no-cmd)"
alias z="__zoxide_z"
alias zi="__zoxide_zi"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

source <(fzf --zsh)
