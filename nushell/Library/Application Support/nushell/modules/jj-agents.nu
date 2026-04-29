# jj-agents.nu — manage parallel Claude Code agents in jj workspaces
#
# Usage (after `use jj-agents.nu *`):
#   ja new <name> [--rev main] [--setup "..."]   Create a workspace + zellij tab + launch claude
#   ja list                                       Show all agent workspaces with their state
#   ja switch <name>                              Jump to that agent's zellij tab
#   ja drop <name> [--keep-files]                 Forget the workspace and close the tab
#   ja sync <name> [--rebase]                     Pull the agent's change into your main workspace
#   ja log                                        Show the change graph across all agents
#   ja status                                     One-line status of the current workspace
#
# Conventions:
#   - Workspaces live as sibling directories: ../<repo-name>-<agent-name>
#   - Each agent gets a jj workspace named "agent-<name>" and a zellij tab "🤖 <name>"
#   - The base repo must be initialized with `jj git init --colocate`

# ─── helpers (private to module) ───────────────────────────────────────────

# Resolve the main repo root.
def repo-root [] {
    let result = (jj workspace root | complete)
    if $result.exit_code != 0 {
        error make { msg: "Not inside a jj repo. Run `jj git init --colocate` first." }
    }
    $result.stdout | str trim
}

# Compute where a named agent's workspace directory should live.
def agent-dir [name: string] {
    let root = (repo-root)
    let parent = ($root | path dirname)
    let repo_name = ($root | path basename)
    $"($parent)/($repo_name)-($name)"
}

def workspace-name [name: string] { $"agent-($name)" }
def tab-name       [name: string] { $"🤖 ($name)" }

# Are we inside a zellij session? (zellij sets ZELLIJ when attached.)
def in-zellij [] {
    ($env.ZELLIJ? | default "" | is-not-empty)
}

# Does a zellij tab with this exact name exist in the current session?
# Uses `list-tabs --json` for a robust check rather than relying on go-to-tab-name silently.
def tab-exists [name: string] {
    if not (in-zellij) { return false }
    let result = (zellij action list-tabs --json | complete)
    if $result.exit_code != 0 { return false }
    let tabs = ($result.stdout | from json)
    ($tabs | any { |t| ($t.name? | default "") == $name })
}

# Get all agent workspaces as a structured table using a deterministic template.
# WorkspaceRef has .name(), .target() (Commit), .root() (path) — exposed as 0-arg keywords.
def list-workspaces [] {
    # Tab-separated: workspace_name<TAB>change_id<TAB>description<TAB>workspace_root
    let template = 'name ++ "\t" ++ target.change_id().short() ++ "\t" ++ target.description().first_line() ++ "\t" ++ root ++ "\n"'
    jj workspace list --template $template
    | lines
    | where { |l| ($l | str trim) != "" }
    | each { |line|
        let parts = ($line | split column "\t" ws change desc root | first)
        $parts
    }
}

# ─── public commands ───────────────────────────────────────────────────────

# Bare `ja` shows the overview. Nushell doesn't auto-route this; it's a
# real command that just delegates to `ja help`.
export def "ja" [] { ja help }

# Print the command overview.
export def "ja help" [] {
    print "jj-agents — parallel Claude Code agents in jj workspaces"
    print ""
    print "Setup:"
    print "  ja start                    Open the orchestrator + resume any prior agent tabs"
    print "  ja resume                   Respawn missing agent tabs with `claude --continue`"
    print ""
    print "Agent lifecycle:"
    print "  ja new <name> [--rev R] [--setup CMD] [--no-launch]"
    print "                              Spawn an agent: workspace + tab + claude"
    print "  ja switch <name>            Jump to that agent's zellij tab"
    print "  ja sync <name> [--rebase]   Pull agent's change into your main workspace"
    print "  ja drop <name> [--keep-files]"
    print "                              Forget workspace, trash dir, close tab"
    print "  ja quit [--keep-files]      Drop every agent and kill the zellij session"
    print ""
    print "Inspect:"
    print "  ja list                     Table of all workspaces (agent / change / path)"
    print "  ja log                      Change graph across all workspaces"
    print "  ja status                   One-line summary of the current workspace"
    print ""
    print "Pre-flight (target repo must be jj-colocated and have a `main` bookmark):"
    print "  jj git init --colocate"
    print "  jj bookmark create main -r @-"
}

