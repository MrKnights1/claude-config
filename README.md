# CLAUDE.md Configuration

Standard CLAUDE.md configuration for Claude Code projects with modular guidelines following official Anthropic best practices.

## ⚡ Quick Install

### Option 1: Official GitHub URL (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash
```

### Option 2: Shortened URL (Convenient)

```bash
curl -fsSL http://bit.ly/47KeOMh | bash
```

### Option 3: With wget

```bash
wget -qO- https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash
```

### Option 4: Manual Clone

```bash
git clone https://github.com/MrKnights1/claude-config.git
cp claude-config/CLAUDE.md .
cp -r claude-config/.claude .
rm -rf claude-config
```

---

## 📦 What's Included

```
claude-config/
├── CLAUDE.md                  # Main config (200 lines, optimized)
└── .claude/                   # Modular guidelines
    ├── security.md           # Security best practices
    ├── testing.md            # Testing requirements
    ├── api-design.md         # API & logging standards
    ├── structure.md          # Project structure conventions
    ├── database.md           # Database & migration guidelines
    └── standards.md          # Code quality & cleanup rules
```

## ✨ Features

✅ **Follows Official Best Practices**
- Main file: 200 lines (recommended 100-200)
- Modular design with `@.claude/*.md` imports
- Concise and scannable

✅ **Comprehensive Coverage**
- Git workflow with GitHub issues
- Security guidelines (XSS, SQL injection, auth)
- Testing requirements & best practices
- RESTful API design standards
- Database migration procedures
- Code quality & cleanup rules

✅ **Production-Ready**
- Used and tested in real projects
- Easy to customize for your stack
- Team-friendly documentation

---

## 🚀 Usage

### Install in New Project

```bash
mkdir my-new-project
cd my-new-project

# Install CLAUDE.md configuration
curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash

# Initialize git
git init
git add CLAUDE.md .claude/
git commit -m "Add CLAUDE.md configuration"

# Start using Claude Code!
```

### Add to Existing Project

```bash
cd existing-project

# Install configuration
curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash

# Customize for your project
vim CLAUDE.md  # Update "Common Commands" section

# Commit
git add CLAUDE.md .claude/
git commit -m "Add CLAUDE.md for Claude Code"
```

---

## 🎯 Customization

After installation, customize for your project:

### 1. Update Common Commands (Required)

Edit `CLAUDE.md` and replace the example commands:

```bash
### Common Commands (Update for your project)
```bash
# YOUR actual commands here:
npm run dev       # Start development server
npm run build     # Build for production
npm test          # Run tests
npm run lint      # Run linter
```

### 2. Adjust Guidelines (Optional)

Review and modify files in `.claude/` directory:
- `security.md` - Add your specific security requirements
- `testing.md` - Add your testing framework specifics
- `api-design.md` - Adjust API conventions
- `structure.md` - Match your project structure
- `database.md` - Add your ORM specifics
- `standards.md` - Add team-specific standards

### 3. Commit to Repository

```bash
git add CLAUDE.md .claude/
git commit -m "Customize CLAUDE.md for project"
```

---

## 📖 How It Works

The `@.claude/security.md` syntax in CLAUDE.md automatically imports those files into Claude's context.

When Claude Code starts, it loads:
1. Your main `CLAUDE.md` (200 lines of essential rules)
2. All imported files from `.claude/` directory

This gives Claude complete context while keeping the main file scannable.

---

## 📚 Documentation

- **Installation**: This README
- **Best Practices**: See `CLAUDE_MD_BEST_PRACTICES_OFFICIAL.md` (included in this repo)
- **Setup Guide**: See `GITHUB_SETUP_GUIDE.md` (included in this repo)

---

## 🔧 Installation Links Summary

| Method | Command |
|--------|---------|
| **GitHub URL (curl)** | `curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh \| bash` |
| **GitHub URL (wget)** | `wget -qO- https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh \| bash` |
| **Shortened (curl)** | `curl -fsSL http://bit.ly/47KeOMh \| bash` |
| **Shortened (wget)** | `wget -qO- http://bit.ly/47KeOMh \| bash` |
| **Git Clone** | `git clone https://github.com/MrKnights1/claude-config.git` |

---

## 💡 Tips

1. **Use the `#` key** in Claude Code to quickly update CLAUDE.md during development
2. **Commit CLAUDE.md changes** with your feature commits so the team benefits
3. **Share with your team** - Use official GitHub URL or shortened link (`http://bit.ly/47KeOMh`)
4. **Customize per project** but keep core security/quality rules consistent
5. **Review periodically** - remove guidelines that don't improve Claude's output

---

## 🔄 Updating Your Configuration

To update CLAUDE.md in existing projects:

```bash
# Backup your customizations
cp CLAUDE.md CLAUDE.md.backup

# Reinstall latest version
curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash

# Merge your customizations back
# (especially the "Common Commands" section)
```

---

## 📊 File Sizes

```
CLAUDE.md               5.9K  (200 lines)
.claude/security.md     3.1K  (security guidelines)
.claude/testing.md      1.6K  (testing requirements)
.claude/api-design.md   2.9K  (API & logging)
.claude/structure.md    3.3K  (project structure)
.claude/database.md     2.5K  (database best practices)
.claude/standards.md    2.5K  (code quality)
-------------------------------------------
Total:                 ~22K  (well optimized)
```

---

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Fork for your own use
- Suggest improvements via issues
- Create your own variants

---

## 📝 License

Free to use in all your projects. No attribution needed.

---

## 🔗 Links

- **Repository**: https://github.com/MrKnights1/claude-config
- **Official Install**: `curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash`
- **Shortened Install** (alternative): http://bit.ly/47KeOMh
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code

---

**Made for Claude Code following official Anthropic best practices.**

Last updated: 2025-10-30
