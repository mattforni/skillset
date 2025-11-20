#!/bin/bash
# Install git hooks for the skillset repository

set -e

echo "Installing git hooks..."

# Copy pre-commit hook
HOOK_SOURCE="$(git rev-parse --show-toplevel)/scripts/hooks/pre-commit"
HOOK_DEST="$(git rev-parse --show-toplevel)/.git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
  echo "Error: Hook source not found at $HOOK_SOURCE"
  exit 1
fi

cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "✓ Pre-commit hook installed"

# Check if markdownlint-cli is installed
if ! command -v markdownlint &> /dev/null; then
  echo ""
  echo "⚠️  markdownlint-cli is not installed"
  echo ""
  echo "The pre-commit hook requires markdownlint-cli."
  echo "Install it with:"
  echo "  npm install -g markdownlint-cli"
  echo ""
  read -p "Install markdownlint-cli now? (y/N): " INSTALL

  if [[ $INSTALL =~ ^[Yy]$ ]]; then
    npm install -g markdownlint-cli
    echo "✓ markdownlint-cli installed"
  else
    echo ""
    echo "Skipping markdownlint-cli installation."
    echo "You can install it later with: npm install -g markdownlint-cli"
  fi
else
  echo "✓ markdownlint-cli already installed"
fi

if ! command -v jq &> /dev/null; then
  echo ""
  echo "⚠️  jq is not installed"
  echo ""
  echo "The pre-commit hook requires jq for JSON validation."
  echo "Please install it with your system's package manager."
  echo "e.g. 'brew install jq' or 'sudo apt-get install jq'"
else
  echo "✓ jq already installed"
fi

echo ""
echo "Git hooks installation complete!"
echo ""
echo "The pre-commit hook will now:"
echo "  - Lint staged markdown files"
echo "  - Validate staged JSON files"
echo "  - Validate staged shell scripts"
echo ""
echo "To bypass the hook on a specific commit, use:"
echo "  git commit --no-verify"
