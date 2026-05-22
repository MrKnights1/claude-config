# Security Guidelines

Anchored to OWASP ASVS v5.0.0 (May 2025) and OWASP Top 10:2025. Universal rules — no language-specific mandates.

---

## Critical Rules

### Always
- Use parameterized queries for all database operations
- Validate and encode output per context (HTML, JS, URL, attribute)
- Hash passwords with Argon2id (preferred), scrypt, or bcrypt
- Generate security tokens with a cryptographically secure PRNG (>=128 bits entropy)
- Protect state-changing requests with synchronizer-token or double-submit CSRF defense
- Set session cookies with `HttpOnly`, `Secure`, `SameSite=Lax` or `Strict`
- Enforce TLS 1.2+ (1.3 preferred); redirect HTTP to HTTPS
- Verify authorization server-side for every protected resource
- Return generic error messages; log details server-side
- Validate file uploads by parsed content type and magic bytes
- Store secrets in a secrets manager or environment variables
- Rate-limit authentication, password reset, and registration endpoints
- Require phishing-resistant MFA (FIDO2/WebAuthn passkeys) for sensitive applications
- Re-authenticate before sensitive account changes
- Use vetted cryptographic libraries (libsodium, platform crypto module, OpenSSL)
- Use authenticated encryption (AES-GCM, ChaCha20-Poly1305)
- Restrict CORS to an explicit allowlist of origins
- Sanitize untrusted input before logging to prevent log injection

### Never
- Concatenate user input into SQL, OS commands, or template strings
- Implement custom cryptography
- Use MD5, SHA-1, ECB mode, TLS <1.2, or the JWT `none` algorithm
- Log passwords, full tokens, PAN, CVV, or unmasked PII
- Send sensitive data in URLs or query strings
- Trust client-side validation or client-side authorization
- Use non-cryptographic PRNGs (e.g. Math.random) for secrets

---

## Data Protection

- Classify data (public, internal, confidential, restricted) and document handling per class.
- Encrypt restricted data at rest (AES-256-GCM) and in transit (TLS 1.2+).
- Define retention windows and automate deletion of expired records.
- Strip metadata (EXIF, document properties) from uploaded files before storage.
- Set `Cache-Control: no-store` on responses containing sensitive data.
- Set `Clear-Site-Data: "cache", "cookies", "storage"` on logout responses.
- Never share sensitive data with third-party analytics or tracking services.

---

## Secret Management

- Never put secrets in source code, config files committed to the repo, container images, or client-side code.
- Read secrets from environment variables or an external secret store at runtime.
- Use distinct credentials per environment (dev, staging, production).
- Add `.env`, `.env.*`, credential files, and key material to `.gitignore` before the first commit.

---

## Passwords (NIST SP 800-63B Rev 4)

- Minimum 15 characters when password is the sole factor; minimum 8 characters when paired with MFA.
- Accept passwords up to at least 64 characters, including spaces and all printable ASCII/Unicode.
- Do not impose composition rules (no required mixes of upper/lower/digit/symbol).
- Block known-breached and top-common passwords on set/change (HIBP API, downloaded list).
- Allow paste into password fields.
- Do not require periodic rotation; rotate only on evidence of compromise.
- Hash with **Argon2id** using `m=47104 (46 MiB), t=1, p=1` or `m=19456 (19 MiB), t=2, p=1`. If Argon2id unavailable, use scrypt, then bcrypt (cost >=12), then PBKDF2-HMAC-SHA256 (>=600k iterations).
- Never store password hints or knowledge-based security questions.

---

## Authentication

- Provide phishing-resistant MFA (FIDO2/WebAuthn passkeys, hardware security keys) as the primary second factor.
- Treat TOTP as acceptable but inferior to passkeys; treat SMS/email codes as a last-resort fallback only.
- Limit OTP lifetime: <=10 minutes for out-of-band codes, 30 seconds for TOTP.
- Return identical error messages and response times for invalid username vs invalid password (prevent account enumeration).
- Rate-limit login (5 attempts / 15 min / IP+account), password reset (3 / 15 min), registration (5 / hour / IP).
- Generate password reset and verification tokens with a CSPRNG, single-use, with short expiry (<=1 hour).
- Password reset must not bypass MFA.
- Re-authenticate before changing email, password, MFA factors, or recovery info.

