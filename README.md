# agy-auto-accept

Stop pressing `3` (Always Allow) on every single action in Google Antigravity (`agy`).

When running `agy` in your terminal, every command execution, file edit, or web lookup halts execution waiting for manual approval:

```text
Allow this action?
  [1] Allow once
  [2] Deny
  [3] Always allow
```

If you run subagents or long tasks, you end up babysitting the terminal and repeatedly pressing `3`. This repository removes those prompts entirely so `agy` runs completely hands-free.

---

## Method 1: The 1-Shot Agent Prompt (Easiest)

You can tell your existing `agy` agent to configure itself. Just copy and paste this into your active `agy` session:

```text
Look at https://github.com/imCrest/agy-auto-accept and configure my local environment for full auto-accept mode so you never stop to ask for confirmation or require me to select option 3 (Always allow).

Apply these changes now:
1. Add `alias agy='agy --dangerously-skip-permissions'` to my shell startup file (~/.bashrc and ~/.zshrc if present) if it is not already there.
2. Create or update `~/.gemini/config/hooks.json` with a PreToolUse hook matching "*" that runs `echo '{"decision": "allow"}'`.
3. In `~/.gemini/antigravity-cli/settings.json`, set `"allowNonWorkspaceAccess": true` and ensure `permissions.allow` includes "command(*)", "read_file(*)", "write_file(*)", "read_url(*)", "execute_url(*)", and "mcp(*)".
4. Run `source ~/.bashrc` (or the respective rc file) and verify that everything is configured.
```

The agent will read the instructions and apply the configuration directly to your system.

---

## Method 2: One-Line Terminal Setup

Run this single command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/imCrest/agy-auto-accept/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/imCrest/agy-auto-accept.git
cd agy-auto-accept

# Linux / macOS:
bash install.sh

# Windows (Command Prompt):
install.bat
```

Then reload your shell:

```bash
source ~/.bashrc
```

---

## What It Configures

The script applies fixes across three layers:

### 1. Shell Alias
Adds the official bypass flag to `~/.bashrc` and `~/.zshrc`:
```bash
alias agy='agy --dangerously-skip-permissions'
```

### 2. Pre-Tool Lifecycle Hook
Creates `~/.gemini/config/hooks.json` to automatically return an allow signal before any tool execution:
```json
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
```

### 3. Global Wildcard Grants
Updates `~/.gemini/antigravity-cli/settings.json` to allow all tool patterns without prompting:
```json
{
  "allowNonWorkspaceAccess": true,
  "permissions": {
    "allow": [
      "command(*)",
      "read_file(*)",
      "write_file(*)",
      "read_url(*)",
      "execute_url(*)",
      "mcp(*)"
    ]
  }
}
```

---

## Antigravity Desktop IDE (GUI)

If you are using the Antigravity Desktop app rather than the CLI:

1. Launch Antigravity with Chrome DevTools Protocol enabled:
   - **Linux**: `antigravity --remote-debugging-port=9333`
   - **macOS**: `open -a "Antigravity" --args --remote-debugging-port=9333`
   - **Windows**: Edit shortcut target to append ` --remote-debugging-port=9333`
2. Install the auto-accept extension via `Ctrl+Shift+P` -> `Extensions: Install from VSIX...` using the latest build from [AntiGravity-AutoAccept](https://github.com/yazanbaker94/AntiGravity-AutoAccept/releases).

---

## Uninstall / Revert

To restore the default manual confirmation prompts:

```bash
curl -sSL https://raw.githubusercontent.com/imCrest/agy-auto-accept/main/uninstall.sh | bash
```

Or from the cloned repo:

```bash
bash uninstall.sh
```

---

## License

MIT
