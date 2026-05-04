#!/bin/zsh
set -eu

SOURCE_DIR="$(cd -- "$(dirname "$0")" && pwd)"
ROOT="$HOME/AgentTasksWidget"
APP_DIR="$HOME/Applications/Fujiko.app"
LEGACY_APP_DIR="$HOME/Applications/Agent Tasks.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/local.agent-tasks-widget.plist"
INSTALL_LAUNCH_AGENT="${INSTALL_LAUNCH_AGENT:-1}"

mkdir -p "$ROOT" "$MACOS_DIR" "$CONTENTS_DIR/Resources" "$HOME/Applications" "$HOME/Library/LaunchAgents"

if [ -d "$LEGACY_APP_DIR" ] && [ "$LEGACY_APP_DIR" != "$APP_DIR" ]; then
  rm -rf "$LEGACY_APP_DIR"
fi

copy_if_diff() {
  src="$1"; dst="$2"
  [ -f "$src" ] || return 0
  if [ "$src" = "$dst" ]; then return 0; fi
  cp "$src" "$dst"
}

copy_if_diff "$SOURCE_DIR/index.html" "$ROOT/index.html"
copy_if_diff "$SOURCE_DIR/README.md" "$ROOT/README.md"
copy_if_diff "$SOURCE_DIR/USAGE.md" "$ROOT/USAGE.md"
copy_if_diff "$SOURCE_DIR/IMPROVEMENTS.md" "$ROOT/IMPROVEMENTS.md"
copy_if_diff "$SOURCE_DIR/.gitignore" "$ROOT/.gitignore"
copy_if_diff "$SOURCE_DIR/tasks.example.yaml" "$ROOT/tasks.example.yaml"
copy_if_diff "$SOURCE_DIR/AGENTS.md" "$ROOT/AGENTS.md"
copy_if_diff "$SOURCE_DIR/CLAUDE.md" "$ROOT/CLAUDE.md"
copy_if_diff "$SOURCE_DIR/AgentTasksPanel.swift" "$ROOT/AgentTasksPanel.swift"
copy_if_diff "$SOURCE_DIR/build-global-widget.sh" "$ROOT/build-global-widget.sh"
copy_if_diff "$SOURCE_DIR/start-global-widget.sh" "$ROOT/start-global-widget.sh"
copy_if_diff "$SOURCE_DIR/install-to-home.sh" "$ROOT/install-to-home.sh"
copy_if_diff "$SOURCE_DIR/AgentTasks.icns" "$ROOT/AgentTasks.icns"
copy_if_diff "$SOURCE_DIR/image.png" "$ROOT/image.png"
chmod +x "$ROOT/build-global-widget.sh" "$ROOT/start-global-widget.sh"
chmod +x "$ROOT/install-to-home.sh"

if [ ! -f "$ROOT/tasks.yaml" ]; then
  if [ -f "$SOURCE_DIR/tasks.yaml" ]; then
    cp "$SOURCE_DIR/tasks.yaml" "$ROOT/tasks.yaml"
  else
    cp "$SOURCE_DIR/tasks.example.yaml" "$ROOT/tasks.yaml"
  fi
fi

(
  cd "$ROOT"
  ./build-global-widget.sh
)

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>AgentTasksLauncher</string>
  <key>CFBundleIdentifier</key>
  <string>local.agent-tasks-widget</string>
  <key>CFBundleName</key>
  <string>Fujiko</string>
  <key>CFBundleDisplayName</key>
  <string>Fujiko</string>
  <key>CFBundleIconFile</key>
  <string>AgentTasks.icns</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
PLIST

cat > "$MACOS_DIR/AgentTasksLauncher" <<'LAUNCHER'
#!/bin/zsh
set -eu

ROOT="$HOME/AgentTasksWidget"
PORT="${AGENT_TASKS_PORT:-8765}"
URL="http://127.0.0.1:${PORT}/"

if ! /usr/bin/curl -fsS "$URL" >/dev/null 2>&1; then
  cd "$ROOT"
  /usr/bin/python3 -m http.server "$PORT" >/tmp/agent-tasks-widget-http.log 2>&1 &
  sleep 0.4
fi

exec "$ROOT/build/AgentTasksPanel" "$URL"
LAUNCHER

chmod +x "$MACOS_DIR/AgentTasksLauncher"

if [ -f "$ROOT/AgentTasks.icns" ]; then
  cp "$ROOT/AgentTasks.icns" "$CONTENTS_DIR/Resources/AgentTasks.icns"
fi

if [ "$INSTALL_LAUNCH_AGENT" = "1" ]; then
  cat > "$LAUNCH_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.agent-tasks-widget</string>
  <key>ProgramArguments</key>
  <array>
    <string>$MACOS_DIR/AgentTasksLauncher</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/agent-tasks-widget-launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/agent-tasks-widget-launchd.err.log</string>
</dict>
</plist>
PLIST

  launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT"
  launchctl kickstart -k "gui/$(id -u)/local.agent-tasks-widget"
  echo "launch agent:   $LAUNCH_AGENT"
fi

echo "installed root: $ROOT"
echo "installed app:  $APP_DIR"
