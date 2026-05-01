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

## Assumption Discipline

Most wrong answers come from reasoning off a mental model when the actual fact is one tool call away. Default to checking, not assuming.

- **Read before reasoning.** When the truth lives in a spec, file, schema, log, env var, command output, or config — read it. Don't reason about how something "probably" works when the authoritative source exists and is reachable.
- **A surprise means you assumed wrong, not that the system is exotic.** When observed behavior contradicts your hypothesis, the first move is "re-check the assumption" — re-read the spec, re-run the query, look at the actual file. Don't invent a new mechanism that protects the original story.
- **"Are you sure?" from the user is a signal to re-verify, not to defend.** When the user pushes back, that is the prompt to re-read what you should have read more carefully the first time. Don't double down.
- **Cite the source, or mark the claim as a guess.** Any claim about how the system works needs a citation (file:line, doc URL, command output, schema). If you cannot cite, say so explicitly: "I'm guessing — let me check."
- **Hedge words are a self-check signal.** When you catch yourself writing "probably", "usually", "I think", "should", or "tends to" about how the system works, either verify and remove the hedge, or explicitly mark the claim as unverified pending a check.

---

## Completion Discipline

Most "stopped early" failures come from declaring done before checking the work against the ask. The work isn't done when the edit lands — it's done when the ask is satisfied and you can show it. See the task through to a complete answer rather than stopping partway.

- **Mark complete on actual execution, not intent.** Map every ask to evidence (file:line, command output, test result, observed behavior) and state what you verified. If you can't verify it, don't ship it.
- **Don't assume the outcome of a tool call or edit.** Re-read the file you changed, run the build / typecheck / tests if applicable, check the actual output. The Edit succeeding is not the same as the change being correct.
- **Verify behavior, not surface.** "Add tests" implies the tests pass. "Fix the bug" implies the cause is gone, not the symptom suppressed. "Refactor X" implies X still works after.
- **Don't trade silently.** If you decided to skip, defer, or substitute part of the ask, say so directly and say why. When uncertain, leave it open and say so — under-reporting beats over-reporting.
- **Surface ambiguity instead of guessing.** If the prompt is unclear about scope or shape, ask before shipping. A short prompt is not an excuse for a shallow read; multi-verb prompts are multi-ask prompts.
- **A check's result is not its coverage — state both in the same sentence as the verdict.** "Tests pass" is not verifiable; "47/47 tests across src/ and tests/ pass" is. "Grep found nothing" is not verifiable; "grep across src/, tests/, scripts/ returned 0" is. If the check covered less than the claim ("done", "fixed", "all X updated"), the claim is wrong — narrow the claim or widen the check. Sample-checking is fine during work, never as proof of completeness.
- **When the check can be scripted, script it and let exit code be the evidence.** For sweeps, migrations, bulk transforms, renames, anonymization, codemods: write a verifier that fails loudly on any miss (grep that must return 0, script with non-zero exit, expected-vs-actual count) and run it. An eyeballed sample is not equivalent to a verifier that would catch one slipped case in a hundred.

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

