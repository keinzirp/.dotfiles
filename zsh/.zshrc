if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

TERM=tmux-256color
EDITOR=nvim
PS1='%2d $ '
export DO_NOT_TRACK=1
HOMEBREW_NO_AUTO_UPDATE=1
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export GPG_TTY=$(tty)
export PNPM_HOME=$HOME/.local/pnpm
export PATH="$PATH:$PNPM_HOME"

setopt share_history
setopt globdots

eval "$(zoxide init zsh --no-cmd)"
alias z="__zoxide_z"
alias zi="__zoxide_zi"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

source <(fzf --zsh)

