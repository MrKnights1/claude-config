# CLAUDE.md Configuration Repository

This directory contains a production-ready CLAUDE.md configuration following official Claude Code best practices.

## What's Here

```
prompts&modes/
├── CLAUDE.md                              # Main config (200 lines)
├── .claude/                               # Modular guidelines
│   ├── security.md                        # Security best practices
│   ├── testing.md                         # Testing requirements
│   ├── api-design.md                      # API & logging standards
│   ├── structure.md                       # Project structure
│   ├── database.md                        # Database & migrations
│   └── standards.md                       # Code quality & cleanup
├── install.sh                             # GitHub-based installer
├── GITHUB_SETUP_GUIDE.md                  # Full setup instructions
├── CLAUDE_MD_BEST_PRACTICES_OFFICIAL.md   # Best practices reference
└── CLAUDE_MD_IMPROVEMENTS.md              # Original improvement analysis
```

## Quick Start: 3 Options

### Option 1: Use in Current Project (Simplest)

Just copy the files to any project:

```bash
# From any project directory
cp /root/projektid/prompts\&modes/CLAUDE.md .
cp -r /root/projektid/prompts\&modes/.claude .
```

### Option 2: Create GitHub Repository (Recommended)

Set up a public GitHub repo so you can install with one command in all your projects:

1. **Follow the guide:** Read `GITHUB_SETUP_GUIDE.md`
2. **Create repo:** `gh repo create claude-config --public`
3. **Upload files:** Push CLAUDE.md and .claude/ to the repo
4. **Create install.sh:** Add the installer script
5. **Done!** Now install anywhere with:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

### Option 3: Shorten the URL

After setting up GitHub repo:

1. Go to https://bit.ly
2. Shorten your install.sh URL
3. Get something like: `https://bit.ly/my-claude`

Now install with:

```bash
curl -fsSL https://bit.ly/my-claude | bash
```

## What Makes This Special

✅ **Follows Official Best Practices**
- Main file: exactly 200 lines (recommended 100-200)
- Modular design with imports
- Concise and scannable

✅ **Comprehensive Coverage**
- Git workflow with GitHub issues
- Security guidelines (XSS, SQL injection, auth)
- Testing requirements
- API design standards
- Database migration best practices
- Code quality & cleanup rules

✅ **Production-Ready**
- Used and tested
- Easy to customize
- Team-friendly

## Customization

After installing in a project:

1. **Update Common Commands** in `CLAUDE.md`:
   ```bash
   # Replace example commands with your actual commands
   npm run dev       # or: bun dev, yarn dev, etc.
   npm run build
   npm test
   ```

2. **Adjust guidelines** in `.claude/` files for your tech stack

3. **Commit to git** so your team benefits

## How It Works

The `@.claude/security.md` syntax in CLAUDE.md automatically imports those files into Claude's context. When Claude Code starts, it loads:

- Your main CLAUDE.md (200 lines of essential rules)
- All imported files from .claude/ directory (detailed guidelines)

This gives Claude complete context while keeping the main file scannable.

## Best Practices Reference

See `CLAUDE_MD_BEST_PRACTICES_OFFICIAL.md` for:
- Official recommendations from Anthropic
- Length guidelines (100-200 lines)
- When to use imports
- The `#` key feature
- Common mistakes to avoid
- Testing effectiveness

## File Sizes

```
CLAUDE.md               5.9K  (200 lines)
.claude/security.md     3.1K  (security guidelines)
.claude/testing.md      1.6K  (testing requirements)
.claude/api-design.md   2.9K  (API & logging)
.claude/structure.md    3.3K  (project structure)
.claude/database.md     2.5K  (database best practices)
.claude/standards.md    2.5K  (code quality)
-----------------------------------
Total:                 ~22K  (well within recommended limits)
```

## Examples

### Install in New Project

```bash
mkdir my-new-project
cd my-new-project

# Copy from this template
cp /root/projektid/prompts\&modes/CLAUDE.md .
cp -r /root/projektid/prompts\&modes/.claude .

# Initialize git
git init
git add CLAUDE.md .claude/
git commit -m "Add CLAUDE.md configuration"

# Start coding with Claude!
claude
```

### Update Existing Project

```bash
cd existing-project

# Copy files
cp /root/projektid/prompts\&modes/CLAUDE.md .
cp -r /root/projektid/prompts\&modes/.claude .

# Review and customize
vim CLAUDE.md

# Commit
git add CLAUDE.md .claude/
git commit -m "Add CLAUDE.md configuration for Claude Code"
```

## GitHub Repository Setup

**Full instructions:** See `GITHUB_SETUP_GUIDE.md`

**Quick version:**

```bash
# 1. Create repository
gh repo create claude-config --public

# 2. Push these files
cd /root/projektid/prompts\&modes
git init
git add CLAUDE.md .claude/ install.sh SETUP_README.md GITHUB_SETUP_GUIDE.md
git commit -m "Initial CLAUDE.md configuration"
git remote add origin https://github.com/YOUR_USERNAME/claude-config.git
git push -u origin main

# 3. Update install.sh with your GitHub username

# 4. Test it works
cd /tmp/test
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-config/main/install.sh | bash
```

## URL Shortening Services

Create memorable install commands:

| Service | URL | Registration |
|---------|-----|--------------|
| [bit.ly](https://bit.ly) | `https://bit.ly/your-name` | Required (free) |
| [is.gd](https://is.gd) | `https://is.gd/your-name` | None needed |
| [TinyURL](https://tinyurl.com) | `https://tinyurl.com/your-name` | Optional |
| [git.io](https://git.io) | `https://git.io/your-name` | GitHub only |

**Example:**

Original:
```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/claude-config/main/install.sh | bash
```

Shortened:
```bash
curl -fsSL https://bit.ly/my-claude | bash
```

## Maintenance

### Updating the Configuration

```bash
# Edit files
vim CLAUDE.md
vim .claude/security.md

# Commit to your GitHub repo
git add .
git commit -m "Update security guidelines"
git push

# Now all future installations get the update automatically!
```

### Versioning

Create branches for different configurations:

```bash
git checkout -b react      # React-specific config
git checkout -b nodejs     # Node.js-specific config
git checkout -b python     # Python-specific config
```

Install specific version:
```bash
curl -fsSL https://raw.githubusercontent.com/YOU/claude-config/react/install.sh | bash
```

## Tips

1. **Use the `#` key** in Claude Code to quickly update CLAUDE.md
2. **Commit CLAUDE.md changes** with your feature commits
3. **Share with your team** via shortened URL
4. **Customize per project** but keep core rules consistent
5. **Review periodically** - remove what doesn't improve Claude's output

## Questions?

- **Best practices:** See `CLAUDE_MD_BEST_PRACTICES_OFFICIAL.md`
- **Setup help:** See `GITHUB_SETUP_GUIDE.md`
- **Improvements:** See `CLAUDE_MD_IMPROVEMENTS.md`

## License

Free to use in all your projects. No attribution needed.

---

**Made for Claude Code following official Anthropic best practices.**
