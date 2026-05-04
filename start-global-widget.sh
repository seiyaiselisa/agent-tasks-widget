#!/bin/zsh
set -eu

cd -- "$(dirname "$0")"

PORT="${AGENT_TASKS_PORT:-8765}"
URL="http://127.0.0.1:${PORT}/"

if ! curl -fsS "${URL}" >/dev/null 2>&1; then
  python3 -m http.server "${PORT}" >/tmp/agent-tasks-widget-http.log 2>&1 &
fi

if [ ! -x build/AgentTasksPanel ]; then
  ./build-global-widget.sh
fi

./build/AgentTasksPanel "${URL}" >/tmp/agent-tasks-widget-panel.log 2>&1 &

echo "widget: ${URL}"
