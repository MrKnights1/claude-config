# Code Quality & Standards

Universal rules for writing, reviewing, shipping, and maintaining code. For identifier naming, see `naming.md`.

---

## Code Quality

Adhere to KISS, DRY, and YAGNI: keep designs simple, eliminate duplication, and refuse to build for hypothetical futures.

- **Single responsibility.** Each function, class, or module has one reason to change. If its description needs the word "and", split it.
- **Function length.** Aim for 15–20 lines; treat 50 as the hard ceiling. Longer functions are usually doing too much.
- **File length.** Split files past ~300–400 lines into focused modules.
- **Nesting depth.** Cap at 2–3 levels. Use early returns instead of deep `if/else` pyramids.
- **Parameters.** Cap at 3–4. Group related arguments into an object.
- **Magic values.** Replace inline numbers and strings with named constants.
- **Extract conditions.** Pull complex boolean expressions into a named helper or variable.
- **Separate concerns.** Data access, business logic, and presentation live in different layers.
- **Explicit dependencies.** Pass collaborators in; avoid global mutable state.
- **Single source of truth.** Each piece of state lives in one place; everything else derives from it.
- **Composition over inheritance.** Prefer assembling behavior from small parts over deep class hierarchies.
- **No circular dependencies.** Modules that import each other belong in one module or need a third to break the cycle.
- **One abstraction level per function.** High-level orchestration code must not mix in low-level details.
- **Self-documenting code.** Names carry the intent (see `naming.md`). Add comments only when the *why* cannot be expressed in code.

---

## Definition of Done

A change is done when every item below is true. Anything skipped is reported, not silently dropped.

- [ ] Behavior matches the requirement and edge cases are handled.
- [ ] Tests for the new behavior and at least one meaningful failure mode are added and passing.
- [ ] Full relevant test suite passes locally.
- [ ] Lint and type checks pass with zero new warnings.
- [ ] Docs, `.env.example`, and migration files updated where the change affects them.
- [ ] Verified working by exercising the actual code path (CLI run, UI flow, API call) — not just by passing tests.

---

## Technical Debt

When introducing or encountering deferred work, mark it inline with a tracked issue reference:

```
TODO(#issue-number): what needs to change and why
```

### Sources of debt to recognize

- Shortcuts taken under deadline pressure.
- Code that works but is hard to change (high coupling, low cohesion, dead branches, ad-hoc patterns).
- Outdated dependencies and deprecated APIs.
- Recurring bug clusters in one area — usually a design smell, not a coding smell.
- High cyclomatic complexity, duplication rate, or churn in a single file.

---

## Performance

Apply known performance patterns; avoid known anti-patterns. Numeric production targets (Core Web Vitals, p95 latency) require real users and telemetry — out of scope for code-time decisions.

### Patterns to apply

- **Pagination.** Every list endpoint paginates and caps maximum page size.
- **Connection pooling.** Reuse connections across requests; never create one per request.
- **Caching.** Cache results of expensive, repeatable computations at the appropriate layer.
- **Code-splitting and lazy-loading.** Split per route. Defer below-the-fold work.
- **Image optimization.** Modern formats (WebP/AVIF), responsive sizes, lazy loading.
- **Indexing.** Index every foreign key and every column used in `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`.

### Anti-patterns to avoid

- **N+1 queries.** Use eager loading, joins, or batch fetching — never a query inside a loop over results.
- **Unbounded result sets.** No endpoint that can return arbitrarily many rows.
- **`SELECT *` when only some columns are read.**
- **Per-request expensive setup.** TLS handshake, DB connection, secret retrieval per request.
- **Speculative optimization.** No memoization, parallelization, or abstraction added "for performance" without a measurement showing a real hot path.

---

## Accessibility — WCAG 2.2 AA

Target WCAG 2.2 Level AA, the standard most regulations now reference.

### Required

