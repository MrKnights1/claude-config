#!/bin/bash
# CLAUDE.md Quick Installer
# Fetches CLAUDE.md configuration from GitHub repository
# Usage: curl -fsSL <url> | bash

set -euo pipefail

# GitHub repository configuration
GITHUB_USER="${CLAUDE_GITHUB_USER:-MrKnights1}"
GITHUB_REPO="${CLAUDE_GITHUB_REPO:-claude-config}"
GITHUB_BRANCH="${CLAUDE_GITHUB_BRANCH:-main}"

# Validate inputs to prevent URL manipulation
# User/repo: no slashes (prevent path traversal). Branch: allow slashes (feature/foo).
_valid_name='^[a-zA-Z0-9][a-zA-Z0-9._-]*$'
_valid_branch='^[a-zA-Z0-9][a-zA-Z0-9._/-]*$'
if [[ ! "$GITHUB_USER" =~ $_valid_name ]]; then
    echo "Error: GITHUB_USER must contain only alphanumeric characters, dots, hyphens, and underscores." >&2
    exit 1
fi
if [[ ! "$GITHUB_REPO" =~ $_valid_name ]]; then
    echo "Error: GITHUB_REPO must contain only alphanumeric characters, dots, hyphens, and underscores." >&2
    exit 1
fi
if [[ ! "$GITHUB_BRANCH" =~ $_valid_branch ]]; then
    echo "Error: GITHUB_BRANCH must contain only alphanumeric characters, dots, hyphens, underscores, and slashes." >&2
    exit 1
fi
if [[ "$GITHUB_BRANCH" == *".."* ]]; then
    echo "Error: GITHUB_BRANCH must not contain '..' sequences." >&2
    exit 1
fi

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

# Temp directory for downloads (cleaned up on exit)
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Prompt helper — reads from /dev/tty so it works with curl | bash
# Set CLAUDE_INSTALL_RESPONSES="val1,val2,..." to provide answers non-interactively (for testing)
if [ -n "${CLAUDE_INSTALL_RESPONSES:-}" ]; then
    _ASK_INDEX_FILE="$TEMP_DIR/.ask_index"
    echo "0" > "$_ASK_INDEX_FILE"
