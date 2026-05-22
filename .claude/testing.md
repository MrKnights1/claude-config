# Testing Requirements

## First-time Setup

If the project has no testing harness yet, do not write ad-hoc test scripts — set up a real framework first. Once committed, every future change has somewhere to land its tests and CI catches regressions automatically.

1. **Pick the standard framework for the stack.** Use the built-in test runner if one exists; otherwise use the dominant community framework. Do not invent.
2. **Add a top-level `test` command** wired into the project manifest so a single canonical command runs the suite.
3. **Create the directory layout and commit one green example test** that imports a real module from the source tree. This proves the harness can find, compile, and run code from the project — not just a hello-world in isolation.
4. **Offer (do not auto-install) a pre-push test hook.** A failing test should block the push locally rather than waiting for CI. Ask first; install only on approval.
5. **Document the test command in `README.md`** and add any test-only environment variables to `.env.example`.

Only after these five steps are committed does the test for the original change get written.

---

## FIRST Principles

Every unit test satisfies all five:

| Principle | Meaning |
|-----------|---------|
| **Fast** | Runs in milliseconds. Slow tests get run less and trusted less. |
| **Independent** | No ordering, no shared state with other tests. Any subset must pass in any order. |
| **Repeatable** | Same input, same result, every environment, every run. No randomness, no clock, no network. |
| **Self-validating** | Pass/fail is automatic. No logs to read, no images to eyeball. |
| **Timely** | Written alongside the production code, not weeks later. |

---

## Test What the Code Does, Not How It Does It

Assert on outputs, side effects, and externally observable state — never on internal calls, private fields, or implementation structure.

| Bad | Good |
|-----|------|
| Assert that `formatPrice` called `Math.round` | Assert that `formatPrice(1.235)` returns `"1.24"` |
| Spy on the internal cache to confirm a hit | Assert the second call returns the same value without re-querying |
| Read a private field after the action | Assert on the public method whose contract depends on that field |

A test that breaks during a pure refactor is testing implementation. A test that survives a pure refactor and fails only when behavior changes is testing behavior.

---

## AAA Structure

Every test has three phases, visually separated:

1. **Arrange** — set up inputs, fixtures, and collaborators
2. **Act** — invoke the single behavior under test
3. **Assert** — verify the outcome

One Act per test. Multiple Acts hide which step failed and what the test actually proves.

---

## Test Naming

Test names describe the scenario and the expected outcome, not the method called.

| Bad | Good |
|-----|------|
| `test_login` | `login_with_invalid_password_returns_401` |
| `test_calculate` | `calculateTotal_returns_zero_for_empty_cart` |
| `it works` | `rejects_negative_quantities_with_validation_error` |

Either `methodName_doesX_whenY` or `given_X_when_Y_then_Z` is acceptable. Pick one per project and stay consistent.

---

## Test Shape

The default distribution is roughly 70% unit, 20% integration, 10% end-to-end — many cheap fast tests, fewer slow expensive ones. Other shapes (testing trophy, honeycomb) are valid for projects dominated by integration concerns (microservices, UI-heavy apps), but the principle holds: catch each bug at the cheapest layer that can catch it.

| Layer | Answers | Speed | Quantity |
|-------|---------|-------|----------|
| Unit | "does this function do what is expected?" | ms | many |
| Integration | "do these components work together?" | 10s–100s of ms | fewer |
| End-to-end | "does this user flow actually work?" | seconds | fewest |

---

## What to Test, What to Skip

Test:
- Pure functions, business logic, calculations, data transformations
- Validation, parsing, encoding/decoding
- State transitions and reducers
- Error paths and edge cases (empty, null, boundary, malformed, oversized)
- Public APIs and contracts

Skip:
- Framework internals — already tested upstream
- Third-party library behavior — not the code under test
- Trivial getters/setters with no logic
- Generated code and pure configuration

---

## Real Code, Mocked Boundaries

Tests must exercise the actual code under test. The thing being tested is the *target*; the things around it (network, DB, clock, filesystem, third-party APIs) are *boundaries* and may be replaced with test doubles.

| Rule | Reason |
|------|--------|
| Import the real target from the source tree | A redefined copy in the test file proves nothing |
| Mock boundaries, not the target | Mocking the target tests the mock |
| Do not mock what is not owned | Wrap third-party APIs in an internal adapter, then mock the adapter |
| Mocking most of the target's collaborators is a design smell | Fix the coupling, do not paper over it with mocks |

### Test Doubles — Pick the Weakest One That Works

| Double | Use when |
|--------|----------|
| **Stub** | The test needs canned return values from a collaborator; state verification |
| **Fake** | A working in-memory substitute (in-memory DB, in-memory queue) is cheaper than the real thing |
| **Spy** | The test needs to verify a call happened without changing the return |
| **Mock** | The test must assert on interactions (behavior verification) |
| **Dummy** | A parameter is required but never used |

