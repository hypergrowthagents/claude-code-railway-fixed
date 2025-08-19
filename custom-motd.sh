#!/bin/bash

# custom-motd.sh
# Custom Message of the Day for Railway SSH Development Environment

# Colors for better formatting
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get system information
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
USERS=$(who | wc -l)

echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│${NC}  ${CYAN}🚆 Railway SSH Development Environment${NC}                    ${BLUE}│${NC}"
echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${BLUE}│${NC}  ${GREEN}System:${NC} Ubuntu 22.04 LTS • ${GREEN}Host:${NC} $HOSTNAME                  ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}  ${GREEN}Uptime:${NC} $UPTIME • ${GREEN}Users:${NC} $USERS                        ${BLUE}│${NC}"
echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"

# Development Tools Section
echo -e "${BLUE}│${NC}  ${YELLOW}🛠️  Development Tools${NC}                                    ${BLUE}│${NC}"

# Check tool versions and authentication status
NODE_VERSION=$(node --version 2>/dev/null || echo "not installed")
RUBY_VERSION=$(ruby --version 2>/dev/null | cut -d' ' -f2 || echo "not installed")
CLAUDE_VERSION=$(claude-code --version 2>/dev/null || echo "not installed")

echo -e "${BLUE}│${NC}     Node.js: ${GREEN}$NODE_VERSION${NC}                                       ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Ruby: ${GREEN}$RUBY_VERSION${NC}                                          ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Claude Code: ${GREEN}$CLAUDE_VERSION${NC}                                ${BLUE}│${NC}"

# Check CLI authentication status
GH_STATUS="❌ Not authenticated"
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        GH_STATUS="✅ Authenticated"
    fi
fi

RAILWAY_STATUS="❌ Token not set"
if [ -n "$RAILWAY_TOKEN" ]; then
    RAILWAY_STATUS="✅ Token configured"
fi

echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${BLUE}│${NC}  ${YELLOW}🔐 CLI Authentication${NC}                                   ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     GitHub CLI: $GH_STATUS                                ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Railway CLI: $RAILWAY_STATUS                        ${BLUE}│${NC}"

echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${BLUE}│${NC}  ${YELLOW}📁 Quick Start${NC}                                          ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Workspace: ${CYAN}~/dev/${NC}                                      ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Clone repo: ${CYAN}gh repo clone <user/repo>${NC}                    ${BLUE}│${NC}"
echo -e "${BLUE}│${NC}     Start Claude: ${CYAN}claude-code${NC}                               ${BLUE}│${NC}"

echo -e "${BLUE}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${BLUE}│${NC}  ${RED}⚠️  Important:${NC} Data is ephemeral - lost on redeploy!       ${BLUE}│${NC}"
echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
echo