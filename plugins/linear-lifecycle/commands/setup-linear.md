---
name: setup-linear
description: Configure Linear API token and team key for the linear-lifecycle plugin
---

# Linear Lifecycle Setup

Run the setup script to configure Linear API credentials for this project.

**What this does:**

1. Installs Linearis CLI if not present
2. Prompts for your Linear API token
3. Auto-detects your team key from Linear
4. Saves both to `.env.local` in the current directory
5. Adds `.env.local` to `.gitignore`
6. Verifies connection to Linear API

**Execute the setup:**

Run the setup script from the plugin directory:

```bash
bash ~/.claude/plugins/cache/linear-lifecycle/skills/linear-lifecycle/scripts/setup.sh
```

The script will guide you through the configuration process interactively.
