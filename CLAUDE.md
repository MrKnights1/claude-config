# CLAUDE.md

## Project Overview

<!-- Fill in for your project -->
Brief description of what this project does.

- **Tech stack:** [e.g., Next.js, PostgreSQL, TypeScript]
- **Architecture:** [e.g., Monolith, API + SPA, Microservices]
- **Primary language:** [e.g., TypeScript, Python, Go]

---

## Development Workflow

### Claude Workflow

When asked to change project source code or database dump:

1. Ask: "Should we create a GitHub issue for this?"
2. If yes:
   - Create issue using `gh issue create` (follow templates below)
   - Create and checkout linked branch: `gh issue develop <issue-number> --checkout`
   - Implement and commit changes to branch
   - Ask: "Is there anything else you want to change, or should I squash merge this to main and close issue #XX?"
   - If changes needed: make additional commits
   - If complete:
     - Squash merge to main: `git checkout main && git merge --squash XX-short-descr`
     - Commit with proper message (see Commit Guidelines): `git commit`
     - Push to remote: `git push origin main`

**Note:** If code changes are completed first and issue is created afterwards, skip branch creation. Simply create issue with `gh issue create`, commit directly to main with `Closes #XX` in commit message.

### Issue Creation

```bash
gh issue create --title "Title" --body "Description"
```

**Feature:**
Title: `As a [role] I [can/want to] [action] so that [benefit]`
Body:
```
As a [role] I [can/want to] [action] so that [benefit]`

Acceptance criteria:
- There is a new menu item called "Logs" in the main menu
- Clicking that takes to /logs which shows a list of events
- The most recent events are on the top
```

Format: One sentence per line, start with capital, simple and testable, no numbering/Given-When-Then.

**Bug:**
Title: `[Brief description]` | Labels: `bug`
Body:
```
1. [Reproduction steps]
Expected: [What should happen]
Actual: [What happens]
```

### Implementation

- Branch: `XX-short-description` (XX = issue number)
- Search the project for existing examples and patterns before writing code (templates, pages, components, functions)
- Make commits on branch with simple, descriptive messages
- Squash merge to main when complete with proper commit message

---

## Commit Guidelines

**IMPORTANT: There are TWO separate commit workflows**

### Workflow 1: Branch Commits (Work in Progress)

Simple, descriptive messages while working on a feature branch. Commit frequently as you work.

**Examples:**
- `Add event history modal UI`
- `Implement move tracking with from/to locations`
- `Fix styling on modal dialog`

**Rules:** Keep it simple, NO "Closes #XX" needed, NO formal format required

### Workflow 2: Squash Merge to Main (Final Commit)

ONLY when squash merging completed feature to main. Creates clean history and closes the issue.

**Format:**
- Features: `As a [role] I [action] so that [benefit]\nCloses #XX`
- Fixes: `Fix: [description]\nCloses #XX`
- Refactor: `Refactor: [description]`
- Style: `Style: [description]`

**Rules:**
- ALWAYS include `Closes #XX` on separate line when resolving issues
- NEVER include "Co-Authored-By: Claude" or any Claude attribution
- Use detailed commit body for complex changes (see example below)

**Examples:**
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

**Bad commit messages (for both workflows):** `wip`, `fixed stuff`, `updates`

---

## Verification Standards

**IMPORTANT: NEVER claim something is working, running, or accessible unless you have actually verified it**

Always verify functionality before claiming it works:
- Run the application/tests and confirm no errors
- Check actual outputs and behavior
- If verification fails, report the actual error - don't claim it works

Example: Don't say "Docker is running on port 3000" unless you ran `docker compose ps` or `docker ps` and verified the container is actually running

---

## Pre-Commit Checklist

Before committing, verify:

- [ ] Tests pass locally
- [ ] No linting/type errors
- [ ] No `console.log` statements left in code
- [ ] No commented-out code
- [ ] Environment variables documented in `.env.example`
- [ ] Database migrations tested (if applicable)
- [ ] API changes documented (if applicable)

