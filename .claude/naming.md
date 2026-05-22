# Naming Conventions

## Core principle

**Names communicate intent. Make them specific, and as long as they need to be — clarity beats brevity every time.**

If a name doesn't describe what the identifier is for on its own — without context from the surrounding code — it's not specific enough. Lengthen it.

Short, vague names — `data`, `temp`, `process`, `handle`, `util`, `info`, `obj`, `val`, `result`, `flag`, `status` — are almost always a mistake. They communicate nothing about what the identifier actually represents.

Spell words out instead of abbreviating. Mangled abbreviations (`crDt`, `usrPrf`, `acctBal`) impede grep, autocomplete, and search. Use the full words (`currentDate`, `userProfile`, `accountBalance`).

---

## Functions

Functions **do** something. The name answers **what does it do?** — verb first, then the noun it acts on.

| Bad | Good |
|-----|------|
| `calc()` | `calculateInvoiceTotal()` |
| `process(data)` | `parseUserSignupPayload(data)` |
| `handle()` | `handleSubmitButtonClick()` |
| `save()` | `savePendingOrderToDatabase()` |
| `getStuff()` | `getActiveSubscriptionsForUser()` |
| `doIt()` | `transferFundsBetweenAccounts()` |
| `check(user)` | `userHasUnverifiedEmail(user)` |

Rules:
- If the name needs `and`/`or` or contains multiple verbs (`validateAndSaveUser`, `fetchAndParseConfig`), the function is doing too much — split it. Long names made of *modifiers* qualifying one verb (`calculateProRatedMonthlyInvoiceTotal`) are fine; long names made of *multiple verbs* are not.
- Functions that return a boolean get a boolean prefix: `is`, `has`, `can`, `should`, `was`, `did`, `will` — e.g. `isValidEmail()`, `hasPaymentMethod()`, `canEditPost()`, `shouldRetry()`.
- Avoid negated booleans (`isNotReady`, `hasNoOrders`) — use the positive form instead (`isInvalid` over `isNotValid`). Double negatives are hard to parse, especially inside conditionals.
- Follow the language's standard identifier casing for function names, and apply it consistently. Most languages use either `camelCase` or `snake_case`; match what the project's stack expects.

---

## Variables

Variables **hold** something — name them as nouns that answer **what is it?** (not what type it is).

| Bad | Good |
|-----|------|
| `data` | `pendingOrders` |
| `arr` | `selectedUserIds` |
| `obj` | `parsedConfig` |
| `temp` | `mergedAddressLine` |
| `list` | `failedRetryAttempts` |
| `val` | `enteredCouponCode` |
| `info` | `customerBillingAddress` |
| `result` | `paymentVerificationOutcome` |
| `flag` | `hasUnsentChanges` |
| `status` | `paymentStatus` (paired with a domain-specific enum) |

Rules:
- Plural for collections — `users`, not `userList` / `userArray` / `arrOfUsers`.
- Don't encode the type into the name — `userArr`, `nameStr`, `priceNum` are wrong. The type system already says that.
- Boolean variables take a boolean prefix, same as boolean functions (`isActive`, `hasPermission`, `canRetry`).
- Single-letter names (`i`, `j`, `k`) only inside tight numeric loops. Never for domain values.
- True constants (values that never change for the life of the program) use **screaming snake case** — `MAX_RETRY_COUNT`, `API_BASE_URL`, `DEFAULT_TIMEOUT_MS`.
- Follow the language's standard identifier casing for variable names, and apply it consistently. Most languages use either `camelCase` or `snake_case`; match what the project's stack expects.

---

## Files

Files **do work** — name them after what they do, not what subject they cover.

| Bad | Good |
|-----|------|
| `user.js` | `UserService.js`, `validateUser.js`, `serializeUser.js` |
| `auth.js` | `validateAuthToken.js`, `AuthMiddleware.js` |
| `helpers.js` | Split it — each helper deserves its own named file |
| `utils.js` | Same — `formatDate.js`, `parseQueryString.js` |
| `index.js` (with logic) | Move logic into a named file; keep `index.*` for re-exports only |
| `exampleskill.md` | `example-skill.md` |

