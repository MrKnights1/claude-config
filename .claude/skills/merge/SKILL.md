---
name: merge
description: Squash merge feature branch to main. Use when user says "merge to main", "squash merge", or "finish feature".
allowed-tools: Bash(git log*), Bash(git diff*), Bash(git checkout *), Bash(git merge *), Bash(git commit *)
---

Squash merge completed feature branch to main with proper commit message.

## Commit Format

| Type | Format |
|------|--------|
| Feature | `As a [role] I [action] so that [benefit]` |
| Fix | `Fix: [description]` |
| Refactor | `Refactor: [description]` |
| Style | `Style: [description]` |

## Rules

- ALWAYS include `Closes #XX` on separate line when resolving issues
- NEVER include "Co-Authored-By: Claude"
- Use detailed commit body for complex changes
- Do NOT push (user will push manually)

## Examples

```
Fix: Return proper error message for unauthorized AJAX requests
Closes #123

- Changed empty array response to include 'Authorization required' message
- Updated error handling middleware
```

```
As a student I can see my learning outcomes
Closes #80
```

## Pre-Merge Checklist

- [ ] Tests pass locally
- [ ] No linting/type errors
- [ ] No `console.log` statements left in code
- [ ] No commented-out code
- [ ] Environment variables documented in `.env.example`
- [ ] Database migrations tested (if applicable)
- [ ] API changes documented (if applicable)

## Process

1. Verify pre-merge checklist
2. Run `git log main..HEAD` to see all branch commits
3. Run `git diff main...HEAD` to see total changes
4. Check staged files - unstage any files unrelated to this merge
5. Checkout main: `git checkout main`
6. Squash merge: `git merge --squash <branch-name>`
7. Commit with HEREDOC:
   ```bash
   git commit -m "$(cat <<'EOF'
   Commit message here.

   Closes #XX
   EOF
   )"
   ```
