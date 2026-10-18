# dotfiles

- `xcode-select --install`
- `curl -fsSL https://mise.run | sh`
- `export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"`
- `git clone git@github.com:keinzirp/.dotfiles.git ~/.dotfiles`
- `cd ~/.dotfiles`
- `mise trust`
- `mise dot apply`
- `mise bootstrap`
- `exec nu`

- for full profile:
    - `printf 'env = ["full"]\n' > ~/.config/mise/miserc.local.toml`
    - `mise bootstrap`
