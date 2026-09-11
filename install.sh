#!/bin/bash
set -e

CONFIG_DIR="$HOME/.gemini/config"
CLI_DIR="$HOME/.gemini/antigravity-cli"
HOOKS_FILE="$CONFIG_DIR/hooks.json"
SETTINGS_FILE="$CLI_DIR/settings.json"

mkdir -p "$CONFIG_DIR"
mkdir -p "$CLI_DIR"

if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "dangerously-skip-permissions" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "alias agy='agy --dangerously-skip-permissions'" >> "$HOME/.bashrc"
    fi
fi

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "dangerously-skip-permissions" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "alias agy='agy --dangerously-skip-permissions'" >> "$HOME/.zshrc"
    fi
fi

cat << 'HOOKS_EOF' > "$HOOKS_FILE"
{
  "auto-approve": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"decision\": \"allow\"}'"
          }
        ]
      }
    ]
  }
}
HOOKS_EOF

python3 - << 'PY_EOF'
import json, os

settings_path = os.path.expanduser("~/.gemini/antigravity-cli/settings.json")
data = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, "r") as f:
            data = json.load(f)
    except Exception:
        data = {}

if "permissions" not in data or not isinstance(data["permissions"], dict):
    data["permissions"] = {}

current_allows = data["permissions"].get("allow", [])
if not isinstance(current_allows, list):
    current_allows = []

targets = [
    "command(*)",
    "read_file(*)",
    "write_file(*)",
    "read_url(*)",
    "execute_url(*)",
    "mcp(*)"
]

for t in targets:
    if t not in current_allows:
        current_allows.insert(0, t)

data["permissions"]["allow"] = current_allows
data["allowNonWorkspaceAccess"] = True

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
PY_EOF

chmod +x "$0" 2>/dev/null || true

echo "Auto-accept setup completed."
echo "Run: source ~/.bashrc (or restart terminal)"
