# linear-lifecycle

Linear issue management using Linearis CLI with zero-context overhead.

## Overview

The `linear-lifecycle` plugin enables Claude to manage Linear issues efficiently without loading heavy MCP servers. Instead of consuming 20k tokens with Linear MCP tools, it uses the lightweight [Linearis CLI](https://github.com/czottmann/linearis) which returns structured JSON for parsing.

**Context savings: 100%** - No MCP loaded, just bash commands with JSON output.

## Features

### Zero Context Overhead

- Uses Linearis CLI instead of 20k token Linear MCP
- Returns structured JSON for parsing
- Saves ~92% of context even for reference material
- 200k/200k tokens remain available for actual work

### Complete Linear Workflow Integration

- Get issue details when starting work
- Create new issues from discovered bugs/features
- Update issue status during development
- Add comments and progress updates
- Search across teams and projects
- Close issues when work is complete

### Project-Local Configuration

- Each project has its own `.env.local` with workspace token
- No manual workspace switching needed
- Token auto-detected from current directory
- Never committed to git (auto-gitignored)
- Same pattern as other secrets (Supabase, etc.)

## Installation

```bash
# From the skillset marketplace
claude plugin install linear-lifecycle@mattforni/skillset

# Or directly from GitHub
claude plugin install linear-lifecycle@github:mattforni/skillset
```

## Setup

After installing the plugin, configure it for each project where you want Linear integration:

### Automated Setup (Recommended)

Run the setup command in Claude Code:

```
/setup-linear
```

This will:

1. Install Linearis CLI if not present
2. Prompt for your Linear API token
3. Auto-detect your team key from Linear
4. Save both to `.env.local` in your project
5. Add `.env.local` to `.gitignore`
6. Verify connection to Linear API

### Manual Setup

```bash
# 1. Install Linearis CLI globally
npm install -g linearis

# 2. Get your Linear API token
# Go to: Linear Settings → Security & Access → Personal API keys

# 3. Add to .env.local in your project
echo "LINEAR_API_TOKEN=lin_api_your_token_here" >> .env.local
echo "LINEAR_TEAM_KEY=your_team_key" >> .env.local

# 4. Ensure it's gitignored
echo ".env.local" >> .gitignore
```

## Usage Examples

Once installed and configured, Claude will automatically use the linear-lifecycle skill when appropriate:

### Start Work on an Issue

```
You: Start working on BET-123

Claude: Fetching issue details...

Issue: BET-123 - Implement dark mode toggle
Status: Todo
Description: Add dark mode toggle to settings page with persistent preference storage
Labels: feature, ui
Branch: bet-123-dark-mode-toggle

Creating branch bet-123-dark-mode-toggle...
```

### Create a New Issue

```
You: Create a Linear issue for fixing the avatar crop bug

Claude: ✓ Created issue BET-145: Fix avatar crop bug
https://linear.app/your-workspace/issue/BET-145

Avatar images are cropping incorrectly on mobile devices. Need to adjust aspect ratio handling.
```

### Update Issue Status

```
You: Update BET-456 to in progress

Claude: ✓ Updated BET-456 to In Progress
```

### Add Comments

```
You: Add comment to BET-789 about the refactor being done

Claude: ✓ Added comment to BET-789
"Completed auth refactor. Moved from Context API to Zustand for better performance. All tests passing."
```

### Search for Issues

```
You: Find all open bugs with label 'authentication'

Claude: Found 3 open authentication bugs:

| ID      | Title                          | State      |
|---------|--------------------------------|------------|
| BET-234 | Login fails on Safari          | In Progress|
| BET-267 | Token refresh not working      | Todo       |
| BET-289 | 2FA bypass vulnerability       | Todo       |
```

### Close Completed Work

```
You: Close BET-789, PR merged

Claude: ✓ Added completion comment to BET-789
✓ Marked BET-789 as Done

Feature complete. PR #456 merged to main.
```

## How It Works

The skill:

1. Sources `.env.local` to load `LINEAR_API_TOKEN` and `LINEAR_TEAM_KEY`
2. Executes Linearis CLI commands with appropriate flags
3. Parses JSON responses to extract relevant information
4. Formats results cleanly for the user
5. Never consumes context with MCP tool definitions

## Performance Comparison

### Before (Linear MCP)

- 20k tokens consumed at session start
- All tools loaded in context
- Context budget: 180k/200k remaining (10% overhead)

### After (Linearis CLI via this plugin)

- 0 tokens in session (just bash commands)
- JSON parsing lightweight (~100 tokens per operation)
- Context budget: 200k/200k remaining (0% overhead)
- **100% context savings**

## Requirements

- Claude Code (latest version)
- Node.js and npm (for installing Linearis CLI)
- Linear workspace with API access
- Git (for project management)

## Troubleshooting

### Token Not Found

If you see "LINEAR_API_TOKEN not found in .env.local":

1. Run the setup script from your project directory
2. Ensure `.env.local` exists and contains your token
3. Verify the token starts with `lin_api_`
4. Check that you're in the correct project directory

### Linearis Not Installed

```bash
npm install -g linearis
```

### Team Key Not Detected

If the auto-detection fails, manually add your team key:

```bash
echo "LINEAR_TEAM_KEY=YOUR_TEAM" >> .env.local
```

You can find your team key in Linear by looking at any issue URL:
`https://linear.app/YOUR_WORKSPACE/issue/TEAM-123` (TEAM is your team key)

## Integration with Other Tools

### GitHub Workflow

Use with PR creation workflows:

```
1. Start Linear issue (BET-123)
2. Create branch from issue
3. Make changes
4. Create PR with Linear issue reference
5. Update Linear issue when PR merges
```

### Commit Messages

The plugin encourages Linear issue references:

```bash
git commit -m "feat: add dark mode toggle [BET-123]"
```

## Privacy and Security

- API tokens stored locally in `.env.local`
- Never committed to git (auto-gitignored)
- No data sent to external services except Linear API
- Tokens never exposed in Claude's context

## Credits

- **Linearis CLI**: [github.com/czottmann/linearis](https://github.com/czottmann/linearis) by Carlo Zottmann
- **Plugin Author**: Matthew Fornaciari [@mattforni](https://github.com/mattforni)

## License

MIT License - see LICENSE for details

## Support

- Issues: [GitHub Issues](https://github.com/mattforni/skillset/issues)
- Discussions: [GitHub Discussions](https://github.com/mattforni/skillset/discussions)