Prefer stubs and fakes over mocks. Mocks couple tests to call patterns and break under refactors.

---

## Determinism — Eliminate Sources of Flakiness

Every flaky test has a root cause. Retries hide flakiness; they do not fix it, and they let unreliable tests rot the signal of the suite.

| Source of flakiness | Fix |
|---------------------|-----|
| Clock (`now`, dates, timers) | Inject a clock; freeze time in the test |
| Randomness (UUIDs, random IDs) | Seed the PRNG, or inject a generator |
| Network | Stub at the boundary, or use a hermetic test container |
| Shared mutable state across tests | Reset between tests; never rely on test order |
| Hardcoded sleeps / timeouts | Wait for explicit conditions, not wall-clock duration |
| Order dependence | Randomize test order in CI to surface hidden coupling |
| Parallel collisions on shared resources | Give each test a unique namespace (schema, key prefix, temp dir) |

Quarantine a test that flakes; do not retry it into green. Track quarantined tests and fix them — a permanent quarantine is a deleted test in disguise.

---

## Test Isolation

Each test sets up its own state and cleans up after itself. No test depends on another test having run first.

- Reset shared state (DB, caches, in-process singletons, env vars) between tests
- Prefer transaction-per-test with rollback for DB integration tests — fast, automatic cleanup, no order dependence
- For DBs without transactional rollback support, truncate or restore between tests
- Never run tests against production or shared development databases — use a dedicated test database, ideally containerized

---

## Fixtures and Factories

| Approach | Use when |
|----------|----------|
| **Fixture (static data)** | Reference data shared across many tests; rarely changes |
| **Factory (function that builds data)** | Test-specific records; each test customizes only the fields it cares about |

Factory rules:
- Build the minimum valid object by default; override per test
- Keep relevant data visible in the test — values the test asserts on must appear in the test, not be buried in a shared fixture (the "Mystery Guest" anti-pattern destroys readability)
- Randomize irrelevant fields so tests do not accidentally couple to them; keep randomness seeded and reproducible

---

## Coverage

Coverage measures execution, not correctness. A 100% covered function can still be wrong.

- Target meaningful coverage of branches, error paths, and boundaries — not a number
- Treat coverage as a floor that signals untested areas, not a ceiling worth gaming
- Reasonable defaults: ~60% acceptable, ~75% commendable, ~90% exemplary for critical modules
- Never write assertion-free tests, empty try/catch, or duplicated tests to hit a target

---

## Anti-patterns to Avoid

| Smell | Why it hurts |
|-------|-------------|
| **Assertion Roulette** | Multiple unrelated assertions in one test — failure does not point to a cause |
| **Mystery Guest** | Critical data lives in an external file or shared fixture — the test cannot be read in isolation |
| **Conditional Logic in Tests** | `if`/loops in tests hide what is actually being tested; a test should describe one path |
| **Test Interdependence** | Test B passes only because test A ran first — fragile and order-sensitive |
| **Sleeping for Time** | Hardcoded waits flake under load; wait for conditions instead |
| **Mocking the Target** | Tests the mock, not the code |
| **Over-mocking Collaborators** | Tests pass even when integration is broken |
| **Snapshot Bloat** | Large auto-updated snapshots become rubber-stamps; no one reviews the diff |

---

## Snapshot Testing

Snapshots detect *change*, not *correctness*. Use only when:
- The output is stable and well-defined
- The diff is small enough that a reviewer will actually read it
- The CI is configured to fail (not auto-create) on missing snapshots

Avoid wide DOM snapshots, huge serialized structures, or anything a reviewer will bulk-update without reading. Treat snapshot files as code subject to review.

---

## CI Strategy

Run cheapest checks first; fail fast.

1. Lint and static analysis
2. Unit tests
3. Integration tests
4. End-to-end tests

Rules:
- Every PR runs the suite; failure blocks merge
- Tests run in parallel — surface hidden coupling, do not paper over it
- Each parallel worker uses isolated resources (own DB schema, own temp dir, own port range)
- Do not auto-retry to mask flakiness; quarantine and fix instead
- Randomize test order to detect order dependence
- Cache dependencies; never cache test results across commits

---

## Performance Tests (when needed)

For performance-critical paths only:
- Define an explicit budget (latency, throughput, memory)
- Assert against the budget; do not just measure
- Run on consistent hardware (CI containers, not laptops) to avoid noise
- Treat performance regressions as test failures, not warnings

---

## Edge Cases — Always Probe These

**Input shape:** empty, null/undefined, wrong type, boundary values (0, -1, max), unicode, very long, malformed.

**State and timing:** empty state, concurrent operations, race conditions, retries, timeouts, partial failures.

**Errors:** network failure, dependency unavailable, auth failure, permission denied, not found, rate limited.
