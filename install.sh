#!/bin/bash
# CLAUDE.md Quick Installer
# Fetches CLAUDE.md configuration from GitHub repository
# Usage:
#   Project install: curl -fsSL <url> | bash
#   Global install:  curl -fsSL <url> | bash -s -- --global

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

# Detect install mode
INSTALL_MODE="project"
for arg in "$@"; do
    if [ "$arg" = "--global" ]; then
        INSTALL_MODE="global"
    fi
done

GLOBAL_DIR="$HOME/.claude"

# Download helper
download_file() {
    local url="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$dest"
    else
        echo -e "${YELLOW}Neither curl nor wget found. Please install one.${NC}"
        exit 1
    fi
}

# Source files to download
guideline_files=(
    "security.md"
    "security-review.md"
    "testing.md"
    "api-design.md"
    "structure.md"
    "database.md"
    "standards.md"
)

skill_dirs=(
    "commit"
    "merge"
    "issue"
)

if [ "$INSTALL_MODE" = "global" ]; then
    echo -e "${BLUE}CLAUDE.md Global Installer${NC}"
    echo -e "${BLUE}================================${NC}\n"

    # Create directories
    echo -e "${YELLOW}Creating directories...${NC}"
    mkdir -p "$GLOBAL_DIR/.claude"
    for skill in "${skill_dirs[@]}"; do
        mkdir -p "$GLOBAL_DIR/skills/$skill"
    done

    # Download CLAUDE.md
    echo -e "${YELLOW}Downloading configuration files...${NC}"
    echo -e "  Downloading CLAUDE.md..."
    download_file "${BASE_URL}/CLAUDE.md" "$GLOBAL_DIR/CLAUDE.md"

    # Download guideline files -> ~/.claude/.claude/*.md
    for file in "${guideline_files[@]}"; do
        echo -e "  Downloading .claude/${file}..."
        download_file "${BASE_URL}/.claude/${file}" "$GLOBAL_DIR/.claude/${file}"
    done

    # Download skills -> ~/.claude/skills/*/SKILL.md
    for skill in "${skill_dirs[@]}"; do
        echo -e "  Downloading skills/${skill}/SKILL.md..."
        download_file "${BASE_URL}/.claude/skills/${skill}/SKILL.md" "$GLOBAL_DIR/skills/${skill}/SKILL.md"
    done

    echo -e "\n${GREEN}All files downloaded successfully!${NC}\n"

    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}Global installation complete!${NC}"
    echo -e "${BLUE}================================${NC}\n"

    echo -e "${YELLOW}Installed to:${NC}"
    echo -e "  ~/.claude/CLAUDE.md"
    echo -e "  ~/.claude/.claude/*.md  (guidelines)"
    echo -e "  ~/.claude/skills/*/     (skills)\n"

    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Start a new Claude Code session"
    echo -e "  2. Skills (/commit, /merge, /issue) are now available globally"
    echo -e "  3. Guidelines apply to all projects without a project-level CLAUDE.md\n"

    echo -e "${BLUE}Tip:${NC} Project-level CLAUDE.md files override the global one.\n"

else
    echo -e "${BLUE}CLAUDE.md Quick Installer${NC}"
    echo -e "${BLUE}================================${NC}\n"

    # Create directories
    echo -e "${YELLOW}Creating directories...${NC}"
    mkdir -p .claude
    for skill in "${skill_dirs[@]}"; do
        mkdir -p ".claude/skills/$skill"
    done

    # Download all files
    echo -e "${YELLOW}Downloading CLAUDE.md configuration...${NC}"

    files=(
        "CLAUDE.md"
    )
    for file in "${guideline_files[@]}"; do
        files+=(".claude/${file}")
    done
    for skill in "${skill_dirs[@]}"; do
        files+=(".claude/skills/${skill}/SKILL.md")
    done

    for file in "${files[@]}"; do
        echo -e "  Downloading ${file}..."
        download_file "${BASE_URL}/${file}" "${file}"
    done

    echo -e "\n${GREEN}All files downloaded successfully!${NC}\n"

    # Update .gitignore if it exists
    if [ -f ".gitignore" ]; then
        if ! grep -q ".claude/settings.local.json" .gitignore; then
            echo -e "${YELLOW}Updating .gitignore...${NC}"
            echo "" >> .gitignore
            echo "# Claude Code local settings" >> .gitignore
            echo ".claude/settings.local.json" >> .gitignore
            echo -e "${GREEN}Updated .gitignore${NC}"
        fi
    fi

    echo -e "\n${BLUE}================================${NC}"
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${BLUE}================================${NC}\n"

    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Customize CLAUDE.md 'Common Commands' for your project"
    echo -e "  2. Review guidelines in .claude/ directory"
    echo -e "  3. Commit files to your repository"
    echo -e "  4. Start using Claude Code!\n"

    echo -e "${BLUE}Tip:${NC} Press ${YELLOW}#${NC} in Claude Code to update CLAUDE.md\n"
fi