# Respawn tabs for every agent workspace that doesn't currently have one.
# Each tab launches `claude --continue` so the prior conversation resumes.
# Falls back to a fresh `claude` when there's no session to continue (e.g.
# agents created via `ja new --no-launch`).
#
# Idempotent: if all tabs already exist, prints a one-liner and returns.
export def "ja resume" [] {
    if not (in-zellij) {
        error make { msg: "Not inside a zellij session. Run `ja start` instead." }
    }

    let agents = (
        list-workspaces
        | where { |row| ($row.ws | str starts-with "agent-") }
        | get ws
        | each { |ws| $ws | str replace "agent-" "" }
    )

    if ($agents | is-empty) { return }

    let missing = ($agents | where { |name| not (tab-exists (tab-name $name)) })

    if ($missing | is-empty) {
        print $"All ($agents | length) agent tab\(s\) already open."
        return
    }

    print $"Resuming ($missing | length) agent\(s\) with `claude --continue`: ($missing | str join ', ')"
    for name in $missing {
        let dir = (agent-dir $name)
        let tab = (tab-name $name)
        # Wrap in bash so we can fall back to fresh `claude` if --continue fails
        # (no prior session in that dir yet).
        zellij action new-tab --cwd $dir --name $tab -- bash -lc "claude --continue || claude"
    }
}

# Open the orchestrator and resume any prior agent tabs.
#   - outside zellij: launch a fresh session with the agents layout
#   - inside zellij:  ensure the mayor tab exists, then resurrect agent tabs
# Refuses outside a jj repo.
export def "ja start" [] {
    let jj_check = (jj workspace root | complete)
    if $jj_check.exit_code != 0 {
        error make { msg: "Not inside a jj repo. Run `jj git init --colocate` first." }
    }

    if not (in-zellij) {
        # The mayor pane's startup runs `ja resume` automatically once it spawns,
        # so agent tabs come back too.
        print "Launching zellij with the agents layout…"
        ^zellij --layout agents
        return
    }

    if (tab-exists "🎩 mayor") {
        print "Mayor tab already exists — switching to it."
        zellij action go-to-tab-name "🎩 mayor"
        # Mayor's already up; user likely wants closed agent tabs respawned.
        ja resume
    } else {
        print "Adding 🎩 mayor tab to current zellij session…"
        # The mayor pane's startup will call `ja resume` itself.
        zellij action new-tab --layout agents
    }
}

# Create a new agent workspace and launch Claude in a zellij tab.
export def "ja new" [
    name: string                  # short identifier (no spaces): auth, payments, tests
    --rev: string = "main"        # base revision to branch from
    --no-launch                   # create the workspace but don't start claude
    --setup: string = ""          # shell command to run in the workspace before claude (e.g. "npm install")
] {
    let dir = (agent-dir $name)
    let ws  = (workspace-name $name)
    let tab = (tab-name $name)

    if ($dir | path exists) {
        error make { msg: $"Workspace directory already exists: ($dir)" }
    }

    print $"Creating jj workspace ($ws) at ($dir) based on ($rev)…"
    # 🤖 prefix marks the change as agent-spawned — searchable in `jj log` and
    # leaves a breadcrumb for changes that originated through `ja new`.
    jj workspace add $dir --name $ws --revision $rev --message $"🤖 ($name): WIP"

    if ($setup | is-not-empty) {
        print $"Running setup: ($setup)"
        # Run setup in the new workspace dir. We use bash explicitly so users
        # can pass shell pipelines/&&/|| in --setup without quoting trouble.
        ^bash -lc $"cd ($dir | str replace --all "'" "'\\''") && ($setup)"
    }

    if $no_launch {
        print $"Workspace ready. cd ($dir) to start working."
        return
    }

    if (in-zellij) {
        print $"Launching claude in zellij tab '($tab)'…"
        # --cwd sets the new tab's working directory; everything after `--` is the command.
        zellij action new-tab --cwd $dir --name $tab -- claude
    } else {
        print "Not inside a zellij session — launching claude inline."
        cd $dir
        ^claude
    }
}

# List all agent workspaces with their current change state.
export def "ja list" [] {
    list-workspaces
    | each { |row|
        let is_agent = ($row.ws | str starts-with "agent-")
        let agent = (if $is_agent { $row.ws | str replace "agent-" "" } else { "(main)" })
        let dir   = (if $is_agent { agent-dir $agent } else { $row.root })
        let path_status = (
            if ($dir | path exists) { $dir }
            else { $"($dir) [MISSING]" }
        )
        {
            workspace: $row.ws,
            agent: $agent,
            change: $row.change,
            description: $row.desc,
            path: $path_status,
        }
    }
}

