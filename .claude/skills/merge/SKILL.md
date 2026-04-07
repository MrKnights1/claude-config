---
name: merge
description: Squash merge feature branch to main. Use when user says "merge to main", "squash merge", or "finish feature".
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

- Include `Closes #XX` on separate line when an issue number was identified (merges are when issues actually close — intermediate commits omit this). If no issue is associated, omit it.
- NEVER include "Co-Authored-By: Claude"
- Use detailed commit body for complex changes
- Do NOT push (user will push manually)
- NEVER skip or shortcut — when invoked, always execute the full process above

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

> NOTE: shell variables do not persist across separate Bash tool calls. Record the branch name and issue number from steps 1-2 in conversation/memory and substitute the literal values into later commands.

1. **Branch sanity check + capture**: run `git rev-parse --abbrev-ref HEAD`. **Record the branch name in conversation memory** — shell variables do not persist across Bash tool calls, so you must substitute the literal value into later commands. If the branch is `main` or `master`, abort — you cannot merge a branch into itself.
2. **Find the issue number** (for `Closes #XX`): inspect the branch name from step 1 for a leading number (the `gh issue develop` convention is `<num>-description`), or check `git log main..HEAD` for issue references. If none found, ask the user.
3. Verify pre-merge checklist
4. Run `git log main..HEAD` to see all branch commits
5. Run `git diff main...HEAD` to see total changes
6. Checkout main: `git checkout main`
7. Squash merge using the literal branch name from step 1: `git merge --squash <branch-name>`
8. **Conflict check**: run `git status`. If any unmerged paths exist, roll back with `git reset --merge` (do NOT use `git merge --abort` — `--squash` does not create MERGE_HEAD) and report the conflicts to the user. Do not commit a broken state.
9. **Draft the commit message** using the Commit Format table above.
10. Commit with the HEREDOC below. Substitute `Commit message here.` with the drafted message from step 9. If an issue number was found in step 2, include `Closes #<num>` on its own line after a blank line. If no issue, omit the `Closes` line entirely. The HEREDOC terminator `EOF` MUST be at column 0:

```bash
git commit -m "$(cat <<'EOF'
Commit message here.

Closes #XX
EOF
)"
```
