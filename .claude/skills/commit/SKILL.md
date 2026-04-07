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
- NEVER include "Closes #XX" (the merge skill adds this when squash-merging — commits are intermediate)
- Do NOT push (only add and commit)
- Do NOT ask about creating issues - just commit
- NEVER skip or shortcut — when invoked, always execute the full process above

## Examples

```
As a teacher I can see event history so that I can track changes
```

```
Fix: Return proper error message for unauthorized requests
```

```
Refactor: Extract payment processing to service
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
2. **No-changes guard**: if `git status --porcelain --untracked-files=no` is empty (no tracked modifications), exit cleanly with "nothing to commit" — do not create an empty commit. If only untracked files exist, ask the user whether to add them before proceeding.
3. **Note current branch**: surface `git rev-parse --abbrev-ref HEAD` so the user sees where the commit will land
4. Verify pre-commit checklist
5. Stage specific files (avoid `git add -A`)
6. Review the staged set with `git diff --cached --stat` and unstage anything unrelated to this commit
7. **Staged-set guard**: run `git diff --cached --quiet` — if it returns 0 (nothing staged), exit cleanly with "nothing staged to commit"
8. Commit with simple descriptive message
9. Run `git status` to verify
