#!/bin/bash
# CLAUDE.md Quick Installer
# Fetches CLAUDE.md configuration from GitHub repository
# Usage: curl -fsSL <url> | bash

set -euo pipefail

# GitHub repository configuration
GITHUB_USER="${CLAUDE_GITHUB_USER:-MrKnights1}"
GITHUB_REPO="${CLAUDE_GITHUB_REPO:-claude-config}"
GITHUB_BRANCH="${CLAUDE_GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors (disabled when stdout is not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    BLUE=''
    YELLOW=''
    NC=''
fi

GLOBAL_DIR="$HOME/.claude"

# Prompt helper — reads from /dev/tty so it works with curl | bash
# Set CLAUDE_INSTALL_RESPONSES="val1,val2,..." to provide answers non-interactively (for testing)
if [ -n "${CLAUDE_INSTALL_RESPONSES:-}" ]; then
    _ASK_INDEX_FILE=$(mktemp)
    echo "0" > "$_ASK_INDEX_FILE"
fi
ask() {
    local prompt="$1"
    local default="$2"
    local reply
    if [ -n "${CLAUDE_INSTALL_RESPONSES:-}" ]; then
        local idx
        idx=$(cat "$_ASK_INDEX_FILE")
        reply=$(echo "$CLAUDE_INSTALL_RESPONSES" | cut -d',' -f$((idx + 1)))
        echo $((idx + 1)) > "$_ASK_INDEX_FILE"
        echo -e "${YELLOW}Auto-response '${reply:-$default}' for: ${prompt}${NC}" >&2
    elif (echo -n "" > /dev/tty) 2>/dev/null; then
        echo -en "${YELLOW}${prompt}${NC} " > /dev/tty
        read -r reply < /dev/tty
    else
        echo -e "${YELLOW}Non-interactive mode: using default '${default}' for: ${prompt}${NC}" >&2
        reply="$default"
    fi
    echo "${reply:-$default}"
}

# Download helper
download_file() {
    local url="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$dest" || { echo -e "${RED}Download failed: $url${NC}" >&2; exit 1; }
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$dest" || { echo -e "${RED}Download failed: $url${NC}" >&2; exit 1; }
    else
        echo -e "${RED}Neither curl nor wget found. Please install one.${NC}" >&2
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
    "project-init.md"
)

skill_dirs=(
    "commit"
    "merge"
    "issue"
    "review"
)

echo -e "${BLUE}CLAUDE.md Installer${NC}"
echo -e "${BLUE}================================${NC}\n"

# Ask: install mode
INSTALL_MODE=$(ask "Install globally or for this project? (g/p)" "p")
case "$INSTALL_MODE" in
    g|G|global) INSTALL_MODE="global" ;;
    *) INSTALL_MODE="project" ;;
esac
echo -e "Mode: ${GREEN}${INSTALL_MODE}${NC}\n"

if [ "$INSTALL_MODE" = "global" ]; then

    # Ask: attribution
    DISABLE_ATTR=$(ask "Disable commit/PR attribution? (y/n)" "n")

    # Warn and confirm if overwriting existing files
    if [ -f "$GLOBAL_DIR/CLAUDE.md" ]; then
        echo -e "${YELLOW}Warning: Existing files in ~/.claude/ will be overwritten.${NC}" >&2
        CONFIRM=$(ask "Continue? (y/n)" "n")
        case "$CONFIRM" in
            y|Y|yes) ;;
            *) echo -e "${RED}Installation cancelled.${NC}" >&2; exit 0 ;;
        esac
    fi

    # Create directories
    echo -e "\n${YELLOW}Creating directories...${NC}"
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

    # Disable attribution if requested
    case "$DISABLE_ATTR" in
        y|Y|yes)
            SETTINGS_FILE="$GLOBAL_DIR/settings.json"
            if [ -f "$SETTINGS_FILE" ]; then
                if command -v jq &> /dev/null; then
                    echo -e "${YELLOW}Updating settings.json...${NC}"
                    jq '.attribution.commit = "" | .attribution.pr = ""' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
                    if [ -s "$SETTINGS_FILE.tmp" ]; then
                        mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                        echo -e "${GREEN}Attribution disabled in settings.json${NC}"
                    else
                        rm -f "$SETTINGS_FILE.tmp"
                        echo -e "${RED}Error: settings.json merge produced empty output${NC}" >&2
                    fi
                else
                    echo -e "${YELLOW}jq not found, skipping settings.json update. Install jq or add attribution manually.${NC}" >&2
                fi
            else
                echo -e "${YELLOW}Creating settings.json...${NC}"
                printf '{\n  "attribution": {\n    "commit": "",\n    "pr": ""\n  }\n}\n' > "$SETTINGS_FILE"
                echo -e "${GREEN}Attribution disabled in settings.json${NC}"
            fi
            ;;
    esac

    echo -e "\n${BLUE}================================${NC}"
    echo -e "${GREEN}Global installation complete!${NC}"
    echo -e "${BLUE}================================${NC}\n"

    echo -e "${YELLOW}Installed to:${NC}"
    echo -e "  ~/.claude/CLAUDE.md"
    echo -e "  ~/.claude/.claude/*.md  (guidelines)"
    echo -e "  ~/.claude/skills/*/     (skills)\n"

    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Start a new Claude Code session"
    echo -e "  2. Skills (/commit, /merge, /issue, /review) are now available globally"
    echo -e "  3. Guidelines apply to all projects without a project-level CLAUDE.md\n"

    echo -e "${BLUE}Tip:${NC} Project-level CLAUDE.md files override the global one.\n"

else

    # Validate project root (only warn interactively)
    if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "composer.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ] && [ ! -f "requirements.txt" ]; then
        if (echo -n "" > /dev/tty) 2>/dev/null; then
            echo -e "${YELLOW}Warning: This doesn't look like a project root (no .git, package.json, etc.)${NC}" >&2
            CONFIRM=$(ask "Install here anyway? (y/n)" "y")
            case "$CONFIRM" in
                y|Y|yes) ;;
                *) echo -e "${RED}Installation cancelled.${NC}" >&2; exit 0 ;;
            esac
        fi
    fi

    # Create directories
    echo -e "\n${YELLOW}Creating directories...${NC}"
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
