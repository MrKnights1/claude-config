---
name: commit
description: Create a git commit. Use when user says "commit", "save changes", or "commit my work".
---

Create a simple, descriptive commit on the current branch.

## Commit Format

| Type | Format |
|------|--------|
| Feature | `As a [role] I [action] so that [benefit]` |
| Fix | `Fix: [description]` |
| Refactor | `Refactor: [description]` |
| Style | `Style: [description]` |

## Rules

- Simple descriptive message
- NEVER include "Co-Authored-By: Claude"
- NEVER include "Closes #XX"
- Do NOT push (only add and commit)
- Do NOT ask about creating issues - just commit

## Examples

```
Add event history modal UI
```

```
Implement move tracking with from/to locations
```

```
Fix styling on modal dialog
```

Bad: `wip`, `fixed stuff`, `updates`

## Pre-Commit Checklist

- [ ] Tests pass locally
- [ ] No linting/type errors
- [ ] No `console.log` statements left in code
- [ ] No commented-out code
- [ ] Environment variables documented in `.env.example`
- [ ] Database migrations tested (if applicable)
- [ ] API changes documented (if applicable)

## Process

1. Run `git status` and `git diff` to review changes
2. Verify pre-commit checklist
3. Check staged files - unstage any files unrelated to this commit
4. Stage specific files (avoid `git add -A`)
5. Commit with simple descriptive message
6. Run `git status` to verify
