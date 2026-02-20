---
name: issue
description: Create a GitHub issue. Use when user says "create issue", "report bug", "new feature request", or "open issue".
---

Create a GitHub issue using the `gh` CLI.

## Issue Format

| Type | Title Format |
|------|--------------|
| Feature | `As a [role] I [can/want to] [action] so that [benefit]` |
| Bug | `[Brief description]` (add label: `bug`) |

## Feature Issue

```bash
gh issue create --title "As a [role] I [action] so that [benefit]" --body "$(cat <<'EOF'
As a [role] I [can/want to] [action] so that [benefit]

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

## Process

1. Determine issue type (feature or bug)
2. Create issue with proper format
3. After creation, create branch: `gh issue develop <issue-number> --checkout`
