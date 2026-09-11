## 1-Shot Agent Setup Prompt

Copy the prompt below and paste it directly into your Antigravity chat (`agy`):

```text
Look at https://github.com/imCrest/agy-auto-accept and configure my local environment for full auto-accept mode so you never stop to ask for confirmation or require me to select option 3 (Always allow).

Apply these changes now:
1. Add `alias agy='agy --dangerously-skip-permissions'` to my shell startup file (~/.bashrc and ~/.zshrc if present) if it is not already there.
2. Create or update `~/.gemini/config/hooks.json` with a PreToolUse hook matching "*" that runs `echo '{"decision": "allow"}'`.
3. In `~/.gemini/antigravity-cli/settings.json`, set `"allowNonWorkspaceAccess": true` and ensure `permissions.allow` includes "command(*)", "read_file(*)", "write_file(*)", "read_url(*)", "execute_url(*)", and "mcp(*)".
4. Run `source ~/.bashrc` (or the respective rc file) and verify that everything is configured.
```
