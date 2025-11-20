# Skillset - Claude Code Plugin Marketplace

A curated collection of Claude Code plugins for enhanced development workflows with zero context overhead.

## Overview

This marketplace provides focused, single-purpose plugins that extend Claude Code's capabilities without consuming excessive context. Each plugin follows Anthropic's best practices for efficiency and modularity.

**Philosophy:** Install only what you need. Each plugin is self-contained and optimized for minimal token usage.

## Available Plugins

### Development

#### linear-lifecycle

Linear issue management using Linearis CLI with zero-context overhead.

**Features:**

- Get issue details when starting work
- Create new issues from discovered bugs/features
- Update issue status during development
- Add comments and progress updates
- Search across teams and projects
- Close issues when work is complete

**Context savings:** 100% (uses CLI instead of 20k token MCP)

**Installation:**

```bash
claude plugin install linear-lifecycle@mattforni/skillset
```

[Full documentation →](docs/plugins/linear-lifecycle.md)

## Installation

### Install the Marketplace

Add this marketplace to Claude Code:

```bash
claude plugin marketplace add mattforni/skillset
```

### Install Individual Plugins

Once the marketplace is added, install specific plugins:

```bash
# Install linear-lifecycle
claude plugin install linear-lifecycle@mattforni/skillset

# Verify installation
claude plugin list
```

### Local Development

For testing or contributing:

```bash
# Clone the repository
git clone https://github.com/mattforni/skillset.git
cd skillset

# Install locally
claude plugin marketplace add local
claude plugin install linear-lifecycle@local
```

## Repository Structure

```
skillset/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace configuration
├── plugins/
│   └── linear-lifecycle/         # Individual plugin
│       ├── plugin.json           # Plugin metadata
│       └── skills/               # Plugin skills
│           └── linear-lifecycle/
│               ├── SKILL.md      # Skill documentation
│               └── scripts/      # Helper scripts
│                   └── setup.sh
├── docs/
│   ├── plugins/                  # Plugin documentation
│   └── contributing.md           # Contribution guidelines
├── .gitignore
├── LICENSE
└── README.md
```

## Plugin Categories

### Development

Tools and workflows for software development

**Current plugins:**

- linear-lifecycle (Issue tracking and project management)

**Coming soon:**

- github-workflow (PR management without MCP overhead)
- notion-lifecycle (Documentation and notes management)
- More to be added...

## Adding New Plugins

This marketplace is designed for easy extension. To add a new plugin:

1. Create a new directory in `plugins/[plugin-name]/`
2. Add plugin.json with metadata
3. Organize your skills, commands, or agents
4. Update marketplace.json to register the plugin
5. Add documentation to `docs/plugins/`
6. Submit a pull request

See [contributing guidelines](docs/contributing.md) for detailed instructions.

## Design Principles

**Minimal Context Usage**
Each plugin minimizes token consumption through:

- CLI tools instead of MCP servers when possible
- Progressive disclosure for documentation
- Focused, single-purpose functionality

**Modular Architecture**

- Install only what you need
- No dependencies between plugins
- Each plugin is self-contained

**Production Ready**

- Tested workflows
- Clear documentation
- Real-world usage patterns

## Requirements

- Claude Code (latest version)
- Git for installation
- Additional requirements vary by plugin (see individual plugin docs)

## Contributing

Contributions are welcome! Whether you want to:

- Add a new plugin
- Improve existing plugins
- Fix bugs or enhance documentation
- Share usage patterns and examples

See [CONTRIBUTING.md](docs/contributing.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details

Individual plugins may have additional licenses or dependencies. Check each plugin's documentation.

## Author

**Matthew Fornaciari**

- GitHub: [@mattforni](https://github.com/mattforni)

## Acknowledgments

Inspired by:

- [wshobson/agents](https://github.com/wshobson/agents) - Marketplace structure and organization
- [Linearis](https://github.com/czottmann/linearis) - Linear CLI for LLM agents by Carlo Zottmann

## Support

- Issues: [GitHub Issues](https://github.com/mattforni/skillset/issues)
- Discussions: [GitHub Discussions](https://github.com/mattforni/skillset/discussions)
