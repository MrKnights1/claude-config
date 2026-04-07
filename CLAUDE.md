# CLAUDE.md

## Project Initialization
@.claude/project-init.md

---

## Verification Standards

**IMPORTANT: NEVER claim something is working, running, or accessible unless you have actually verified it**

Always verify functionality before claiming it works:
- Run the application/tests and confirm no errors
- Check actual outputs and behavior
- If verification fails, report the actual error - don't claim it works

Example: Don't say "Docker is running on port 3000" unless you ran `docker compose ps` or `docker ps` and verified the container is actually running

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

## Critical Rules Summary

### Always
- When asked to init or create a project CLAUDE.md, follow @.claude/project-init.md
- Create GitHub issues for features and bugs
- Search the project for existing examples and patterns before writing code (templates, pages, components, functions)
- Write tests for new features
- Remove console.log and commented code before committing
- Design code to be modular when possible (separate concerns, reusable components)
- Use absolute paths for imports and file references within the project
- Write all code elements in English (comments, placeholders, variable names, function names, commit messages, documentation, error messages, TODOs)

### Never
- Modify database directly in production
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