- **Semantic HTML first.** Use `<button>`, `<nav>`, `<main>`, `<form>`, `<label>` before reaching for ARIA. Native elements carry built-in keyboard and assistive-tech support.
- **Keyboard access.** Every interactive element is reachable and operable via Tab, Shift+Tab, Enter, Space, and arrow keys where appropriate.
- **Visible focus.** The focused element is always visually distinguishable and not occluded by sticky headers, modals, or overlays.
- **Color contrast.** 4.5:1 for body text, 3:1 for large text and meaningful non-text UI (icons, focus rings, form borders).
- **Color is never the only signal.** Pair color with text, icon, or pattern.
- **Text alternatives.** Every meaningful image has `alt`; decorative images use `alt=""`.
- **Forms.** Every input has a visible, persistent `<label>`. Errors are announced to assistive tech and shown near the field. Placeholder text never replaces a label.
- **Target size.** Pointer targets are at least 24×24 CSS pixels (AA) — 44×44 is the AAA target and a safer default for touch.
- **Dragging alternatives.** Any drag interaction has a single-pointer non-drag alternative.
- **Accessible authentication.** Login flows do not require memorization-only puzzles; allow paste into password fields and offer alternatives to CAPTCHAs.
- **Reduced motion.** Honor `prefers-reduced-motion` for animations and transitions.

---

## Documentation

Keep documentation close to the code it describes and updated in the same change that alters behavior.

### README

A newcomer should be able to clone the repo and run it in under 10 minutes.

Required sections:

1. **What it is** — one or two sentences.
2. **Prerequisites** — language/runtime versions, system services.
3. **Setup** — install, environment file copy, database migrate/seed.
4. **Run** — dev server, tests, build, lint — one canonical command each.

### Other artifacts to keep in sync

- `.env.example` mirrors every variable the app reads — placeholder values only, no secrets.
- API reference (OpenAPI or equivalent) matches deployed behavior; generated from the source when possible.

---

## UI/UX Consistency

- **Spacing scale.** Pick one (e.g. 4 / 8 / 16 / 24 / 32 px) and use it everywhere. Arbitrary one-off values fragment the design.
- **Component library.** Reuse one set of primitives (buttons, inputs, modals) across the app.
- **Feedback for every action.** Loading, success, and error states are explicit — never silent.
- **Loading states.** Skeletons for content areas; spinners for in-progress actions; disable controls mid-submit; show progress for anything slow.
- **Error states.** Display the error next to the field or action that caused it, with clear recovery instructions and consistent styling.
- **Form patterns.** Labels, validation timing, and error display behave the same across every form.

---

## Error Handling

### Fail fast on programmer errors

Invariant violations, missing required config, contract breaches between modules — throw immediately and loudly. Continuing in an undefined state corrupts data and hides the root cause.

### Degrade gracefully on operational errors

Non-essential external dependency unavailable? Disable that feature, keep the rest of the app working. The fallback must be simpler and more reliable than what it replaces — usually a cache, a static value, or a default. Never fall back in a way that bypasses a security or correctness check.

### Retries

Retry only on transient failures (network timeouts, 5xx, rate limits). Use exponential backoff with jitter and a max attempt cap to avoid retry storms and thundering herds.

### User-facing messages

- Never expose stack traces, internal paths, database errors, or library names to end users.
- Return a generic, actionable message ("We couldn't complete that — try again or contact support") with a correlation/request ID.
- Log the full error with context server-side, including the same correlation ID.

### Centralized handling

Funnel errors through one handler per surface (HTTP middleware, top-level UI boundary, background-job wrapper). Per-call try/catch is for cases the surrounding code can actually recover from.

---

## Code Cleanup

After every change — feature, fix, refactor — remove what is no longer needed and update what drifted.

### Remove

- Unused imports, variables, functions, classes, files.
- Commented-out code (git history is the archive).
- Debug print/log statements left from development.
- Dead branches and unreachable code.
- Unused CSS classes and assets.
- Completed `TODO` markers.

### Update

- Outdated comments and docstrings.
- `.env.example` when variables are added or removed.
- Type signatures and downstream callers.
- Tests when behavior intentionally changes.

### Verify

- Linter passes with zero new warnings.
- Dependency check (e.g. `depcheck` or equivalent) shows no unused packages.
- Full test suite passes.
- Final review of `git diff` before committing.

---

## Error Class Pattern (language-neutral)

Define one application error type that carries:

- A stable machine-readable code (e.g. `NOT_FOUND`, `VALIDATION_ERROR`).
- A short, safe-to-display message intended for end-user surfaces.
- A status code or category for the transport layer to map.
- Optional context (request ID, offending field).

Throw it from business logic. Catch it in the centralized handler, log with full context, render the safe message to the caller.