---

## Quick Reference

### Common Commands (Update for your project)
```bash
# Build, test, and dev commands go here
# Example:
# npm run dev       # Start dev server
# npm run build     # Build for production
# npm test          # Run tests
```

### File Placement Quick Guide

| File Type | Location |
|-----------|----------|
| React components | `/src/components` |
| API routes | `/src/routes` or `/src/pages/api` |
| Utility functions | `/src/lib` or `/src/utils` |
| Database models | `/src/models` |
| Types/Interfaces | `/src/types` |
| Middleware | `/src/middleware` |
| Tests | Next to file or `/tests` |
| Migrations | `/migrations` |
| Static assets (bundled) | `/src/assets` |
| Static files (served) | `/public` |

---

## Detailed Guidelines (Imported)

For comprehensive guidelines on specific topics, see:

### Security
@.claude/security.md

### Security Review Process
@.claude/security-review.md

### Testing
@.claude/testing.md

### API Design & Logging
@.claude/api-design.md

### Project Structure
@.claude/structure.md

### Database
@.claude/database.md

### Code Quality & Standards
@.claude/standards.md

---

## Error Handling Patterns

### API/Backend Errors

- Return consistent error format: `{ success: false, error: { message, code } }`
- Log errors server-side with request ID and context
- Never expose stack traces or internal details to clients
- Use appropriate HTTP status codes (400 for client errors, 500 for server errors)

### Frontend/UI Errors

- Use error boundaries to catch and display component errors gracefully
- Show user-friendly error messages (not technical details)
- Provide clear recovery actions (retry button, go back, contact support)
- Log errors to monitoring service for debugging

### Error Message Guidelines

- Be specific but not technical: "Could not save your changes" not "Database write failed"
- Suggest next steps when possible: "Please try again" or "Contact support if this continues"
- Avoid blame: "Something went wrong" not "You entered invalid data"

---

## Critical Rules Summary

### Always
- Check if Project Overview and Environment Notes sections in CLAUDE.md contain placeholder text (e.g., `[e.g.,`). If so, offer to run `/init` to auto-fill these sections by analyzing package.json, docker-compose.yml, .env.example, and project structure
- Create GitHub issues for features and bugs
- Search the project for existing examples and patterns before writing code (templates, pages, components, functions)
- Write tests for new features
- Remove console.log and commented code before committing
- Use environment variables for secrets
- Validate user input
- Use parameterized queries (prevent SQL injection)
- Design code to be modular when possible (separate concerns, reusable components)
- Use absolute paths for imports and file references within the project
- Write all code elements in English (comments, placeholders, variable names, function names, commit messages, documentation, error messages, TODOs)
- Create a todo list when entering plan mode to track tasks and progress

### Never
- Commit directly to main
- Include "Co-Authored-By: Claude" in commits
- Store secrets in code
- Modify database directly in production
- Expose error details to users
- Trust client-side validation alone
- Add fallbacks, default values, or backwards-compatibility shims unless explicitly requested

### Protected Areas

NEVER modify without explicit approval:
- Database migration files (once committed)
- `.github/workflows/*` (CI/CD configs)
- `package-lock.json` or `bun.lock` (unless updating deps)

ALWAYS ask before:
- Changing authentication/authorization logic
- Modifying database schemas
- Adding new dependencies
- Changing API contracts

---

## Environment Notes

<!-- Fill in for your project -->

### Development
- **Database:** [e.g., Local PostgreSQL on port 5432]
- **API URL:** [e.g., http://localhost:3000]
- **Auth:** [e.g., Mock auth / Local Keycloak]

### Staging
- **URL:** [e.g., staging.example.com]
- **Data:** [e.g., Anonymized production data / Seed data]

### Production
- **URL:** [e.g., app.example.com]
- NEVER run destructive commands
- All schema changes require migration review
- All changes require PR approval
