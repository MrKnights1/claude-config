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
- **`Closes #XX` is branch-dependent** — decided in Process step 4:
  - On a **feature branch**: NEVER include it. The merge skill adds `Closes #XX` when squash-merging; branch commits are intermediate.
  - On **`main`/`master`**: the job was completed without a branch, so no merge will follow and this commit is the final landing. Include `Closes #XX` for the associated issue (if one exists) so the issue still closes.
- NEVER push — stage and commit only. Pushing is always the user's manual action.
- NEVER auto-commit — never commit as a side effect of other work, and never commit directly to `main`/`master` without passing the confirmation gate in Process step 9. Committing only happens when this skill is explicitly invoked.
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

> NOTE: shell variables do not persist across separate Bash tool calls. Record the branch name (step 3) and any issue number (step 4) in conversation and substitute the literal values into later commands.

1. Run `git status` and `git diff` to review changes
2. **No-changes guard**: if `git status --porcelain --untracked-files=no` is empty (no tracked modifications), exit cleanly with "nothing to commit" — do not create an empty commit. If only untracked files exist, ask the user whether to add them before proceeding.
3. **Determine current branch**: run `git rev-parse --abbrev-ref HEAD` and record it. Surface it so the user sees where the commit will land. This decides the `Closes #XX` rule (step 4) and whether the confirmation gate applies (step 9).
4. **Decide `Closes #XX`** from the branch in step 3:
   - **Feature branch** (anything other than `main`/`master`): no `Closes` line — the merge skill adds it later. Draft a single descriptive line.
   - **`main`/`master`, or detached `HEAD`** (job finished without a branch — no merge will run, so this commit must close the issue itself):
     - Identify the issue number: first check the conversation for an issue just created or referenced; if none is known, ask the user "Does this commit close an issue? Which number? (reply 'none' if not)".
     - If a number is given, draft a multi-line message with `Closes #<num>` on its own line after a blank line.
     - If 'none', draft a normal single-line message (no `Closes`).
5. Verify pre-commit checklist
6. Stage specific files (avoid `git add -A`)
7. Review the staged set with `git diff --cached --stat` and unstage anything unrelated to this commit
8. **Staged-set guard**: run `git diff --cached --quiet` — if it returns 0 (nothing staged), exit cleanly with "nothing staged to commit"
9. **Confirmation gate (`main`/`master` only)**: show the user the exact drafted commit message and the staged file list, and wait for explicit approval before committing — never auto-commit directly to `main`/`master`. On a feature branch, skip this gate: the skill invocation is the go-ahead.
10. Commit:
    - Feature branch (single line): `git commit -m "message"`
    - `main`/`master` with a `Closes` line — use the HEREDOC below, substituting the drafted message. The terminator `EOF` MUST be at column 0:
      ```bash
      git commit -m "$(cat <<'EOF'
      Commit message here.

      Closes #XX
      EOF
      )"
      ```
11. Run `git status` to verify. NEVER push — leave pushing to the user.
