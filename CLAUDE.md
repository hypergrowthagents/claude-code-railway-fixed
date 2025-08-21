# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Railway Docker Ubuntu SSH Server project that provides an Ubuntu 24.04 LTS base with SSH server enabled for Railway deployment. It creates a containerized SSH environment accessible via Railway's TCP proxy, pre-configured as a complete development environment with Claude Code, Node.js, Ruby, and essential development tools.

## Architecture

- **Dockerfile**: Defines Ubuntu 24.04 LTS base image with SSH server, Node.js 20.x LTS, Ruby 3.3.6, development tools
- **ssh-user-config.sh**: Configuration script that runs on container startup to set up SSH users and authentication
- **setup-dev-tools.sh**: Configures Claude Code, git identity, CLI authentication, and development environment
- **assets/**: Screenshots for documentation showing Railway configuration steps

## Key Components

### Container Setup
- Ubuntu 24.04 LTS base with OpenSSH server
- Node.js 20.x LTS, Ruby 3.3.6 (via rbenv), Rails, PostgreSQL/Redis clients
- Python 3.12 (Ubuntu 24.04 default)
- Claude Code AI development assistant
- GitHub CLI and Railway CLI pre-installed
- Root login disabled by default for security
- Custom user creation with sudo permissions
- Support for both password and SSH key authentication

### Configuration Flow
1. `ssh-user-config.sh` reads environment variables or defaults
2. Creates SSH user with specified credentials
3. Sets up authorized keys if provided (disables password auth automatically)
4. Calls `setup-dev-tools.sh` to configure development environment
5. Installs Claude Code globally for SSH user
6. Configures git identity and CLI tools (GitHub CLI auth, Railway CLI install)
7. Creates ~/dev workspace directory
8. Clones all user's GitHub repositories to ~/dev (if GH_TOKEN provided)
9. Starts SSH daemon

## Environment Variables

Required for deployment:
- `SSH_USERNAME`: SSH user to create (default: "myuser")
- `SSH_PASSWORD`: Password for SSH user (default: "mypassword")

Optional:
- `ROOT_PASSWORD`: Root password (empty by default, root login disabled)
- `AUTHORIZED_KEYS`: SSH public keys for key-based authentication

Development Environment (Optional):
- `GH_TOKEN`: GitHub Personal Access Token for GitHub CLI authentication
- `GITHUB_EMAIL`: Git commit email address
- `GITHUB_NAME`: Git commit name
- `HOST`: Host binding address for Railway applications (defaults to 0.0.0.0)
- `HOSTNAME`: Hostname binding for Railway applications (defaults to 0.0.0.0)

## Deployment Commands

### Build and Deploy
```bash
# Railway automatically builds from Dockerfile on git push
git add .
git commit -m "Deploy changes"
git push
```

### Local Testing
```bash
# Build Docker image
docker build -t railway-ssh .

# Run locally (expose port 2222 for testing)
docker run -p 2222:22 \
  -e SSH_USERNAME=testuser \
  -e SSH_PASSWORD=testpass \
  -e GITHUB_EMAIL="your@email.com" \
  -e GITHUB_NAME="Your Name" \
  -e GH_TOKEN="your_github_token" \
  railway-ssh

# Connect locally
ssh testuser@localhost -p 2222

# Test development tools after SSH connection
claude --version
node --version
ruby --version
gh auth status
```

## Railway Configuration

### Required Setup Steps
1. Configure environment variables in Railway dashboard
2. Enable TCP Proxy on port 22 in Railway networking settings
3. Redeploy project after networking changes

### Security Notes
- Always change default credentials before production deployment
- Root login is disabled by default
- Consider using SSH keys instead of passwords
- Data is ephemeral - lost on every redeploy

## Development Guidelines

- Modify `ssh-user-config.sh` for user setup logic changes
- Update `setup-dev-tools.sh` for development tool configuration changes
- Update Dockerfile for base image or package changes
- Test locally before Railway deployment
- Remember Railway containers are stateless - no persistent storage without volumes
- Use `~/dev/` directory for project development
- Clone repositories manually after SSH connection using `gh repo clone`

## Documentation Maintenance

**IMPORTANT:** When making changes to the codebase, always update documentation:

### Files to Keep Updated:
- **README.md**: User-facing documentation, environment variables, usage examples
- **CLAUDE.md**: Development guidance, architecture overview, deployment instructions

### When to Update Documentation:
- Adding/removing environment variables
- Changing setup scripts (`ssh-user-config.sh`, `setup-dev-tools.sh`)
- Modifying Dockerfile (new tools, dependencies)
- Changing authentication methods (CLI tools, tokens)
- Adding new features or workflows

### Documentation Update Checklist:
- [ ] Update environment variables section if changed
- [ ] Update installation/setup steps if modified
- [ ] Update usage examples with new commands/features
- [ ] Update architecture section if new scripts/components added
- [ ] Verify all example commands still work
- [ ] Test documentation accuracy against actual deployment

**Always commit documentation updates with code changes to keep them in sync.**