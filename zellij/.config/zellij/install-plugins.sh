#!/usr/bin/env bash
set -euo pipefail

plugins_dir="${ZELLIJ_PLUGIN_DIR:-$HOME/.config/zellij/plugins}"
mkdir -p "$plugins_dir"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

install_new_tab_next_to_current() {
  local repo="https://github.com/vimkim/zellij-new-tab-next-to-current.git"
  local commit="f93dc91f8f69f3ddc7d123067722cb5715cb1ab3"
  local tmpdir
  local cargo_cmd=(cargo)
  local rustc_cmd=""

  need git

  if command -v rustup >/dev/null 2>&1; then
    local toolchain
    toolchain="$(rustup show active-toolchain | awk '{print $1}')"
    rustup target add --toolchain "$toolchain" wasm32-wasip1 >/dev/null
    cargo_cmd=(rustup run "$toolchain" cargo)
    rustc_cmd="$(rustup which --toolchain "$toolchain" rustc)"
  else
    need cargo
  fi

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  git clone --quiet --filter=blob:none "$repo" "$tmpdir/repo"
  git -C "$tmpdir/repo" fetch --quiet --depth 1 origin "$commit"
  git -C "$tmpdir/repo" checkout --quiet --detach "$commit"

  if [ -n "$rustc_cmd" ]; then
    RUSTC="$rustc_cmd" "${cargo_cmd[@]}" build --quiet --release --target wasm32-wasip1 --manifest-path "$tmpdir/repo/Cargo.toml"
  else
    "${cargo_cmd[@]}" build --quiet --release --target wasm32-wasip1 --manifest-path "$tmpdir/repo/Cargo.toml"
  fi

  install -m 644 \
    "$tmpdir/repo/target/wasm32-wasip1/release/zellij-new-tab-next-to-current.wasm" \
    "$plugins_dir/zellij-new-tab-next-to-current.wasm"

  echo "installed zellij-new-tab-next-to-current ${commit} -> $plugins_dir/zellij-new-tab-next-to-current.wasm"
}

install_new_tab_next_to_current