fi
ask() {
    local prompt="$1"
    local default="$2"
    local reply
    if [ -n "${CLAUDE_INSTALL_RESPONSES:-}" ]; then
        local idx
        idx=$(cat "$_ASK_INDEX_FILE")
        reply=$(printf '%s\n' "$CLAUDE_INSTALL_RESPONSES" | awk -F',' -v i=$((idx + 1)) '{print $i}')
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

# Download helper (downloads to temp dir)
download_file() {
    local url="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if command -v curl &> /dev/null; then
        curl -fSL --proto =https --proto-redir =https --connect-timeout 10 --max-time 30 --max-filesize 1048576 "$url" -o "$dest" || { echo -e "${RED}Download failed: $url${NC}" >&2; exit 1; }
    elif command -v wget &> /dev/null; then
        wget -q --https-only --timeout=30 "$url" -O "$dest" || { echo -e "${RED}Download failed: $url${NC}" >&2; exit 1; }
        local filesize
        filesize=$(wc -c < "$dest")
        if [ "$filesize" -gt 1048576 ]; then
            echo -e "${RED}Downloaded file exceeds 1MB limit: $url${NC}" >&2
            rm -f "$dest"
            exit 1
        fi
    else
        echo -e "${RED}Neither curl nor wget found. Please install one.${NC}" >&2
        exit 1
    fi

    # Reject HTML responses (error pages, captive portals)
    if head -c 100 "$dest" | grep -qiE '^\s*<(!DOCTYPE|html)'; then
        echo -e "${RED}Downloaded file appears to be HTML, not markdown: $url${NC}" >&2
        rm -f "$dest"
        exit 1
    fi
}

# Compare temp downloads with existing files, show changes, and copy over
# Usage: apply_downloads target_dir file1 file2 ... -- known1 known2 ...
# Files after "--" are known installer-managed paths for removal detection
apply_downloads() {
    local target_dir="$1"
    shift

    local files=()
    local known_paths=()
    local past_separator=false
    for arg in "$@"; do
        if [ "$arg" = "--" ]; then
            past_separator=true
            continue
        fi
        if [ "$past_separator" = true ]; then
            known_paths+=("$arg")
        else
            files+=("$arg")
        fi
    done

    local changed=()
    local new_files=()
    local removed=()

    for file in "${files[@]}"; do
        local temp_file="$TEMP_DIR/$file"
        local dest_file="$target_dir/$file"
        if [ ! -f "$dest_file" ]; then
            new_files+=("$file")
        elif ! cmp -s "$temp_file" "$dest_file"; then
            changed+=("$file")
        fi
    done

    # Detect previously-installed files that are no longer in the current file list
    for known in "${known_paths[@]}"; do
        [ -f "$target_dir/$known" ] || continue
        local found=false
        for file in "${files[@]}"; do
            if [ "$file" = "$known" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            removed+=("$known")
        fi
    done

    if [ ${#changed[@]} -eq 0 ] && [ ${#new_files[@]} -eq 0 ] && [ ${#removed[@]} -eq 0 ]; then
        echo -e "${GREEN}All files are already up to date.${NC}"
        return 0
    fi

    if [ ${#new_files[@]} -gt 0 ]; then
        echo -e "${GREEN}New files:${NC}"
        for file in "${new_files[@]}"; do
            echo -e "  + ${file}"
        done
    fi
    if [ ${#changed[@]} -gt 0 ]; then
        echo -e "${YELLOW}Changed files:${NC}"
        for file in "${changed[@]}"; do
            echo -e "  ~ ${file}"
        done
    fi
    if [ ${#removed[@]} -gt 0 ]; then
        echo -e "${RED}Removed upstream (not in remote):${NC}"
        for file in "${removed[@]}"; do
            echo -e "  - ${file}"
        done
    fi

    echo ""
    local CONFIRM
    CONFIRM=$(ask "Apply these changes? (Y/n)" "y")
    case "$CONFIRM" in
        y|Y|yes) ;;
        *) echo -e "${RED}Installation cancelled.${NC}" >&2; exit 0 ;;
    esac

    # Backup changed and removed files before applying
    local backup_dir=""
    if [ ${#changed[@]} -gt 0 ] || [ ${#removed[@]} -gt 0 ]; then
        backup_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-backup-XXXXXX")
        for file in "${changed[@]}"; do
            mkdir -p "$backup_dir/$(dirname "$file")"
            cp "$target_dir/$file" "$backup_dir/$file"
        done
        if [ ${#removed[@]} -gt 0 ]; then
            for file in "${removed[@]}"; do
                mkdir -p "$backup_dir/$(dirname "$file")"
                cp "$target_dir/$file" "$backup_dir/$file"
            done
        fi
        echo -e "${BLUE}Backup saved to: ${backup_dir}${NC}"
    fi

    if [ ${#new_files[@]} -gt 0 ]; then
        for file in "${new_files[@]}"; do
            local dest_file="$target_dir/$file"
            mkdir -p "$(dirname "$dest_file")"
            cp "$TEMP_DIR/$file" "$dest_file"
        done
    fi
    if [ ${#changed[@]} -gt 0 ]; then
        for file in "${changed[@]}"; do
            local dest_file="$target_dir/$file"
            mkdir -p "$(dirname "$dest_file")"
            cp "$TEMP_DIR/$file" "$dest_file"
        done
    fi

    if [ ${#removed[@]} -gt 0 ]; then
        for file in "${removed[@]}"; do
            rm -f "$target_dir/$file"
            local parent
            parent="$(dirname "$target_dir/$file")"
            if [ "$parent" != "$target_dir" ]; then
                rmdir -p "$parent" 2>/dev/null || true
            fi
        done
    fi

    echo -e "${GREEN}Applied ${#new_files[@]} new, ${#changed[@]} updated, ${#removed[@]} removed.${NC}"
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
    "plan"
)

echo -e "${BLUE}CLAUDE.md Installer${NC}"
echo -e "${BLUE}================================${NC}\n"

# Ask: install mode
INSTALL_MODE=$(ask "Install globally or for this project? (G/p)" "g")
case "$INSTALL_MODE" in
    g|G|global) INSTALL_MODE="global" ;;
    *) INSTALL_MODE="project" ;;
esac
echo -e "Mode: ${GREEN}${INSTALL_MODE}${NC}\n"

if [ "$INSTALL_MODE" = "global" ]; then

    # Ask: attribution
    DISABLE_ATTR=$(ask "Disable commit/PR attribution? (Y/n)" "y")


    # Build file list for global install
    global_files=("CLAUDE.md")
    for file in "${guideline_files[@]}"; do
        global_files+=(".claude/${file}")
    done
    for skill in "${skill_dirs[@]}"; do
        global_files+=("skills/${skill}/SKILL.md")
    done

    # Download all files to temp dir
    echo -e "\n${YELLOW}Downloading configuration files...${NC}"
    for file in "${global_files[@]}"; do
        echo -e "  Downloading ${file}..."
        # Map source paths: .claude/* comes from repo .claude/*, skills/* from repo .claude/skills/*
        if [[ "$file" == "CLAUDE.md" ]]; then
            download_file "${BASE_URL}/CLAUDE.md" "$TEMP_DIR/$file"
        elif [[ "$file" == .claude/* ]]; then
            download_file "${BASE_URL}/${file}" "$TEMP_DIR/$file"
        elif [[ "$file" == skills/* ]]; then
            download_file "${BASE_URL}/.claude/${file}" "$TEMP_DIR/$file"
        else
            echo -e "${RED}Unknown file mapping: $file${NC}" >&2; exit 1
        fi
    done

    # Known paths for removal detection — add historical paths here if files are removed from global_files
    global_known=("${global_files[@]}")

    echo ""
    apply_downloads "$GLOBAL_DIR" "${global_files[@]}" -- "${global_known[@]}"
    echo ""

    # Disable attribution if requested
    case "$DISABLE_ATTR" in
        y|Y|yes)
            SETTINGS_FILE="$GLOBAL_DIR/settings.json"
            if [ -f "$SETTINGS_FILE" ]; then
                if command -v jq &> /dev/null; then
                    echo -e "${YELLOW}Updating settings.json...${NC}"
                    if jq '.attribution.commit = "" | .attribution.pr = ""' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" 2>/dev/null \
                       && [ -s "$SETTINGS_FILE.tmp" ] \
                       && jq . "$SETTINGS_FILE.tmp" > /dev/null 2>&1; then
                        mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                        echo -e "${GREEN}Attribution disabled in settings.json${NC}"
                    else
                        rm -f "$SETTINGS_FILE.tmp"
                        echo -e "${RED}Error: settings.json merge failed (is settings.json valid JSON?)${NC}" >&2
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
    echo -e "  2. Skills (/commit, /merge, /issue, /review, /plan) are now available globally"
    echo -e "  3. Guidelines apply to all projects without a project-level CLAUDE.md\n"

    echo -e "${BLUE}Tip:${NC} Project-level CLAUDE.md files override the global one.\n"

else

    # Validate project root
    if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "composer.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ] && [ ! -f "requirements.txt" ]; then
        echo -e "${YELLOW}Warning: This doesn't look like a project root (no .git, package.json, etc.)${NC}" >&2
        if [ -n "${CLAUDE_INSTALL_RESPONSES:-}" ] || (echo -n "" > /dev/tty) 2>/dev/null; then
            CONFIRM=$(ask "Install here anyway? (Y/n)" "y")
            case "$CONFIRM" in
                y|Y|yes) ;;
                *) echo -e "${RED}Installation cancelled.${NC}" >&2; exit 0 ;;
            esac
        fi
    fi

    # Build file list for project install
    project_files=("CLAUDE.md")
    for file in "${guideline_files[@]}"; do
        project_files+=(".claude/${file}")
    done
    for skill in "${skill_dirs[@]}"; do
        project_files+=(".claude/skills/${skill}/SKILL.md")
    done

    # Download all files to temp dir
    echo -e "\n${YELLOW}Downloading configuration files...${NC}"
    for file in "${project_files[@]}"; do
        echo -e "  Downloading ${file}..."
        download_file "${BASE_URL}/${file}" "$TEMP_DIR/$file"
    done

    # Known paths for removal detection — add historical paths here if files are removed from project_files
    project_known=("${project_files[@]}")

    echo ""
    apply_downloads "." "${project_files[@]}" -- "${project_known[@]}"
    echo ""

    # Update .gitignore if it exists
    if [ -f ".gitignore" ]; then
        if ! grep -qF ".claude/settings.local.json" .gitignore; then
            echo -e "${YELLOW}Updating .gitignore...${NC}"
            # Add blank line separator only if file doesn't end with one
            [ -n "$(tail -c1 .gitignore)" ] && echo "" >> .gitignore
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
