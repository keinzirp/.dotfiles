"""Run with python3 tests/kak_config.py; requires Kakoune and installed plugins."""

import os
from pathlib import Path
import subprocess
import tempfile


def kakquote(value):
    return "'" + str(value).replace("'", "''") + "'"


config = Path(__file__).resolve().parents[1] / "kak/.config/kak"
with tempfile.TemporaryDirectory(prefix="kak-check-") as tmp:
    root = Path(tmp).resolve()
    # Exercise first-run bootstrap offline, then ensure startup skips cloning.
    bootstrap = (config / "kakrc").read_text().split("nop %sh{\n", 1)[1].split("\n}", 1)[0]
    fresh = root / "fresh config"
    bootstrap_env = dict(os.environ, kak_config=str(fresh), GIT_CONFIG_COUNT="1",
        GIT_CONFIG_KEY_0=f"url.{(config / 'plugins/plug.kak').as_uri()}.insteadOf",
        GIT_CONFIG_VALUE_0="https://github.com/andreyorst/plug.kak.git")
    subprocess.run(["/bin/sh", "-c", bootstrap], env=bootstrap_env, check=True, timeout=20)
    assert (fresh / "plugins/plug.kak/rc/plug.kak").is_file()
    subprocess.run(["/bin/sh", "-c", bootstrap], env=dict(bootstrap_env, PATH=""), check=True, timeout=5)
    folder = root / "space ' quote $dollar; directory"
    folder.mkdir()
    sample = folder / "sample.nu"
    sample.write_text("let answer = 42\n")
    (root / ".editorconfig").write_text(
        "root = true\n[*]\nindent_style = space\nindent_size = 2\n"
    )
    repo = root / "git repo"
    repo.mkdir()
    tracked = repo / "tracked.txt"
    tracked.write_text("one\ntwo\nthree\n")
    subprocess.run(["git", "init", "-q", str(repo)], check=True)
    subprocess.run(["git", "-C", str(repo), "add", "tracked.txt"], check=True)
    tracked.write_text("one\nchanged\nthree\n")
    log = root / "debug"
    commands = f'''
define-command finish-check %{{ buffer *debug*; write {kakquote(log)}; quit! }}
try %{{
source "%val{{runtime}}/kakrc"
colorscheme base16-default-dark-treesitter
require-module fzf
require-module fzf-file
require-module fzf-grep
echo -debug "preview=%opt{{fzf_grep_preview_command}}"
# Stop the initial LSP session before stubbing requests to language servers.
lsp-exit
define-command -override lsp-send -params .. nop
define-command -override lsp-send-buffer -params 1 nop
edit {kakquote(sample)}
echo -debug "indent=%opt{{indentwidth}} smarttab=%opt{{smarttab_mode}}"
echo -debug "filetype=%opt{{filetype}} lsp=%opt{{lsp_fail_if_disabled}}"
echo -debug %opt{{lsp_servers}}
# Capture the item command instead of launching an interactive picker.
define-command -override fzf -params .. %{{ echo -debug "items=%arg{{7}}" }}
execute-keys -with-maps '<space>fF'
edit -scratch scratch
execute-keys -with-maps '<space>fF'
# Simulate an unavailable editorconfig CLI for both file hooks.
define-command -override editorconfig-load -params ..1 %{{ fail 'missing editorconfig' }}
edit {kakquote(root / 'new.txt')}
echo -debug "new-fallback=%opt{{smarttab_mode}}"
edit {kakquote(root / '.editorconfig')}
echo -debug "open-fallback=%opt{{smarttab_mode}}"
edit {kakquote(tracked)}
echo -debug "git-open=%opt{{git_diff_flags}}"
git next-hunk
echo -debug "git-next=%val{{cursor_line}}"
execute-keys '%cone<ret>two<ret>three<esc>'
write
echo -debug "git-save=%opt{{git_diff_flags}}"
set-option global autoreload yes
hook -once buffer BufReload .* %{{
    echo -debug "git-reload=%opt{{git_diff_flags}}"
    finish-check
}}
nop %sh{{ printf 'one\\nchanged\\nthree\\n' > "$kak_buffile" }}
}} catch %{{ echo -debug "error: %val{{error}}"; finish-check }}
'''
    env = dict(os.environ, KAKOUNE_CONFIG_DIR=str(config))
    result = subprocess.run(
        ["kak", "-n", "-ui", "dummy", "-e", commands],
        cwd=root, env=env, capture_output=True, text=True, timeout=20,
    )
    assert result.returncode == 0, result.stderr
    output = log.read_text()
    assert "error" not in output.lower(), output
    for expected in (
        "preview=bat", "indent=2 smarttab=expandtab", "filetype=nu lsp=nop",
        "[nu]", 'args = ["--lsp"]', "new-fallback=expandtab", "open-fallback=expandtab",
    ):
        assert expected in output, output
    git_results = dict(line.split("=", 1) for line in output.splitlines() if line.startswith("git-"))
    assert "2|" in git_results["git-open"], output
    assert git_results["git-next"] == "2", output
    assert "|" not in git_results["git-save"], output
    assert "2|" in git_results["git-reload"], output
    items = [line.removeprefix("items=") for line in output.splitlines() if line.startswith("items=")]
    assert len(items) == 2, output
    for command in items:
        files = subprocess.check_output(["sh", "-c", command], cwd=root, text=True).splitlines()
        assert sample in [(root / file).resolve() for file in files], files

print("Kakoune config checks passed")
