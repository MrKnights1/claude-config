# GitHub Repository Setup Guide for CLAUDE.md

This guide shows how to create a public GitHub repository for your CLAUDE.md configuration that can be installed with a simple one-liner command.

## Step 1: Create GitHub Repository

### Option A: Using GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `claude-config` (or any name you prefer)
3. Description: `Standard CLAUDE.md configuration for all my projects`
4. Make it **Public** (so anyone can download without authentication)
5. Click "Create repository"

### Option B: Using GitHub CLI

```bash
gh repo create claude-config --public --description "Standard CLAUDE.md configuration for all my projects"
```

## Step 2: Upload Your CLAUDE.md Files

### Project Structure in Repository

Your repository should have this structure:

```
claude-config/
├── README.md
├── install.sh
├── CLAUDE.md
└── .claude/
    ├── security.md
    ├── testing.md
    ├── api-design.md
    ├── structure.md
    ├── database.md
    └── standards.md
```

### Upload Files

**From your current directory:**

```bash
# Initialize git if not already done
git init

# Add all CLAUDE.md files
git add CLAUDE.md .claude/

# Create install.sh (will create in next step)
git add install.sh README.md

# Commit
git commit -m "Add CLAUDE.md configuration files"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/claude-config.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Create install.sh in Repository

Create `install.sh` in your repository root:

```bash
#!/bin/bash
# CLAUDE.md Quick Installer
set -e

# Configuration - Update these with your GitHub details
GITHUB_USER="YOUR_USERNAME"
GITHUB_REPO="claude-config"
GITHUB_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🤖 CLAUDE.md Installer${NC}\n"

# Create .claude directory
mkdir -p .claude

# Files to download
files=(
    "CLAUDE.md"
    ".claude/security.md"
    ".claude/testing.md"
    ".claude/api-design.md"
    ".claude/structure.md"
    ".claude/database.md"
    ".claude/standards.md"
)

# Download each file
for file in "${files[@]}"; do
    echo "Downloading ${file}..."
    curl -fsSL "${BASE_URL}/${file}" -o "${file}"
done

# Update .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q ".claude/settings.local.json" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code local settings" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
    fi
fi

echo -e "\n${GREEN}✓ Installation complete!${NC}\n"
echo -e "Next steps:"
echo -e "  1. Customize CLAUDE.md for your project"
echo -e "  2. Review .claude/ guidelines"
echo -e "  3. Commit to your repository\n"
```

**Important:** Replace `YOUR_USERNAME` with your actual GitHub username in the script!

## Step 4: Create Repository README.md

Create a nice README for your repository:

```markdown
# CLAUDE.md Configuration

Standard CLAUDE.md configuration for Claude Code projects with modular guidelines.

## Quick Install

Run this one-liner in any project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

## Manual Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/claude-config.git

# Copy files to your project
cp claude-config/CLAUDE.md your-project/
cp -r claude-config/.claude your-project/
```

## What's Included

- **CLAUDE.md** - Main configuration (200 lines, optimized)
- **.claude/security.md** - Security guidelines
- **.claude/testing.md** - Testing requirements
- **.claude/api-design.md** - API & logging standards
- **.claude/structure.md** - Project structure conventions
- **.claude/database.md** - Database & migration guidelines
- **.claude/standards.md** - Code quality & cleanup rules

## Customization

After installation:

1. Update the "Common Commands" section in `CLAUDE.md` with your project's specific commands
2. Adjust guidelines in `.claude/` directory as needed
3. Commit to your project repository

## Features

✓ Follows official Claude Code best practices (100-200 lines main file)
✓ Modular design with imports
✓ Comprehensive security guidelines
✓ Git workflow with GitHub issues
✓ Testing and code quality standards
✓ Easy to maintain and update

## License

MIT - Free to use in your projects
```

## Step 5: Test Your Installation

```bash
# Go to a test directory
cd /tmp
mkdir test-project
cd test-project

# Run your installer
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash

# Verify files were created
ls -la
ls -la .claude/
```

---

## Installation Commands

After setup, share these commands with your team:

### One-Liner (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

### One-Liner (wget)

```bash
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

### Git Clone Method

```bash
# Clone to temp directory and copy
git clone https://github.com/YOUR_USERNAME/claude-config.git /tmp/claude-config
cp /tmp/claude-config/CLAUDE.md .
cp -r /tmp/claude-config/.claude .
rm -rf /tmp/claude-config
```

---

## URL Shortening

### Using bit.ly

1. Go to https://bitly.com
2. Create free account
3. Shorten: `https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh`
4. Get short URL like: `https://bit.ly/claude-setup`

**Then your installation becomes:**

```bash
curl -fsSL https://bit.ly/claude-setup | bash
```

### Using git.io (GitHub's shortener)

```bash
curl https://git.io/ -i -F "url=https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh" -F "code=claude-setup"
```

This creates: `https://git.io/claude-setup`

### Using is.gd (No registration needed)

```bash
curl -s "https://is.gd/create.php?format=simple&url=https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh"
```

### Using TinyURL

Go to https://tinyurl.com and paste your GitHub raw URL.

---

## Advanced: Multiple Configurations

You can create different branches for different tech stacks:

```bash
# Main branch: General configuration
main/

# React-specific configuration
git checkout -b react
# Modify CLAUDE.md for React projects
git push origin react

# Node.js-specific
git checkout -b nodejs
# Modify CLAUDE.md for Node.js
git push origin nodejs
```

**Install specific branch:**

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/react/install.sh | bash
```

---

## Maintenance

### Updating Your Configuration

```bash
# Edit files in your repository
vim CLAUDE.md

# Commit and push
git add .
git commit -m "Update security guidelines"
git push

# All future installations will get the updated version!
```

### Updating Existing Projects

Create an `update.sh` script in your repository:

```bash
#!/bin/bash
echo "Updating CLAUDE.md configuration..."
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
echo "✓ Updated to latest version"
```

Users can update with:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/update.sh | bash
```

---

## Example Final Commands

Replace `YOUR_USERNAME` with your GitHub username:

### Ultra-Short with bit.ly

```bash
# Setup bit.ly shortener
# Original: https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh
# Shortened to: https://bit.ly/my-claude

# Installation becomes:
curl -fsSL https://bit.ly/my-claude | bash
```

### Team README Example

Add this to your team's documentation:

```markdown
## Setting up Claude Code

Install our standard CLAUDE.md configuration:

```bash
curl -fsSL https://bit.ly/our-claude-config | bash
```

This installs:
- Git workflow with GitHub issues
- Security guidelines
- Testing requirements
- Code quality standards
```

---

## Security Note

**Always review scripts before piping to bash!**

Good practice: Download first, review, then execute:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh -o install.sh

# Review it
cat install.sh

# Make executable and run
chmod +x install.sh
./install.sh
```

---

## Summary

1. ✅ Create public GitHub repository
2. ✅ Upload CLAUDE.md and .claude/ files
3. ✅ Create install.sh script
4. ✅ Test installation
5. ✅ Optional: Shorten URL with bit.ly or similar
6. ✅ Share one-liner with your team

**Final one-liner example:**

```bash
curl -fsSL https://bit.ly/claude-setup | bash
```

That's it! Now you can set up CLAUDE.md in any project with a single command.
