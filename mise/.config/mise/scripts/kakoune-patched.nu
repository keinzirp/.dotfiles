#!/usr/bin/env nu

let prefix = $env.MISE_TOOL_INSTALL_PATH
mkdir ($prefix | path join "tmp")

do --capture-errors {
    cd ($prefix | path join $"kakoune-($env.MISE_TOOL_VERSION)")
    ^patch --batch --forward --fuzz=0 -p1 -i ($env.FILE_PWD | path join "../patches/kakoune-shifted-keys.patch" | path expand)
    ^make -j4 debug=yes
    ^./src/kak -n -ui dummy -e "quit!"
    with-env {TMPDIR: ($prefix | path join "tmp") XDG_RUNTIME_DIR: ""} {
        ^test/run ...[
            test/commands test/compose test/display test/highlight test/hooks test/indent
            test/normal test/prompt test/regression test/shell
            test/tools/autorestore test/tools/diff
        ]
    }
    ^make -j4 debug=no
    ^make install $"PREFIX=($prefix)"
    ^($prefix | path join "bin/kak") -n -ui dummy -e "quit!"
    cd $prefix
    ^rip $"kakoune-($env.MISE_TOOL_VERSION)" tmp
}
