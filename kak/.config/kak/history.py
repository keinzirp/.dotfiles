"""Persist Kakoune prompt histories as data, merging concurrent sessions."""

import fcntl
import json
import os
from pathlib import Path
import shlex
import sys
import tempfile


REGISTERS = ("colon", "slash", "pipe")
path = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "kak/history.json"


def read_history():
    try:
        history = json.loads(path.read_text())
    except FileNotFoundError:
        return {}
    if not isinstance(history, dict) or any(
        not isinstance(history.get(reg, []), list)
        or any(not isinstance(item, str) for item in history.get(reg, []))
        for reg in REGISTERS
    ):
        raise ValueError(f"Invalid Kakoune history: {path}")
    return history


if sys.argv[1] == "load":
    history = read_history()
    for reg in REGISTERS:
        values = " ".join("'" + item.replace("'", "''") + "'" for item in history.get(reg, [])[:100])
        if values:
            print(f"set-register {reg} {values}")
elif sys.argv[1] == "save":
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    with os.fdopen(os.open(path.with_suffix(".lock"), os.O_CREAT | os.O_RDWR, 0o600), "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        history = read_history()
        for reg in REGISTERS:
            current = shlex.split(os.environ[f"kak_quoted_reg_{reg}"])
            history[reg] = list(dict.fromkeys(item for item in current + history.get(reg, []) if item))[:100]
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as output:
            temporary = Path(output.name)
            try:
                json.dump(history, output, ensure_ascii=False)
                output.flush()
                os.replace(temporary, path)
            finally:
                temporary.unlink(missing_ok=True)
