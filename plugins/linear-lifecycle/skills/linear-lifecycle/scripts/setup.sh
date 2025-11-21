#!/bin/bash
# Linear Lifecycle - Simple Setup Script
# Installs Linearis CLI and saves Linear API token to ~/.linear_api_token

set -e

echo "🔧 Linear Lifecycle Setup"
echo ""

# Step 1: Check/Install Linearis
echo "Step 1: Checking Dependencies..."
if ! command -v linearis &> /dev/null; then
  echo "  Linearis not found. Installing globally via npm..."
  npm install -g linearis
  echo "  ✓ Linearis installed"
else
  echo "  ✓ Linearis already installed"
fi

echo ""

# Step 2: Configure Linear API Token
echo "Step 2: Configuring Linear API Token..."

# Check if ~/.linear_api_token exists
if [ -f ~/.linear_api_token ]; then
  TOKEN=$(cat ~/.linear_api_token)
  echo "  ✓ Token already configured"
  echo "    Token: ${TOKEN:0:20}..."
  echo ""
  read -p "  Update token? (y/N): " UPDATE_TOKEN

  if [[ ! $UPDATE_TOKEN =~ ^[Yy]$ ]]; then
    echo "  Keeping existing token."
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Your Linear API token is ready to use."
    echo "Linearis will automatically use ~/.linear_api_token"
    exit 0
  fi
fi

# Prompt for token
echo ""
echo "  Get your Linear API token from:"
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

# Save to ~/.linear_api_token
echo "$LINEAR_API_TOKEN" > ~/.linear_api_token
chmod 600 ~/.linear_api_token
echo "  ✓ Saved token to ~/.linear_api_token"

echo ""

# Step 3: Verify connection
echo "Step 3: Verifying connection..."
TEST_RESPONSE=$(linearis issues list -l 1 2>&1)
if [ $? -eq 0 ]; then
  echo "  ✓ Successfully connected to Linear API"

  echo ""
  echo "🎉 Setup complete!"
  echo ""
  echo "Your Linear API token is saved to ~/.linear_api_token"
  echo "Linearis will automatically use this token for all operations."
  echo ""
  echo "Next steps:"
  echo "  • List issues:  linearis issues list"
  echo "  • Read issue:   linearis issues read BET-123"
  echo "  • Or just ask Claude to manage Linear issues!"
else
  echo "  ⚠️  Failed to connect to Linear API"
  echo "     Error: $TEST_RESPONSE"
  echo ""
  echo "     Please verify your token is correct."
  echo ""
  echo "To update, delete ~/.linear_api_token and re-run this script."
  exit 1
fi
