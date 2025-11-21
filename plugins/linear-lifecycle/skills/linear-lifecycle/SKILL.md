---
name: linear-lifecycle
description: Use when working with Linear issues across development workflow - uses Linearis CLI with JSON output for zero-context issue management. Get details, create issues, update status, and add comments without consuming tokens in main session.
---

# Linear Lifecycle Management with Linearis CLI

## Overview

**Core principle:** Use Linearis CLI for all Linear operations instead of loading 20k token Linear MCP. CLI returns structured JSON for parsing without context overhead.

**Tool:** [Linearis](https://github.com/czottmann/linearis) - Linear CLI built for LLM agents with ~1000 token footprint vs 13k+ for MCP.

**Context savings:** 100% - no MCP loaded, just bash commands with JSON output.

## Setup (One Time)

**Automated setup (recommended):**

Use the `/linear-setup` command in Claude Code to run the setup interactively.

This script will:

1. Install Linearis CLI if not present
2. Prompt for your Linear API token
3. Save token to `~/.linear_api_token` (linearis standard location)
4. Verify connection to Linear API

**Manual setup:**

```bash
# 1. Install Linearis
npm install -g linearis

# 2. Save your token to ~/.linear_api_token
echo "lin_api_YOUR_TOKEN_HERE" > ~/.linear_api_token
chmod 600 ~/.linear_api_token
```

**Why ~/.linear_api_token:**

- Linearis automatically reads from this file (no environment variables needed)
- Global setup works for all projects
- Simple one time configuration
- File permissions protect your token (chmod 600)

## When to Use

**Use this pattern when:**

- Starting work on a Linear issue (need issue details)
- Creating new issues from bugs or features discovered
- Updating issue status during development
- Adding comments or progress updates
- Searching for issues across teams/projects

**Don't use when:**

- Issue tracking not needed for current work
- Working on non-Linear projects

## Implementation

Linearis automatically reads your token from `~/.linear_api_token`. No environment variable loading needed!

### Creating a New Issue

**IMPORTANT: Keep it simple! Specify the team key directly. Never use --labels or --priority.**

**User request:** "Create a Linear issue for fixing the avatar crop bug"

**Command:**

```bash
linearis issues create "Fix avatar crop bug" \
  --team BET \
  --description "Avatar images are cropping incorrectly on mobile devices. Need to adjust aspect ratio handling."
```

**Key rules:**

- ✅ Use `--team TEAM_KEY` (get from user's Linear workspace, e.g. BET, ENG, etc.)
- ✅ Keep description clear and concise
- ❌ NEVER use --labels (causes errors)
- ❌ NEVER use --priority (unnecessary)

**Parse response:**

```bash
# Returns JSON with: {identifier, title, url, ...}
# Extract: issue ID (e.g., BET-145) and URL
```

**Response to user:**

```markdown
✓ Created issue BET-145: Fix avatar crop bug
https://linear.app/your-workspace/issue/BET-145
```

### Starting Work on an Issue

**User request:** "Start working on bet-123"

**Command:**

```bash
linearis issues read BET-123
```

**Parse JSON response for:**

- title
- description
- state (current status)
- priority
- labels
- branchName (suggested git branch)

**Response to user:**

```markdown
Issue: BET-123 - [Title]
Status: [State]
Description: [Brief description]
Labels: [labels]
Branch: [branchName or generate from title]

Creating branch [branch-name]...
```

**Then create branch and proceed with development.**

### Updating Issue Status

**User request:** "Update bet-456 to in progress"

**Command:**

```bash
linearis issues update BET-456 --state "In Progress"
```

**Response:**

```markdown
✓ Updated BET-456 to In Progress
```

### Adding Comments

**User request:** "Add comment to bet-789 about the refactor being done"

**Command:**

```bash
linearis comments create BET-789 --body "Completed auth refactor. Moved from Context API to Zustand for better performance. All tests passing."
```

**Response:**

```markdown
✓ Added comment to BET-789
```

### Searching for Issues

**User request:** "Find all open bugs with label 'authentication'"

**Command:**

```bash
linearis issues search "authentication" --team "$LINEAR_TEAM_KEY" | jq '.[] | select(.labels[]? | contains("bug")) | {id: .identifier, title: .title, state: .state.name}'
```

**Parse and format results as table.**

### Completing Work

**User request:** "Close bet-789, PR merged"

**Commands:**

```bash
# 1. Add completion comment
linearis comments create BET-789 --body "Feature complete. PR #456 merged to main."

# 2. Update status to done
linearis issues update BET-789 --state "Done"
```

**Response:**

```markdown
✓ Marked BET-789 as Done
✓ Added completion comment
```

## Quick Reference

| Operation | Command Pattern |
|-----------|----------------|
| List recent issues | `linearis issues list -l 10` |
| Get issue details | `linearis issues read ABC-123` |
| Create issue | `linearis issues create "Title" --team TEAM_KEY --description "Description"` |
| Update status | `linearis issues update ABC-123 --state "In Progress"` |
| Add comment | `linearis comments create ABC-123 --body "Comment text"` |
| Search issues | `linearis issues search "query"` |

## Common Mistakes

**Not parsing JSON output**

- ❌ Don't show raw JSON to user
- ✅ Parse and format relevant fields cleanly

**Hardcoding team/project names**

- ❌ Don't assume team structure
- ✅ Let user specify or discover via linearis commands

**Using issue IDs incorrectly**

- ❌ Don't lowercase (bet-123) in commands
- ✅ Use proper case (BET-123) - linearis handles both but be consistent

## Real-World Impact

**Before (Linear MCP):**

- 20k tokens consumed at session start
- All tools loaded in context
- Context budget: 180k/200k remaining

**After (Linearis CLI):**

- 0 tokens in session (just bash commands)
- JSON parsing lightweight
- Context budget: 200k/200k remaining
- **100% context savings**

**Performance:**

- Linearis usage docs: ~1000 tokens
- MCP tool definitions: ~13000 tokens
- **92% reduction even for reference material**

## Advanced: Multi-Team Operations

**List issues across teams:**

```bash
linearis issues list --team Frontend -l 5
linearis issues list --team Backend -l 5
```

**Create issue in specific team:**

```bash
linearis issues create "Fix API timeout" --team Backend
```

**No workspace switching needed** - all commands accept `--team` flag for cross-team operations within same Linear workspace.
