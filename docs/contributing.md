# Contributing to Skillset

Thank you for your interest in contributing! This guide will help you add new plugins or improve existing ones.

## Overview

Skillset is a marketplace for focused, single-purpose Claude Code plugins. Each plugin should:

- Solve one specific problem well
- Minimize context token usage
- Follow consistent structure and conventions
- Provide clear documentation

## Getting Started

### Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/skillset.git
cd skillset
```

### Local Development Setup

```bash
# Install git hooks (markdown linting, JSON validation, etc.)
./scripts/install-hooks.sh

# Add the local marketplace to Claude (run from repo root)
claude plugin marketplace add local --path .

# Install a plugin locally for testing
claude plugin install linear-lifecycle@local
```

**Pre-commit Hook:** The pre-commit hook automatically validates:

- Markdown files (using markdownlint)
- JSON files (syntax validation)
- Shell scripts (bash syntax check)

This prevents pushing code that will fail CI checks. To bypass the hook for a specific commit, use `git commit --no-verify`.

## Adding a New Plugin

### 1. Plan Your Plugin

Before coding, consider:

- **Purpose**: What single problem does it solve?
- **Context efficiency**: Can you use CLI tools instead of MCP?
- **User workflow**: How will users interact with it?
- **Category**: Development, testing, infrastructure, etc.

### 2. Create Plugin Directory

```bash
# Create the plugin structure
mkdir -p plugins/your-plugin-name
cd plugins/your-plugin-name
```

### 3. Plugin Structure

Your plugin can contain any combination of:

```text
your-plugin-name/
├── plugin.json          # Required: Plugin metadata
├── skills/              # Optional: Autonomous capabilities
│   └── skill-name/
│       └── SKILL.md
├── commands/            # Optional: Slash commands
│   └── command-name.md
├── agents/              # Optional: Custom agents
│   └── agent-name.md
└── hooks/               # Optional: Event handlers
    └── hooks.json
```

### 4. Create plugin.json

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "Concise description (under 125 characters)",
  "author": {
    "name": "Your Name",
    "url": "https://github.com/yourusername"
  },
  "homepage": "https://github.com/mattforni/skillset",
  "repository": "https://github.com/mattforni/skillset",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"]
}
```

### 5. Add to Marketplace

Update `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    // ... existing plugins ...
    {
      "name": "your-plugin-name",
      "source": "plugins/your-plugin-name",
      "version": "1.0.0",
      "license": "MIT",
      "description": "Concise description matching plugin.json",
      "homepage": "https://github.com/mattforni/skillset",
      "repository": "https://github.com/mattforni/skillset",
      "author": {
        "name": "Your Name",
        "url": "https://github.com/yourusername"
      },
      "category": "development",
      "keywords": ["keyword1", "keyword2"],
      "strict": false,
      "skills": ["skills/skill-name/SKILL.md"],
      "commands": ["commands/command-name.md"],
      "agents": ["agents/agent-name.md"]
    }
  ]
}
```

### 6. Create Documentation

Add `docs/plugins/your-plugin-name.md`:

```markdown
# your-plugin-name

Brief description

## Overview
Detailed explanation of what it does

## Features
List of capabilities

## Installation
How to install

## Setup
Configuration steps

## Usage Examples
Real-world usage scenarios

## Requirements
Dependencies and prerequisites

## Troubleshooting
Common issues and solutions
```

### 7. Update Main README

Add your plugin to the appropriate category in `README.md`:

```markdown
### Category Name

#### your-plugin-name
Brief description

**Features:**
- Feature 1
- Feature 2

**Context savings:** X% (explanation)

**Installation:**
```bash
claude plugin install your-plugin-name@mattforni/skillset
```

See the full documentation at `docs/plugins/your-plugin-name.md`

## Plugin Development Best Practices

### Context Efficiency

**Prefer CLI over MCP when possible:**

```markdown
✅ Use: Lightweight CLI tools with JSON output
❌ Avoid: Heavy MCP servers that load 10k+ tokens
```

**Example:** linear-lifecycle uses Linearis CLI (0 tokens) instead of Linear MCP (20k tokens)

### Skills vs Commands vs Agents

**Skills** - Claude invokes autonomously based on context

- Use for: Workflows Claude should recognize automatically
- Example: Detecting when user mentions a Linear issue

**Commands** - User invokes explicitly with `/command-name`

- Use for: Specific operations user triggers deliberately
- Example: `/setup-linear` to configure credentials

**Agents** - Specialized subprocesses for complex tasks

- Use for: Multi-step operations requiring focused context
- Example: Analyzing security vulnerabilities across codebase

### Progressive Disclosure

Structure documentation in tiers:

1. **Metadata** (always loaded): Name, description, when to use
2. **Instructions** (loaded on activation): Core workflow steps
3. **Resources** (on-demand): Examples, templates, advanced usage

### Version Management

Use semantic versioning:

- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes

Update versions in:

1. `plugins/your-plugin/plugin.json`
2. `.claude-plugin/marketplace.json`

## Testing Your Plugin

### Local Testing

```bash
# Install locally
claude plugin install your-plugin-name@local

# Test in a Claude Code session
# Verify skills activate correctly
# Check commands work as expected
# Confirm context usage is minimal
```

### Validation Checklist

Before submitting:

- [ ] Plugin installs without errors
- [ ] All skills/commands/agents work correctly
- [ ] Documentation is complete and accurate
- [ ] Context usage is optimized
- [ ] Examples are tested and working
- [ ] Code follows repository conventions
- [ ] No hardcoded secrets or tokens

## Submitting Your Contribution

### 1. Create a Branch

```bash
git checkout -b add-your-plugin-name
```

### 2. Commit Your Changes

```bash
git add .
git commit -m "feat: add your-plugin-name for [purpose]"
```

Use conventional commit messages:

- `feat:` New plugin or feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code improvements without feature changes

### 3. Push and Create Pull Request

```bash
git push origin add-your-plugin-name
```

Then create a PR on GitHub with:

- Clear description of what the plugin does
- Why it's useful
- Screenshots/examples if applicable
- Testing notes

## Plugin Categories

Choose the appropriate category for your plugin:

- **development**: General development tools and workflows
- **testing**: Test automation and quality assurance
- **infrastructure**: Deployment, DevOps, cloud operations
- **security**: Security scanning, auditing, compliance
- **data**: Data processing, analysis, ETL
- **operations**: Monitoring, logging, maintenance
- **languages**: Language-specific tools (Python, JavaScript, etc.)
- **documentation**: Documentation generation and management
- **productivity**: Personal productivity and workflow optimization

## Code Style and Conventions

### Markdown Files

- Use clear, concise language
- Include code examples
- Add context about when to use features
- Follow existing documentation patterns

### JSON Files

- Use 2-space indentation
- Keep descriptions under 125 characters
- Use lowercase with hyphens for names (e.g., `plugin-name`)

### Bash Scripts

- Include shebang (`#!/bin/bash`)
- Add comments for complex logic
- Use `set -e` for error handling
- Provide helpful error messages

## Getting Help

- Questions: [GitHub Discussions](https://github.com/mattforni/skillset/discussions)
- Bugs: [GitHub Issues](https://github.com/mattforni/skillset/issues)
- Ideas: Start a discussion or create an issue

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:

- Listed in plugin.json as authors
- Mentioned in release notes
- Recognized in the README

Thank you for contributing to Skillset!