Casing rules:
- **Source files** — match the casing of whatever's primarily inside, using the language's identifier convention. A file that defines a single class or type takes that type's name and casing; a file containing one main function takes that function's name and casing.
- **Tests** — match the source file plus a clear test marker the project's tooling recognizes (e.g. a `.test.` or `_test` segment in the name).
- **Documentation, scripts, and configs** — use `lowercase-with-hyphens` (`api-design.md`, `deploy-staging.sh`, `prettier.config.js`). These aren't bound to a code-identifier convention, and lowercase-with-hyphens is the cross-platform standard.

`ALL_CAPS.md` is reserved for top-level project docs that tools or platforms specifically recognize: `README.md`, `CHANGELOG.md`, `LICENSE`, `CONTRIBUTING.md`, `CLAUDE.md`, `SKILL.md`. Any other doc in all caps (`IMPROVEMENTS.md`, `NOTES.md`, `TODO.md`) is wrong — use lowercase-with-hyphens.

---

## Directories

**Use lowercase directory names with hyphens between words, and be consistent across the whole project.**

`user-profiles/`, `api-client/`, `migrations/`. Lowercase avoids cross-platform case-sensitivity collisions (Windows is case-insensitive, Linux is case-sensitive — mixed-case directories silently break on one of them). Hyphens read more cleanly than underscores and behave better in URLs, grep, and command-line use. If the project already uses a different convention, match it — the consistency rule beats the convention rule.

- Plural for collections of similar things: `components/`, `hooks/`, `utils/`, `migrations/`.
- Singular for a single-purpose module: `auth/`, `database/`, `config/`.

---

## Types and classes

Types and classes **are** something — name them as nouns or noun phrases (`Customer`, `OrderProcessor`, `WikiPage`, `AddressParser`). Use **`PascalCase`** — it's the type-level identifier convention in essentially every modern language.

- Avoid vague suffixes like `Manager`, `Processor`, `Data`, `Info`, `Handler`. They communicate nothing about what the class actually does — pick a more specific name. (`UserAccountValidator` states what it is; `UserManager` doesn't.)
- Don't prefix interfaces with `I` (`IUserService`). It's a Hungarian-notation holdover; the type system already says it's an interface.
- Enum types and their members are nouns too — `OrderStatus.Pending`, `OrderStatus.Fulfilled`.
- Generic type parameters: a single `T` is fine when there's one; use descriptive names when there are several (`TUser`, `TOrder`, `TResult`).

---

## Acronyms

Treat an acronym as a single word in mixed-case identifiers — only the first letter is uppercase.

| Wrong | Right |
|-------|-------|
| `userID` | `userId` |
| `parseURL()` | `parseUrl()` |
| `HTMLParser` | `HtmlParser` |
| `APIClient` | `ApiClient` |
| `loadJSONFromS3` | `loadJsonFromS3` |
| `getHTTPSURL()` | `getHttpsUrl()` |

Why: consecutive uppercase letters obscure word boundaries. `HTTPSURLParser` is harder to parse than `HttpsUrlParser`, and clumping worsens as identifiers grow.

Exception: inside `UPPER_SNAKE_CASE` constants, acronyms stay all-caps — `API_BASE_URL`, `MAX_HTTP_RETRIES`. The whole identifier is already all caps, so there's no ambiguity.

---

## English only

All identifiers, comments, file names, commit messages, error strings, and documentation are written in English. Mixed-language names break grep, autocomplete, and consistency across the codebase.

---

## Cross-references

Naming rules that live closer to their subject — consult those when working in that area:

- **API endpoints / URL paths** — `api-design.md` § URL Structure, § RESTful Conventions
- **Database tables, columns, indexes, migration files** — `database.md` § Migration Files, § Indexing Strategy
- **Log field names** — `api-design.md` § Log Entry Format
- **Environment variable names** — `structure.md` § Environment Configuration
