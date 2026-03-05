# CLAUDE.md Configuration

Standard CLAUDE.md configuration for Claude Code projects with modular guidelines following official Anthropic best practices.

## ⚡ Quick Install

### Option 1: Official GitHub URL (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh | bash
```

### Option 2: Shortened URL (Convenient)

```bash
curl -fsSL https://bit.ly/47KeOMh | bash
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

The installer is interactive — it will ask whether to install globally or for the current project.

---

## 📦 What's Included

```
claude-config/
├── CLAUDE.md                  # Main config (optimized)
└── .claude/                   # Modular guidelines
    ├── security.md           # Security best practices
    ├── security-review.md    # Security review process
    ├── testing.md            # Testing requirements
    ├── api-design.md         # API & logging standards
    ├── structure.md          # Project structure conventions
    ├── database.md           # Database & migration guidelines
    ├── standards.md          # Code quality & cleanup rules
    ├── project-init.md       # Project CLAUDE.md initialization guide
    └── skills/               # Invocable skills
        ├── commit/SKILL.md   # /commit - create git commits
        ├── merge/SKILL.md    # /merge - squash merge to main
        ├── issue/SKILL.md    # /issue - create GitHub issues
        └── review/SKILL.md   # /review - brutally honest code review
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

✅ **Invocable Skills**
- `/commit` - Create git commits with proper format
- `/merge` - Squash merge feature branches to main
- `/issue` - Create GitHub issues (features & bugs)
- `/review` - Brutally honest code review (2 parallel reviewers)

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

---

## 🔧 Installation Links Summary

| Method | Command |
|--------|---------|
| **GitHub URL (curl)** | `curl -fsSL https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh \| bash` |
| **GitHub URL (wget)** | `wget -qO- https://raw.githubusercontent.com/MrKnights1/claude-config/main/install.sh \| bash` |
| **Shortened (curl)** | `curl -fsSL https://bit.ly/47KeOMh \| bash` |
| **Shortened (wget)** | `wget -qO- https://bit.ly/47KeOMh \| bash` |
| **Git Clone** | `git clone https://github.com/MrKnights1/claude-config.git` |

---

## 💡 Tips

1. **Use the `#` key** in Claude Code to quickly update CLAUDE.md during development
2. **Commit CLAUDE.md changes** with your feature commits so the team benefits
3. **Share with your team** - Use official GitHub URL or shortened link (`https://bit.ly/47KeOMh`)
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

## 🎮 Using Skills

Skills are invoked with slash commands in Claude Code:

```
/commit          # Create a git commit
/merge           # Squash merge to main
/issue           # Create a GitHub issue
/review          # Brutally honest code review
```

Skills provide structured workflows that Claude follows automatically.

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
- **Shortened Install** (alternative): https://bit.ly/47KeOMh
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code

---

**Made for Claude Code following official Anthropic best practices.**
