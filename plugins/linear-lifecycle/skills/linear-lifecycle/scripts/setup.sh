#!/bin/bash
# Linear Lifecycle - Complete Setup Script
# Installs Linearis CLI, configures LINEAR_API_TOKEN in .env.local, and verifies setup

set -e

echo "🔧 Linear Lifecycle Setup"
echo ""

# Step 1: Check/Install Dependencies
echo "Step 1: Checking Dependencies..."
if ! command -v linearis &> /dev/null; then
  echo "  Linearis not found. Installing globally via npm..."
  npm install -g linearis
  echo "  ✓ Linearis installed"
else
  echo "  ✓ Linearis already installed"
fi

if ! command -v jq &> /dev/null; then
  echo "  ⚠️  jq is not installed, but it's required to run this script."
  echo "     Please install it first. For example:"
  echo "       - macOS: brew install jq"
  echo "       - Debian/Ubuntu: sudo apt-get install jq"
  exit 1
else
  echo "  ✓ jq is already installed"
fi

echo ""

# Step 2: Configure LINEAR_API_TOKEN in .env.local
echo "Step 2: Configuring LINEAR_API_TOKEN..."

# Check if .env.local exists and has token
if [ -f .env.local ] && grep -q "^LINEAR_API_TOKEN=" .env.local; then
  echo "  ✓ LINEAR_API_TOKEN already configured in .env.local"

  # Show first 20 chars to identify workspace
  TOKEN=$(grep "^LINEAR_API_TOKEN=" .env.local | cut -d'=' -f2)
  echo "    Token: ${TOKEN:0:20}..."
  echo ""
  read -p "  Update token? (y/N): " UPDATE_TOKEN

  if [[ ! $UPDATE_TOKEN =~ ^[Yy]$ ]]; then
    echo "  Keeping existing token."
  else
    # Remove old token line
    grep -v "^LINEAR_API_TOKEN=" .env.local > .env.local.tmp
    mv .env.local.tmp .env.local
    # Fall through to prompt for new token
    NEED_TOKEN=true
  fi
else
  NEED_TOKEN=true
fi

# Prompt for token if needed
if [ "$NEED_TOKEN" = true ]; then
  echo ""
  echo "  I need your Linear API token for this workspace."
  echo ""
  echo "  Get your token from:"
  echo "    1. Log into Linear (linear.app)"
  echo "    2. Go to: Settings → Security & Access → Personal API keys"
  echo "    3. Create a new API key"
  echo ""
  read -p "  Enter LINEAR_API_TOKEN: " LINEAR_API_TOKEN

  # Validate token format
  if [[ ! $LINEAR_API_TOKEN =~ ^lin_api_ ]]; then
    echo ""
    echo "  ⚠️  Warning: Token doesn't start with 'lin_api_'"
    echo "     Linear API tokens usually start with 'lin_api_'"
    echo ""
    read -p "  Continue anyway? (y/N): " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
      echo "  Setup cancelled."
      exit 1
    fi
  fi

  # Save to .env.local
  touch .env.local
  echo "" >> .env.local
  echo "# Linear API token for this workspace" >> .env.local
  echo "LINEAR_API_TOKEN=$LINEAR_API_TOKEN" >> .env.local

  echo "  ✓ Saved LINEAR_API_TOKEN to .env.local"
fi

echo ""

# Step 3: Ensure .env.local is gitignored
echo "Step 3: Checking .gitignore..."
if [ -f .gitignore ]; then
  if ! grep -q "^\.env\.local$" .gitignore; then
    echo ".env.local" >> .gitignore
    echo "  ✓ Added .env.local to .gitignore"
  else
    echo "  ✓ .env.local already in .gitignore"
  fi
else
  echo ".env.local" > .gitignore
  echo "  ✓ Created .gitignore with .env.local"
fi

echo ""

# Step 4: Verify setup and auto-detect team key
echo "Step 4: Verifying setup and detecting team..."

# Load token from .env.local
source .env.local

# Test linearis and get team key
TEAM_RESPONSE=$(linearis issues list -l 1 2>&1)
if [ $? -eq 0 ]; then
  echo "  ✓ Successfully connected to Linear API"

  # Extract team key from response
  TEAM_KEY=$(echo "$TEAM_RESPONSE" | jq -r '.[0].team.key')

  if [ -n "$TEAM_KEY" ]; then
    echo "  ✓ Detected team key: $TEAM_KEY"

    # Save team key to .env.local if not already there
    if grep -q "^LINEAR_TEAM_KEY=" .env.local; then
      # Update existing team key (portable across macOS and Linux)
      sed "s/^LINEAR_TEAM_KEY=.*/LINEAR_TEAM_KEY=$TEAM_KEY/" .env.local > .env.local.tmp
      mv .env.local.tmp .env.local
      echo "  ✓ Updated LINEAR_TEAM_KEY in .env.local"
    else
      # Add new team key
      echo "LINEAR_TEAM_KEY=$TEAM_KEY" >> .env.local
      echo "  ✓ Saved LINEAR_TEAM_KEY to .env.local"
    fi
  else
    echo "  ⚠️  Could not auto-detect team key"
    echo "     You may need to specify --team manually when creating issues"
  fi

  echo ""
  echo "🎉 Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  • List issues:  linearis issues list"
  echo "  • Read issue:   linearis issues read BET-123"
  echo "  • Create issue: linearis issues create \"Issue title\" --team $TEAM_KEY"
  echo "  • Or just ask Claude to manage Linear issues!"
else
  echo "  ⚠️  Failed to connect to Linear API"
  echo "     Please verify your token is correct."
  echo ""
  echo "To update token, delete the LINEAR_API_TOKEN line from .env.local"
  echo "and re-run this script."
  exit 1
fi
