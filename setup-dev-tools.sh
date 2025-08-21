#!/bin/bash

# setup-dev-tools.sh
# Sets up development tools for the SSH user

set -e

USERNAME=${SSH_USERNAME:-"myuser"}
USER_HOME="/home/$USERNAME"

echo "Setting up development tools for user: $USERNAME"

# Function to run commands as the SSH user
run_as_user() {
    sudo -u "$USERNAME" bash -c "cd $USER_HOME && $1"
}

# Configure npm prefix to avoid permission issues with global installs
echo "Configuring npm for user installations..."
run_as_user "mkdir -p $USER_HOME/.npm-global"
run_as_user "npm config set prefix '$USER_HOME/.npm-global'"

# Add npm global binaries and rbenv to PATH
echo 'export PATH="/opt/rbenv/bin:/opt/rbenv/shims:$HOME/.npm-global/bin:$PATH"' >> "$USER_HOME/.bashrc"
echo 'export PATH="/opt/rbenv/bin:/opt/rbenv/shims:$HOME/.npm-global/bin:$PATH"' >> "$USER_HOME/.profile"
echo 'eval "$(/opt/rbenv/bin/rbenv init -)"' >> "$USER_HOME/.bashrc"
echo 'eval "$(/opt/rbenv/bin/rbenv init -)"' >> "$USER_HOME/.profile"

# Ruby is installed via rbenv, ensure it's in PATH
export PATH="/opt/rbenv/bin:/opt/rbenv/shims:$USER_HOME/.npm-global/bin:$PATH"
eval "$(/opt/rbenv/bin/rbenv init -)"

# Install Claude Code globally as user (command: claude)
echo "Installing Claude Code..."
run_as_user "npm install -g @anthropic-ai/claude-code"

# Configure git if environment variables are provided
if [ -n "$GITHUB_EMAIL" ] && [ -n "$GITHUB_NAME" ]; then
    echo "Configuring git identity..."
    run_as_user "git config --global user.email '$GITHUB_EMAIL'"
    run_as_user "git config --global user.name '$GITHUB_NAME'"
    run_as_user "git config --global init.defaultBranch main"
    run_as_user "git config --global pull.rebase false"
fi

# Create a development directory first (moved up to ensure it exists before cloning)
run_as_user "mkdir -p $USER_HOME/dev"

# Authenticate GitHub CLI if token is provided
if [ -n "$GH_TOKEN" ]; then
    echo "Authenticating GitHub CLI..."
    run_as_user "echo '$GH_TOKEN' | gh auth login --with-token"
    run_as_user "gh auth status"
    
    # Setup git to use GitHub CLI for authentication (enables git push/pull)
    echo "Setting up git authentication with GitHub CLI..."
    run_as_user "gh auth setup-git"
    
    # Clone all user's repos to ~/dev
    echo "Cloning all GitHub repositories..."
    run_as_user "cd $USER_HOME/dev && gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | xargs -I {} gh repo clone {} -- --quiet"
fi

# Railway CLI is installed system-wide
# Note: Manual login required after SSH connection: 'railway login'

# Rails is installed via rbenv during Docker build

# Install common Node.js packages
echo "Installing common Node.js packages..."
run_as_user "npm install -g pnpm yarn create-next-app @expo/cli"

# Set ~/dev as the default directory when logging in via SSH
echo "cd ~/dev" >> "$USER_HOME/.bashrc"
echo "cd ~/dev" >> "$USER_HOME/.profile"

echo "Development tools setup completed for $USERNAME"