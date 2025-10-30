#!/bin/bash
# CLAUDE.md Quick Installer
# Fetches CLAUDE.md configuration from GitHub repository
# Usage: curl -fsSL <url-to-this-script> | bash

set -e

# GitHub repository configuration
GITHUB_USER="${CLAUDE_GITHUB_USER:-MrKnights1}"
GITHUB_REPO="${CLAUDE_GITHUB_REPO:-claude-config}"
GITHUB_BRANCH="${CLAUDE_GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🤖 CLAUDE.md Quick Installer${NC}"
echo -e "${BLUE}================================${NC}\n"

# Create .claude directory
echo -e "${YELLOW}Creating .claude directory...${NC}"
mkdir -p .claude

# Download files
echo -e "${YELLOW}Downloading CLAUDE.md configuration...${NC}"

files=(
    "CLAUDE.md"
    ".claude/security.md"
    ".claude/testing.md"
    ".claude/api-design.md"
    ".claude/structure.md"
    ".claude/database.md"
    ".claude/standards.md"
)

for file in "${files[@]}"; do
    echo -e "  Downloading ${file}..."
    if command -v curl &> /dev/null; then
        curl -fsSL "${BASE_URL}/${file}" -o "${file}"
    elif command -v wget &> /dev/null; then
        wget -q "${BASE_URL}/${file}" -O "${file}"
    else
        echo -e "${YELLOW}⚠️  Neither curl nor wget found. Please install one.${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}✓ All files downloaded successfully!${NC}\n"

# Update .gitignore if it exists
if [ -f ".gitignore" ]; then
    if ! grep -q ".claude/settings.local.json" .gitignore; then
        echo -e "${YELLOW}Updating .gitignore...${NC}"
        echo "" >> .gitignore
        echo "# Claude Code local settings" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo -e "${GREEN}✓ Updated .gitignore${NC}"
    fi
fi

echo -e "\n${BLUE}================================${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${BLUE}================================${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Customize CLAUDE.md 'Common Commands' for your project"
echo -e "  2. Review guidelines in .claude/ directory"
echo -e "  3. Commit files to your repository"
echo -e "  4. Start using Claude Code!\n"

echo -e "${BLUE}Tip:${NC} Press ${YELLOW}#${NC} in Claude Code to update CLAUDE.md\n"
