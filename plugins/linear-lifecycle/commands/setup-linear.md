---
name: setup-linear
description: Configure Linear API token and team key for the linear-lifecycle plugin
---

Please run the Linear lifecycle setup script to configure this project for Linear integration.

The script will:

1. Install Linearis CLI if not present
2. Prompt for your Linear API token
3. Auto-detect your team key from Linear
4. Save configuration to `.env.local`
5. Add `.env.local` to `.gitignore`
6. Verify the connection

Run this command:

```bash
bash ~/.claude/plugins/cache/linear-lifecycle/skills/linear-lifecycle/scripts/setup.sh
```
