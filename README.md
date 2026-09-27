# dotfiles

Personal dotfiles.

## Configuration
- `stow --verbose --restow <path>`
- `stow --verbose --delete <path>`
- `~/.config/zellij/install-plugins.sh` after stowing `zellij` on a new machine
- `stow --verbose --restow --target /opt/homebrew homebrew` to install the local Homebrew tap
- Thanks jonhoo for the Firefox [userChrome.css](https://raw.githubusercontent.com/jonhoo/configs/refs/heads/master/gui/.mozilla/firefox/chrome/userChrome.css)
- `misc` is not a valid stow target
