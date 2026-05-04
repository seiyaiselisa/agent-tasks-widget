# Usage

## Requirements

- macOS
- `python3`
- `swiftc`
- `curl`

The app uses the macOS system frameworks AppKit and WebKit. It does not require Electron or Node.js.

## Install

From the repository directory:

```sh
./install-to-home.sh
```

By default this installs the app and registers a LaunchAgent for login startup.

To install without login startup:

```sh
INSTALL_LAUNCH_AGENT=0 ./install-to-home.sh
```

## Start

```sh
open -a "$HOME/Applications/Agent Tasks.app"
```

The launcher starts a local server on port `8765` if one is not already running.

## Change Port

```sh
AGENT_TASKS_PORT=8766 open -a "$HOME/Applications/Agent Tasks.app"
```

For direct script usage:

```sh
AGENT_TASKS_PORT=8766 ./start-global-widget.sh
```

## Edit Tasks

Update:

```text
~/AgentTasksWidget/tasks.yaml
```

The widget refreshes every few seconds.

For a repository checkout, create a local task file from the example:

```sh
cp tasks.example.yaml tasks.yaml
```

## Font Size

Use `A-` and `A+` in the widget header. The value is saved in browser local storage for the widget.

## Panel Position

Use the `NW`, `NE`, `SW`, and `SE` buttons in the widget header to move the panel to a screen corner. The selected position is saved by the native panel app.

## Agent Colors

Cards are marked by agent:

- Codex: blue accent
- Claude: orange accent
- Unknown agent: purple accent

Status badges keep their own colors, so agent and task state can be read independently.

## Recommended Agent Instructions

Put this in `AGENTS.md` for Codex-style agents:

```text
When work starts, update ~/AgentTasksWidget/tasks.yaml with status "running".
If blocked, set status to "blocked" and explain the blocker in summary.
When done, set status to "done" and summarize the result.
Do not delete or overwrite other agents' tasks.
```

Put the same idea in `CLAUDE.md` for Claude:

```text
When Claude receives a task, update ~/AgentTasksWidget/tasks.yaml.
Use agent: "claude".
Preserve existing tasks from Codex or other agents.
```

## YAML Format

```yaml
updated: "YYYY-MM-DD HH:MM"
tasks:
  - agent: "codex"
    title: "Short task title"
    status: "running"
    summary: "One sentence status."
    since: "HH:MM"
    url: ""
```

## Troubleshooting

Check the local server:

```sh
curl -I http://127.0.0.1:8765/
```

Check LaunchAgent:

```sh
launchctl print "gui/$(id -u)/local.agent-tasks-widget"
```

Reload LaunchAgent:

```sh
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.agent-tasks-widget.plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.agent-tasks-widget.plist"
launchctl kickstart -k "gui/$(id -u)/local.agent-tasks-widget"
```

Logs:

```text
/tmp/agent-tasks-widget-http.log
/tmp/agent-tasks-widget-panel.log
/tmp/agent-tasks-widget-launchd.out.log
/tmp/agent-tasks-widget-launchd.err.log
```
