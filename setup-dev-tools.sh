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

# Add npm global binaries to PATH
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$USER_HOME/.bashrc"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$USER_HOME/.profile"

# Add rbenv to PATH for this session
echo 'export PATH="/opt/rbenv/bin:$PATH"' >> "$USER_HOME/.bashrc"
echo 'eval "$(rbenv init -)"' >> "$USER_HOME/.bashrc"
echo 'export PATH="/opt/rbenv/bin:$PATH"' >> "$USER_HOME/.profile"
echo 'eval "$(rbenv init -)"' >> "$USER_HOME/.profile"

# Source the updated profile for current setup
export PATH="/opt/rbenv/bin:$USER_HOME/.npm-global/bin:$PATH"
eval "$(rbenv init -)" 2>/dev/null || true

# Install Claude Code globally as user
echo "Installing Claude Code..."
run_as_user "npm install -g @anthropic/claude-code"

# Configure git if environment variables are provided
if [ -n "$GITHUB_EMAIL" ] && [ -n "$GITHUB_NAME" ]; then
    echo "Configuring git identity..."
    run_as_user "git config --global user.email '$GITHUB_EMAIL'"
    run_as_user "git config --global user.name '$GITHUB_NAME'"
    run_as_user "git config --global init.defaultBranch main"
    run_as_user "git config --global pull.rebase false"
fi

# Authenticate GitHub CLI if token is provided
if [ -n "$GH_TOKEN" ]; then
    echo "Authenticating GitHub CLI..."
    run_as_user "echo '$GH_TOKEN' | gh auth login --with-token"
    run_as_user "gh auth status"
fi

# Authenticate Railway CLI if token is provided
if [ -n "$RAILWAY_TOKEN" ]; then
    echo "Authenticating Railway CLI..."
    run_as_user "railway login --token '$RAILWAY_TOKEN'"
fi

# Install Rails if Ruby is available
if command -v /opt/rbenv/bin/rbenv >/dev/null 2>&1; then
    echo "Installing Rails..."
    run_as_user "source $USER_HOME/.bashrc && gem install rails bundler"
fi

# Install common Node.js packages
echo "Installing common Node.js packages..."
run_as_user "npm install -g pnpm yarn create-next-app @expo/cli"

# Create a development directory
run_as_user "mkdir -p $USER_HOME/dev"

echo "Development tools setup completed for $USERNAME"