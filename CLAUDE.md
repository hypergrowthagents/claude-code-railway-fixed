# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Railway Docker Ubuntu SSH Server project that provides an Ubuntu 22.04 base with SSH server enabled for Railway deployment. It creates a containerized SSH environment accessible via Railway's TCP proxy.

## Architecture

- **Dockerfile**: Defines Ubuntu 22.04 base image with SSH server, creates secure user setup
- **ssh-user-config.sh**: Configuration script that runs on container startup to set up SSH users and authentication
- **assets/**: Screenshots for documentation showing Railway configuration steps

## Key Components

### Container Setup
- Ubuntu 22.04 base with OpenSSH server
- Root login disabled by default for security
- Custom user creation with sudo permissions
- Support for both password and SSH key authentication

### Configuration Flow
1. `ssh-user-config.sh` reads environment variables or defaults
2. Creates SSH user with specified credentials
3. Sets up authorized keys if provided (disables password auth automatically)
4. Starts SSH daemon

## Environment Variables

Required for deployment:
- `SSH_USERNAME`: SSH user to create (default: "myuser")
- `SSH_PASSWORD`: Password for SSH user (default: "mypassword")

Optional:
- `ROOT_PASSWORD`: Root password (empty by default, root login disabled)
- `AUTHORIZED_KEYS`: SSH public keys for key-based authentication

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
docker run -p 2222:22 -e SSH_USERNAME=testuser -e SSH_PASSWORD=testpass railway-ssh

# Connect locally
ssh testuser@localhost -p 2222
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
- Update Dockerfile for base image or package changes
- Test locally before Railway deployment
- Remember Railway containers are stateless - no persistent storage without volumes