---

## Authorization (OWASP Top 10:2025 A01 — #1 risk)

- Deny by default; explicitly grant.
- Derive the acting principal from the server-side session, never from a client-supplied identifier.
- Check authorization on every request to every object — including reads.
- Centralize access checks in middleware or a policy engine (e.g., OPA, Cedar); avoid per-handler ad-hoc checks.
- Enforce ownership/tenancy in the data-access layer (parameterized `WHERE owner_id = :session.user`).
- Treat IDOR/BOLA as the default failure mode: opaque IDs (UUIDs) reduce enumeration but do not replace authorization checks.

---

## Session Management

- Generate session tokens with >=128 bits entropy from a CSPRNG.
- Issue a new session ID on authentication; invalidate the pre-auth ID.
- Verify session validity server-side on every request.
- Enforce both an inactivity timeout and an absolute maximum lifetime; align with documented risk.
- On logout, account disable, password change, or MFA change: invalidate all server-side sessions.
- Allow account holders to view and terminate their active sessions.
- Session cookies: `HttpOnly`, `Secure`, `SameSite=Lax` (default) or `Strict` (high-sensitivity), `Path=/`, and `__Host-` prefix where supported.

---

## CSRF Protection

- Required for any cookie-authenticated state-changing request (POST, PUT, PATCH, DELETE).
- Stateful apps: synchronizer token pattern — server-side per-session token, validated on each state change.
- Stateless apps/APIs: double-submit cookie with signed/HMAC token, validated against header (`X-CSRF-Token`).
- Generate tokens with a CSPRNG (>=128 bits entropy); reject missing/invalid tokens.
- Treat `SameSite=Lax/Strict` as defense in depth, not a replacement for tokens.
- Pure token-bearer APIs (no ambient cookie auth) do not need CSRF tokens but must reject cookie auth on those endpoints.

---

## Injection Prevention

| Class | Defense |
|-------|---------|
| SQL | Parameterized queries / ORM bound parameters |
| NoSQL | Driver-typed queries; reject operator-key user input |
| OS command | Parameterized exec APIs; never shell with concatenated input |
| LDAP / XPath | Library escaping; bind variables |
| XSS | Context-aware output encoding; framework auto-escaping; CSP + Trusted Types |
| HTML (WYSIWYG) | DOMPurify, ammonia, nh3, or equivalent allowlist sanitizer |
| Template (SSTI) | Never interpolate user input into template source |
| XML / XXE | Disable external entity and DTD processing |
| Deserialization | Allowlist types; avoid native deserializers on untrusted input |
| CSV | Prefix `= + - @ \t \r` with `'` per RFC 4180 guidance |
| Log injection | Strip CR/LF from user input before logging |

- Never compile or execute strings derived from user input (no dynamic code execution).

---

## XSS Defenses

- Use a framework with automatic context-aware escaping (React, Vue, Angular, Svelte). Do not bypass escaping with raw HTML insertion APIs on untrusted data.
- For untrusted HTML (markdown, WYSIWYG): sanitize with an allowlist library before rendering.
- Deploy a strict CSP as defense in depth: nonces or hashes for inline scripts, no `unsafe-inline`, no `unsafe-eval`.
- Enable Trusted Types (`require-trusted-types-for 'script'`) to block DOM-XSS sinks.
- Set `X-Content-Type-Options: nosniff` so injected non-JS payloads aren't executed.

---

## Input Validation

- Validate type, length, range, and format against an allowlist using a schema validator.
- Validate server-side; client-side checks are UX only.
- Canonicalize input (Unicode normalize, decode once) before validation.
- File uploads: enforce max size, allowlist of MIME types verified by magic-byte inspection (not extension), store outside the web root or with non-executing storage backend, re-encode images.

