# Improvement Ideas

## Near Term

- Add a small settings popover for opacity, panel width, refresh interval, and YAML path.
- Make panel size persistent across restarts.
- Add status filters so completed tasks can be hidden.
- Add a compact mode that only shows agent, title, and status.
- Add a stale-task indicator when `updated` is old.

## Agent Integration

- Provide a small CLI such as `agent-tasks set --agent codex --status running --title ...` so agents do not need to edit YAML directly.
- Add file locking around writes to prevent Codex and Claude from overwriting each other.
- Add JSON output support for easier machine writes while keeping YAML as the human-facing format.
- Provide reusable snippets for `AGENTS.md` and `CLAUDE.md`.

## Reliability

- Replace the minimal YAML parser with a stricter parser or accept JSON as the canonical source.
- Add validation and show YAML errors with line numbers in the widget.
- Avoid port conflicts by probing for a free port and writing the selected port to a state file.
- Add a proper uninstall script that unloads LaunchAgent and removes generated files.

## UI

- Add agent icons or initials.
- Add task age and duration.
- Add click-to-copy task summary.
- Add opacity controls for overlay use.
- Add light theme support.

## Distribution

- Package a signed `.app`.
- Add GitHub Actions build checks.
- Add screenshots and a short demo GIF.
- Add a custom app icon and include generated `.icns` assets.
- Add a Homebrew tap or simple release archive.
