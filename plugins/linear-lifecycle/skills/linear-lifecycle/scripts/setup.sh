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

# Check for LINEAR_API_KEY and offer migration to LINEAR_API_TOKEN
if [ -f .env.local ] && grep -q "^LINEAR_API_KEY=" .env.local && ! grep -q "^LINEAR_API_TOKEN=" .env.local; then
  echo "  ℹ️  Found LINEAR_API_KEY in .env.local"
  echo ""
  echo "  Linearis CLI uses LINEAR_API_TOKEN instead of LINEAR_API_KEY."
  echo "  Would you like to migrate your configuration?"
  echo ""
  read -p "  Migrate LINEAR_API_KEY → LINEAR_API_TOKEN? (Y/n): " MIGRATE_KEY

  if [[ ! $MIGRATE_KEY =~ ^[Nn]$ ]]; then
    # Extract the key value
    API_KEY=$(grep "^LINEAR_API_KEY=" .env.local | cut -d'=' -f2)

    # Add LINEAR_API_TOKEN with the same value
    echo "LINEAR_API_TOKEN=$API_KEY" >> .env.local
    echo "  ✓ Added LINEAR_API_TOKEN to .env.local"
    echo "  ✓ Original LINEAR_API_KEY preserved for compatibility"
    echo ""
  else
    echo "  Skipped migration. Note: Linearis CLI requires LINEAR_API_TOKEN."
    NEED_TOKEN=true
  fi
fi

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
  read -sp "  Enter LINEAR_API_TOKEN: " LINEAR_API_TOKEN
  echo ""

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

# Test linearis connection and get teams
echo "  Testing Linear API connection..."
TEAMS_RESPONSE=$(linearis teams list 2>&1)
if [ $? -eq 0 ]; then
  echo "  ✓ Successfully connected to Linear API"

  # Count teams
  TEAM_COUNT=$(echo "$TEAMS_RESPONSE" | jq '. | length')

  if [ "$TEAM_COUNT" -eq 0 ]; then
    echo "  ⚠️  No teams found in your Linear workspace"
    echo "     Please check your API token permissions"
  elif [ "$TEAM_COUNT" -eq 1 ]; then
    # Single team - auto-configure
    TEAM_KEY=$(echo "$TEAMS_RESPONSE" | jq -r '.[0].key')
    TEAM_NAME=$(echo "$TEAMS_RESPONSE" | jq -r '.[0].name')
    echo "  ✓ Detected team: $TEAM_NAME ($TEAM_KEY)"

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
    # Multiple teams - prompt user to choose
    echo "  Found $TEAM_COUNT teams in your workspace:"
    echo ""
    echo "$TEAMS_RESPONSE" | jq -r '.[] | "    • \(.key): \(.name)"'
    echo ""
    read -p "  Enter the team key to use (e.g., BET): " TEAM_KEY

    if [ -n "$TEAM_KEY" ]; then
      # Validate team key exists
      VALID_TEAM=$(echo "$TEAMS_RESPONSE" | jq -r --arg key "$TEAM_KEY" '.[] | select(.key == $key) | .key')

      if [ -n "$VALID_TEAM" ]; then
        # Save team key to .env.local
        if grep -q "^LINEAR_TEAM_KEY=" .env.local; then
          sed "s/^LINEAR_TEAM_KEY=.*/LINEAR_TEAM_KEY=$TEAM_KEY/" .env.local > .env.local.tmp
          mv .env.local.tmp .env.local
          echo "  ✓ Updated LINEAR_TEAM_KEY in .env.local"
        else
          echo "LINEAR_TEAM_KEY=$TEAM_KEY" >> .env.local
          echo "  ✓ Saved LINEAR_TEAM_KEY to .env.local"
        fi
      else
        echo "  ⚠️  Invalid team key: $TEAM_KEY"
        echo "     You may need to specify --team manually when creating issues"
      fi
    else
      echo "  ⚠️  No team key entered"
      echo "     You may need to specify --team manually when creating issues"
    fi
  fi

  echo ""
  echo "🎉 Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  • List issues:  linearis issues list"
  echo "  • Read issue:   linearis issues read BET-123"
  if [ -n "$TEAM_KEY" ]; then
    echo "  • Create issue: linearis issues create \"Issue title\" --team $TEAM_KEY"
  else
    echo "  • Create issue: linearis issues create \"Issue title\" --team YOUR_TEAM_KEY"
  fi
  echo "  • Or just ask Claude to manage Linear issues!"
else
  echo "  ⚠️  Failed to connect to Linear API"
  echo "     Error: $TEAMS_RESPONSE"
  echo ""
  echo "     Please verify your token is correct."
  echo ""
  echo "To update token, delete the LINEAR_API_TOKEN line from .env.local"
  echo "and re-run this script."
  exit 1
fi