---

## JWT Security

- Whitelist accepted algorithms server-side; reject anything not on the list (including `none`, `NonE`, etc.).
- Verify the signature with the algorithm the server selected, not the algorithm from the JWT header. Mitigates RS256 → HS256 confusion attacks.
- Validate `exp`, `nbf`, `iss`, `aud`; reject if any required claim is missing.
- Keep access tokens short-lived (5–15 min). Use rotating refresh tokens with reuse detection (7–30 days).
- Store refresh tokens in `HttpOnly`, `Secure`, `SameSite` cookies. Never put any JWT in browser local or session storage.
- Maintain a revocation list (or rely on short expiry + refresh rotation) for logout, password change, suspicious activity.
- JWT payload is base64, not encrypted — do not put PII or secrets in it.
- Use asymmetric algorithms (RS256, ES256, EdDSA) when issuer and verifier are different services.

---

## SSRF Prevention (OWASP Top 10:2025 A01 sub-category)

- Allowlist destination hosts; if not feasible, denylist private/link-local ranges: `127.0.0.0/8`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `169.254.0.0/16`, `::1`, `fc00::/7`, `fe80::/10`.
- Resolve the hostname, validate the resulting IPs against the allowlist, then connect to the resolved IP directly with `Host` header set — eliminates the second resolution that enables DNS rebinding.
- Disable HTTP redirects, or re-validate the target after every redirect.
- On AWS, enforce IMDSv2 (session-token PUT requests, hop limit 1); disable IMDSv1.
- Run egress through a proxy that enforces the allowlist at the network layer.
- Isolate services that make external requests in segmented network zones.

---

## HTTP Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains; preload` | Force HTTPS |
| `Content-Security-Policy` | nonce-based, no `unsafe-inline`/`unsafe-eval`, `frame-ancestors 'none'`, `require-trusted-types-for 'script'` | XSS / clickjacking defense |
| `X-Content-Type-Options` | `nosniff` | Block MIME sniffing |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limit referrer leakage |
| `Permissions-Policy` | Deny unused features (`geolocation=()`, `camera=()`, ...) | Restrict browser APIs |
| `Cross-Origin-Opener-Policy` | `same-origin` | Isolate window from cross-origin |
| `Cross-Origin-Resource-Policy` | `same-origin` | Block cross-origin embedding |
| `Cross-Origin-Embedder-Policy` | `require-corp` | Enable cross-origin isolation |
| `Cache-Control` | `no-store` for authenticated responses | Prevent sensitive caching |

- `X-Frame-Options` is obsoleted by CSP `frame-ancestors`; set both only for legacy browser support.
- `X-XSS-Protection: 0` (the legacy filter creates more problems than it solves).
- Roll out CSP in `Content-Security-Policy-Report-Only` first, observe violations, then enforce.

---

## CORS

- Explicit allowlist of origins; never `Access-Control-Allow-Origin: *` on credentialed endpoints.
- Reflect a request's origin only after matching it against the allowlist.
- Set `Access-Control-Allow-Credentials: true` only when cookies/auth are actually required.
- Limit `Access-Control-Allow-Methods` and `Access-Control-Allow-Headers` to what the API uses.
- Validate the `Origin` header server-side for sensitive requests as additional defense.

---

## Transport Security

