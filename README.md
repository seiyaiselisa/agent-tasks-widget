# Agent Tasks Widget

Agent Tasks Widget is a small macOS overlay for tracking work currently assigned to AI coding agents such as Codex and Claude.

It reads `tasks.yaml` through a local HTTP server, refreshes automatically, and displays the current tasks in a floating WebView panel that can stay visible across spaces.

## Features

- Lightweight static HTML widget
- Auto-refresh from `tasks.yaml`
- Floating macOS panel built with Swift, AppKit, and WebKit
- Optional login startup through LaunchAgent
- Font-size controls in the widget header
- Position controls for moving the panel to any screen corner
- Separate visual colors for Codex and Claude tasks
- No Electron dependency

## Quick Start

```sh
./install-to-home.sh
```

The installer creates:

```text
~/AgentTasksWidget
~/Applications/Agent Tasks.app
~/Library/LaunchAgents/local.agent-tasks-widget.plist
```

Open manually:

```sh
open -a "$HOME/Applications/Agent Tasks.app"
```

Browser preview:

```text
http://127.0.0.1:8765/
```

## Task File

Edit:

```text
~/AgentTasksWidget/tasks.yaml
```

Example:

```yaml
updated: "2026-05-04 16:30"
tasks:
  - agent: "codex"
    title: "Build task widget"
    status: "running"
    summary: "Preparing the widget for sharing."
    since: "16:30"
    url: ""
  - agent: "claude"
    title: "Review draft"
    status: "queued"
    summary: "Waiting for review."
    since: ""
    url: ""
```

For a fresh checkout, start from:

```sh
cp tasks.example.yaml tasks.yaml
```

Supported statuses:

- `running`
- `blocked`
- `done`
- `queued`

## Documentation

- [USAGE.md](USAGE.md): installation, daily usage, agent instructions, and troubleshooting
- [IMPROVEMENTS.md](IMPROVEMENTS.md): suggested next improvements
