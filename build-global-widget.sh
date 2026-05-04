#!/bin/zsh
set -eu

cd -- "$(dirname "$0")"
mkdir -p build

swiftc AgentTasksPanel.swift \
  -framework AppKit \
  -framework WebKit \
  -o build/AgentTasksPanel

echo "built: $(pwd)/build/AgentTasksPanel"