- TLS 1.2 minimum, TLS 1.3 strongly preferred (PCI DSS v4.0 baseline).
- Disable SSLv2, SSLv3, TLS 1.0, TLS 1.1.
- Use modern cipher suites (AEAD only: AES-GCM, ChaCha20-Poly1305).
- Enable HSTS with `includeSubDomains`; submit to the HSTS preload list for high-value domains.
- Use OCSP stapling or short-lived certificates; automate renewal (ACME / Let's Encrypt / cloud CA).

---

## Cryptography (OWASP Top 10:2025 A04)

- Use only vetted libraries (libsodium, platform crypto module). Never roll custom algorithms or modes.
- Minimum strengths:
  - Symmetric: AES-128 (AES-256 preferred), or ChaCha20-Poly1305
  - Asymmetric: RSA >=3072 bits, ECC >=256 bits (P-256, Curve25519, Ed25519)
  - Hash: SHA-256 / SHA-384 / SHA-512 / SHA-3
- Use AEAD for encryption (AES-GCM, AES-GCM-SIV, ChaCha20-Poly1305). Never ECB. Never reuse a (key, nonce) pair.
- Generate IVs/nonces with a CSPRNG.
- Key derivation for passwords: Argon2id > scrypt > bcrypt > PBKDF2.
- Key derivation for non-password secrets: HKDF.
- Banned: MD5, SHA-1, DES, 3DES, RC4, PKCS#1 v1.5 padding for new code.
- Never store keys in source code or unencrypted on disk.
- Design for crypto agility — algorithm and key material replaceable without redesign.

---

## File Access Control

- Place config, credential, and key files outside the web root.
- Block direct access to dotfiles and known sensitive paths (`.env`, `.git`, `.htpasswd`, `config.*`, backup extensions).
- Disable directory listings.
- Serve uploaded files from a separate origin/CDN with a non-executing content-type; never let them inherit application execution context.

---

## Rate Limiting

- Token-bucket or sliding-window counter, backed by a centralized store (Redis) with atomic operations (Lua scripts) for distributed systems.
- Use Redis server time, not application clocks, to avoid skew.
- Recommended baselines:
  - Login: 5 / 15 min per (IP + account)
  - Password reset: 3 / 15 min per account
  - Registration: 5 / hour per IP
  - Authenticated API: 100 req/min per principal (tune to workload)
  - Public/unauthenticated API: 20 req/min per IP
- Return HTTP `429` with `Retry-After`; expose `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
- Layer with WAF / bot detection / device fingerprinting for credential stuffing defense.

---

## Logging & Error Handling (OWASP Top 10:2025 A10 — Mishandling of Exceptional Conditions)

- Log security events with: UTC timestamp, level, request ID, principal (or `anon`), source IP, user agent, action, outcome, resource.
- Required events: auth success/failure, MFA challenges, authorization denials, password/email/MFA changes, privilege changes, rate-limit hits, CSRF failures, validation failures (sanitized), configuration changes, system errors.
- Structured (JSON) logs; ship to a separate, append-only / tamper-evident store.
- Never log: passwords, password hashes, full tokens (mask: `sk_...abc`), session IDs, full PAN, CVV, government IDs, raw request bodies for sensitive endpoints.
- Sanitize CR/LF from user input before logging.
- Return generic user-facing errors ("Invalid credentials", "An error occurred", "Access denied"). Never leak stack traces, SQL fragments, internal paths, or framework versions.
- Fail closed: on validation error, auth check failure, or dependency outage, deny the action — never default-allow.
- Implement a global last-resort handler so no unhandled exception ever reaches the response body.

---

## Supply Chain Security (OWASP Top 10:2025 A03 — new)

- Pin dependency versions; commit the lockfile (`package-lock.json`, `bun.lock`, `composer.lock`, `Cargo.lock`, etc.).
- Defend against dependency confusion: scope private packages (`@org/*`), explicitly configure registry per scope.
- Defend against typosquatting: before adding a new dependency, check publish date, maintainer history, and download count — treat brand-new or low-trust packages with suspicion.
- Remove unused dependencies whenever changes leave them orphaned.

---

## Environment & Configuration

- Distinct credentials, API keys, database instances, and signing keys per environment.
- Validate required env vars at startup; fail fast if missing.
- Maintain `.env.example` with every required variable using placeholder values.
- Never use production data in non-production environments without irreversibly anonymizing it.
- Disable debug endpoints, stack traces, and verbose error pages in production.
