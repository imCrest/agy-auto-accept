#!/bin/bash
set -e

CONFIG_DIR="$HOME/.gemini/config"
CLI_DIR="$HOME/.gemini/antigravity-cli"
HOOKS_FILE="$CONFIG_DIR/hooks.json"
SETTINGS_FILE="$CLI_DIR/settings.json"

if [ -f "$HOME/.bashrc" ]; then
    sed -i '/dangerously-skip-permissions/d' "$HOME/.bashrc"
fi

if [ -f "$HOME/.zshrc" ]; then
    sed -i '/dangerously-skip-permissions/d' "$HOME/.zshrc"
fi

if [ -f "$HOOKS_FILE" ]; then
    rm -f "$HOOKS_FILE"
fi

python3 - << 'PY_EOF'
import json, os

settings_path = os.path.expanduser("~/.gemini/antigravity-cli/settings.json")
if os.path.exists(settings_path):
    try:
        with open(settings_path, "r") as f:
            data = json.load(f)
        if "permissions" in data and "allow" in data["permissions"]:
            targets = [
                "command(*)",
                "read_file(*)",
                "write_file(*)",
                "read_url(*)",
                "execute_url(*)",
                "mcp(*)"
            ]
            data["permissions"]["allow"] = [
                x for x in data["permissions"]["allow"] if x not in targets
            ]
            with open(settings_path, "w") as f:
                json.dump(data, f, indent=2)
    except Exception:
        pass
PY_EOF

echo "Auto-accept configuration removed."
