---
name: issue
description: Create a GitHub issue and check out a branch for it. Use when user says "create issue", "report bug", "new feature request", or "open issue".
---

Create a GitHub issue using the `gh` CLI.

## Issue Format

| Type | Title Format |
|------|--------------|
| Feature | `As a [role] I [action] so that [benefit]` |
| Bug | `[Brief description]` (add label: `bug`) |

## Feature Issue

```bash
gh issue create --title "As a [role] I [action] so that [benefit]" --body "$(cat <<'EOF'
As a [role] I [action] so that [benefit]

Acceptance criteria:
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
EOF
)"
```

**Acceptance Criteria Format:**
- One sentence per line
- Start with capital
- Simple and testable
- No numbering/Given-When-Then

## Bug Issue

```bash
gh issue create --title "[Brief description]" --label "bug" --body "$(cat <<'EOF'
1. [Reproduction steps]

Expected: [What should happen]
Actual: [What happens]
EOF
)"
```

## Examples

Feature:
```
Title: As a student I can see my learning outcomes so that I can track progress
Body:
As a student I can see my learning outcomes so that I can track progress

Acceptance criteria:
- There is a new menu item called "Outcomes" in the main menu
- Clicking that takes to /outcomes which shows a list of outcomes
- The most recent outcomes are on the top
```

Bug:
```
Title: Login button unresponsive on mobile
Body:
1. Open app on mobile device
2. Enter credentials
3. Tap login button

Expected: User is logged in
Actual: Nothing happens, button does not respond
```

## Rules

- NEVER skip or shortcut — when invoked, always execute the full process above
- NEVER create an issue without first verifying gh auth and the target repo
- If a similar issue exists, surface it to the user instead of silently creating a duplicate

## Process

> NOTE: shell variables do not persist across separate Bash tool calls. Record the issue number in conversation/memory after step 5 and substitute the literal value into step 6.

1. **Pre-flight checks**:
   - `gh auth status` — fail with clear message if not authenticated
   - `gh repo view --json nameWithOwner` — confirm correct repo before creating
2. Determine issue type (feature or bug)
3. **Draft the title and body** following the format above
4. **Check for duplicates**: extract 2-3 distinctive nouns/verbs from the drafted title (e.g. from "As a teacher I can see event history" → `teacher event history`), then run `gh issue list --search "<terms>" --state all`. If a similar issue exists (open or closed), surface it to the user before creating. Closed matches: report as "previously reported and closed."
5. Create the issue and capture the number from the returned URL. Record the number in conversation for step 6:
   ```bash
   ISSUE_URL=$(gh issue create --title "..." --body "...")
   ISSUE_NUM="${ISSUE_URL##*/}"
   echo "$ISSUE_NUM"
   ```
6. **Dirty-tree check + branch creation**: run `git status --porcelain`. If non-empty, warn the user and ask whether to stash, proceed with `--checkout` anyway, or skip checkout. Then run one of:
   - `gh issue develop <number> --checkout` (default — branch is created and checked out)
   - `gh issue develop <number>` (if user opted out of checkout — branch created but not checked out)
7. If checkout happened, report the new branch name to the user so they know their checkout changed. If checkout was skipped, tell the user the branch was created but they remain on their current branch.