# Switch to an agent's zellij tab. Refuses if the workspace doesn't exist.
export def "ja switch" [name: string] {
    let dir = (agent-dir $name)
    let tab = (tab-name $name)

    if not ($dir | path exists) {
        error make { msg: $"No workspace for '($name)' at ($dir). Run `ja new ($name)` first." }
    }

    if (in-zellij) {
        if (tab-exists $tab) {
            zellij action go-to-tab-name $tab
        } else {
            print $"Workspace exists but no zellij tab '($tab)' is open."
            print $"  cd ($dir) && claude"
        }
    } else {
        print $"Not in zellij. Enter the workspace manually:"
        print $"  cd ($dir)"
    }
}

# Drop an agent: forget the jj workspace, remove its directory, close its zellij tab.
export def "ja drop" [
    name: string
    --keep-files               # forget the workspace but leave the directory on disk
] {
    let dir = (agent-dir $name)
    let ws  = (workspace-name $name)
    let tab = (tab-name $name)

    print $"Forgetting jj workspace ($ws)…"
    jj workspace forget $ws

    if not $keep_files {
        if ($dir | path exists) {
            print $"Removing directory ($dir)…"
            # `rm` is aliased to `rip`, which is recursive by default and trashes
            # rather than deletes — so a misfired `ja drop` is recoverable.
            rm $dir
        }
    }

    # Only touch zellij if we're inside it AND the tab actually exists.
    # Otherwise close-tab would close whichever tab we're currently on (footgun).
    if (in-zellij) and (tab-exists $tab) {
        print $"Closing zellij tab '($tab)'…"
        zellij action go-to-tab-name $tab
        zellij action close-tab
    }

    print $"Done."
}

# Tear down the whole orchestrator session: drop every agent, then kill zellij.
# Each agent's commits remain in jj history (workspace forget is reversible)
# and the directories go to trash via `rip`, so this is recoverable.
export def "ja quit" [
    --keep-files               # forget workspaces but leave directories on disk
] {
    let agents = (
        list-workspaces
        | where { |row| ($row.ws | str starts-with "agent-") }
        | get ws
        | each { |ws| $ws | str replace "agent-" "" }
    )

    if ($agents | is-empty) {
        print "No agents to drop."
    } else {
        print $"Dropping ($agents | length) agent\(s\): ($agents | str join ', ')"
        for agent in $agents {
            if $keep_files {
                ja drop $agent --keep-files
            } else {
                ja drop $agent
            }
        }
    }

    if (in-zellij) {
        let session = ($env.ZELLIJ_SESSION_NAME? | default "")
        if ($session | is-not-empty) {
            print $"Killing zellij session '($session)'…"
            zellij kill-session $session
        } else {
            print "Zellij session has no name — detach with Ctrl-o d and `zellij kill-session <name>`."
        }
    }
}

# Pull an agent's change back into your main workspace as a new revision.
export def "ja sync" [
    name: string
    --rebase                   # also rebase the agent's change onto main first
] {
    let ws = (workspace-name $name)

    let entry = (
        list-workspaces
        | where ws == $ws
    )

    if ($entry | is-empty) {
        error make { msg: $"No workspace named ($ws). Run `ja list` to see what's available." }
    }

    let change = ($entry | first | get change)
    print $"Agent ($name) is at change ($change)."

    if $rebase {
        print "Rebasing onto main…"
        jj rebase --revisions $change --onto main
    }

    print "Creating a new revision in your main workspace on top of the agent's work…"
    jj new $change
    print $"You're now editing on top of ($change)."
}

# Show the change graph for all working copies and what's not on main yet.
# `working_copies()` returns the working-copy commits of all workspaces.
# We add their ancestors back to (but not including) main, so you see the full picture.
export def "ja log" [] {
    jj log --revisions "working_copies() | (main..working_copies())" --limit 30
}

# One-line status of the current workspace — useful as a prompt segment.
export def "ja status" [] {
    let here = (jj workspace root | complete | get stdout | str trim)
    let info = (
        jj log --revisions @ --no-graph --no-pager --template 'change_id.short() ++ "\t" ++ description.first_line()'
        | complete | get stdout | str trim
    )
    let parts = ($info | split column "\t" change desc | first)
    # `desc` is missing when the commit has no description (str trim above ate the trailing tab).
    let desc = ($parts | get -o desc | default "")
    print $"[($here | path basename)] ($parts.change) ($desc)"
}
