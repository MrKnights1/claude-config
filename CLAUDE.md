# CLAUDE.md

## Project Initialization
@.claude/project-init.md

---

---

## Verification Standards

**IMPORTANT: NEVER claim something is working, running, or accessible unless you have actually verified it**

Always verify functionality before claiming it works:
- Run the application/tests and confirm no errors
- Check actual outputs and behavior
- If verification fails, report the actual error - don't claim it works

Example: Don't say "Docker is running on port 3000" unless you ran `docker compose ps` or `docker ps` and verified the container is actually running

---

## File Placement Quick Guide

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
- When asked to init or create a project CLAUDE.md, follow @.claude/project-init.md
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

