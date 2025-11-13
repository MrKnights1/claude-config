# Security Guidelines

**Based on OWASP Application Security Verification Standard (ASVS) v5.0.0**

This document provides actionable security requirements following OWASP ASVS. When writing code, ALWAYS follow these guidelines to ensure application security.

## Quick Reference - Critical Security Rules

### ALWAYS
- Use parameterized queries (NEVER concatenate SQL)
- Validate AND sanitize all user input
- Use context-appropriate output encoding (HTML, JavaScript, URL)
- Hash passwords with bcrypt/scrypt/Argon2 (minimum 10 rounds)
- Use cryptographically secure random generation for security tokens
- Implement CSRF protection on state-changing requests
- Set secure session cookie flags (httpOnly, secure, sameSite)
- Enforce HTTPS in production
- Return generic error messages to users
- Log security events with proper metadata
- Validate file uploads by content (MIME), not extension
- Use environment variables for secrets
- Implement rate limiting on authentication endpoints
- Require MFA for sensitive applications
- Re-authenticate before sensitive account changes

### NEVER
- Store secrets in plain text or hardcode them
- Use weak cryptography (MD5, SHA-1, ECB mode)
- Use non-cryptographic random (Math.random, rand)
- Use eval() or dynamic code execution with user input
- Expose stack traces, internal paths, or DB details to users
- Log passwords, tokens, credit cards, or PII
- Trust client-side validation or authorization
- Use password hints or security questions
- Use email or SMS as primary authentication
- Send sensitive data in URLs or to third-party analytics
- Use CORS wildcard (*) in production
- Implement custom cryptographic algorithms

---

## Data Protection

### Data Classification & Documentation (ASVS V14)
- Identify and classify all sensitive data in your application (PII, credentials, financial data, health data)
- Document protection requirements for each data classification level
- Define data retention policies and implement automated deletion schedules
- NEVER send sensitive data in URLs or query strings (use HTTP body or headers only)

### Secret Management
- NEVER store passwords, API keys, tokens, or secrets in plain text
- ALWAYS use environment variables for secrets (process.env.SECRET_NAME in Node.js, $_ENV in PHP), never hardcode them
- Ensure .gitignore includes .env, .env.local, .htpasswd, config.php, and similar sensitive files
- Use separate environment variables for different environments (dev, staging, production)

### Password Storage (ASVS V6)
- Hash passwords using bcrypt, scrypt, or Argon2 (minimum 10 rounds for bcrypt)
  - PHP: password_hash() with PASSWORD_BCRYPT or PASSWORD_ARGON2ID
  - Node.js: bcrypt or argon2 library
- NEVER store password hints or security questions
- Validate passwords against top 3,000 common passwords during registration/changes

### Sensitive Data Handling
- Return only necessary sensitive information (mask complete details unless explicitly requested)
- Remove sensitive metadata from user-uploaded files before storage
- Clear sensitive data from server-side caches after use or securely purge
- Implement automated deletion of outdated sensitive data
- NEVER send sensitive data to third-party tracking/analytics services
- Set Cache-Control: no-store for responses containing sensitive data
- Use Clear-Site-Data header to remove authenticated data from browser on logout

## Input Validation & Sanitization

### Encoding & Output Context (ASVS V1)
- Decode all input data only once into canonical form before processing
- Apply output encoding as the final step before sending to any interpreter
- Use context-appropriate encoding for the target interpreter:
  - HTML context: Escape <, >, &, ", ' characters
  - JavaScript/JSON: Use proper JSON encoding
  - URL context: Use URL encoding or base64url
  - SQL: Use parameterized queries (never encoding)
  - OS commands: Use parameterized commands

### Injection Prevention
- **SQL Injection**: Use parameterized queries or ORM methods (NEVER concatenate user input into SQL)
- **XSS Prevention**: Sanitize HTML output to prevent cross-site scripting:
  - PHP: htmlspecialchars($input, ENT_QUOTES, 'UTF-8')
  - React: Use JSX (auto-escapes), or DOMPurify for rich content
  - Node.js: Use libraries like validator, xss, or DOMPurify
- **WYSIWYG Content**: Sanitize all untrusted HTML from editors using well-known libraries (DOMPurify, Bleach)
- **Command Injection**: Use parameterized/safe APIs for OS commands, avoid system() and exec() with user input
- **XML External Entity (XXE)**: Configure XML parsers to disable external entity processing
- **Template Injection**: Avoid dynamic template generation with user input
- **CSV Injection**: Follow RFC 4180, sanitize formulas in CSV exports
- **LDAP/XPath Injection**: Use parameterized queries or escaping functions
- **Deserialization**: Use allowlists for acceptable object types, avoid deserializing untrusted data
- NEVER use eval() or dynamic code execution with user input

### Input Validation
- ALWAYS validate user input type (string, number, email, etc.)
- ALWAYS validate input length (min/max characters)
- ALWAYS validate input format using regex or validation libraries (zod, joi, yup)
- ALWAYS validate file upload types by checking file content (MIME type), not just extension
- ALWAYS limit file upload sizes (e.g., max 5MB for images, max 10MB for documents)
- Validate data on both client-side (UX) AND server-side (security)

## Authentication & Authorization

### Authentication Requirements (ASVS V6)

#### Password Policy
- Enforce minimum 8-character passwords (15+ characters strongly recommended)
- Validate against top 3,000 common passwords during registration and password changes
- Allow unrestricted character composition (no mandatory complexity rules)
- Allow paste functionality in password fields
- Mask password input fields in UI
- Process passwords exactly as submitted (no trimming or modification)

#### Multi-Factor Authentication (MFA)
- Implement MFA for sensitive applications (Level 2+)
- For high-security apps (Level 3), use hardware-based authentication (FIDO keys, device-bound passkeys)
- NEVER use email as an authentication mechanism
- NEVER use SMS/PSTN for Level 3 applications (prefer TOTPs or cryptographic methods)
- Limit OTP lifetimes: 10 minutes for out-of-band codes, 30 seconds for TOTPs
- Implement rate limiting against brute force and push bombing attacks on MFA endpoints

#### Attack Prevention
- Implement controls against credential stuffing and brute force attacks
- Prevent user enumeration through:
  - Consistent error messages ("Invalid credentials" not "Username not found")
  - Consistent response times for valid and invalid users
- Implement rate limiting on authentication endpoints:
  - 3-5 attempts per 15 minutes for login
  - 3 attempts per 15 minutes for password reset
  - Include file locking to prevent race conditions in file-based systems
  - Use express-rate-limit (Node.js) or custom file/Redis-based limiting

#### Password Reset & Recovery
- Generate initial passwords/codes using cryptographically secure random generation (crypto.randomBytes, random_bytes)
- Enable secure password reset without bypassing MFA
- NEVER use password hints or security questions
- Support revocation of compromised authentication factors

#### Session Management
- Regenerate session IDs after login to prevent session fixation
- Use secure session cookies:
  - httpOnly: true (prevent JavaScript access)
  - secure: true (HTTPS only)
  - sameSite: 'strict' or 'lax' (CSRF protection)
  - PHP: session.cookie_httponly=1, session.cookie_secure=1, session.cookie_samesite="Strict"
  - Express.js: Use express-session with proper cookie settings

#### Authorization
- Verify user is authenticated and has permission to access requested resource before processing
- Follow principle of least privilege: users should only access what they need
- NEVER trust client-side authorization checks, always verify server-side
- Re-authenticate users before sensitive account modifications (email, MFA, recovery info)

#### Identity Provider Integration
- When using external IdPs, combine IdP ID with user identifier to prevent identity spoofing
- ALWAYS validate digital signatures on assertions (JWTs, SAML)
- Verify authentication strength claims from external providers

## Session Management (ASVS V7)

### Documentation & Planning
- Conduct risk analysis and document security decisions before implementation
- Document session inactivity timeout and absolute maximum session lifetime
- Define and document concurrent session policies

### Token Generation & Security
- Perform all session token verification on trusted backend services (NEVER on client-side)
- Generate session tokens dynamically with at least 128 bits of entropy
- Use cryptographically secure random generation (crypto.randomBytes, random_bytes)
- Issue new tokens upon authentication, invalidating previous ones
- Avoid static or predictable tokens

### Session Timeouts
Implement two types of timeouts:
- **Inactivity timeout**: Forces re-authentication after periods of disuse
- **Absolute maximum lifetime**: Requires re-authentication regardless of activity
- Both must align with documented risk decisions

### Session Termination
- Logout and expiration must completely prevent further session use
- Terminate all sessions when user accounts are disabled or deleted
- Allow users to view and terminate their active sessions
- Allow users to terminate other active sessions after security changes
- Give administrators ability to terminate individual or all user sessions
- Make logout functionality easy and visible on all authenticated pages

### Abuse Prevention
- Require full re-authentication for sensitive account modifications:
  - Email address changes
  - MFA configuration
  - Recovery information updates
  - Password changes
- Users can view their active sessions
- High-risk transactions may require additional authentication factors

### Federated/SSO Systems
- SSO providers must coordinate session lifetimes across applications
- Ensure documented termination behavior
- Require explicit user consent before session creation

## CSRF Protection

- ALWAYS implement CSRF protection for state-changing requests (POST, PUT, PATCH, DELETE)
- Generate cryptographically secure tokens:
  - PHP: bin2hex(random_bytes(32))
  - Node.js: crypto.randomBytes(32).toString('hex')
- Store token in session, embed in forms as hidden field
- Validate token on server before processing request
- Rotate token after successful validation to prevent reuse
- Use CSRF middleware:
  - Express.js: csurf middleware
  - PHP: Custom implementation or framework-provided (Laravel, Symfony)
  - React/SPA: Include token in request headers (X-CSRF-Token)

## HTTP Security Headers

ALWAYS set these security headers (via middleware, web server config, or framework):

### Essential Headers
- **X-Frame-Options: DENY** - Prevent clickjacking (or use CSP frame-ancestors)
- **X-Content-Type-Options: nosniff** - Prevent MIME type sniffing
- **Strict-Transport-Security: max-age=31536000; includeSubDomains; preload** - Enforce HTTPS
- **Referrer-Policy: strict-origin-when-cross-origin** - Control referrer information
- **X-XSS-Protection: 1; mode=block** - Enable XSS filter for legacy browsers

### Content Security Policy (CSP)
- **Content-Security-Policy** - Restrict resource loading to prevent XSS:
  ```
  default-src 'self';
  script-src 'self' https://trusted-cdn.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  frame-ancestors 'none';
  ```
- Start restrictive, gradually allow trusted sources
- Use 'nonce-' or 'hash-' instead of 'unsafe-inline' when possible
- Test thoroughly - CSP can break functionality if misconfigured

### Additional Headers
- **Permissions-Policy: geolocation=(), microphone=(), camera=()** - Restrict browser features
- **Cross-Origin-Resource-Policy: same-origin** - Protect against Spectre attacks

### Implementation
- **Apache (.htaccess)**: Use `<IfModule mod_headers.c>` and `Header always set`
- **Nginx**: Use `add_header` in server block
- **Express.js**: Use helmet middleware
- **Next.js**: Configure in next.config.js headers
- **PHP**: Use header() function (less preferred than web server config)

## CORS Configuration

- NEVER use '*' wildcard in production
- Explicitly whitelist allowed origins:
  - Express.js: Configure cors middleware with origin array
  - PHP: Check $_SERVER['HTTP_ORIGIN'] and set Access-Control-Allow-Origin
  - Next.js: Configure in next.config.js or API middleware
- Set appropriate Access-Control-Allow-Methods (only methods you support)
- Set Access-Control-Allow-Credentials: true only when needed
- Be restrictive with Access-Control-Allow-Headers

## HTTPS & Transport Security

- ALWAYS enforce HTTPS in production (NEVER allow HTTP for authenticated/sensitive operations)
- Redirect HTTP to HTTPS:
  - Apache: RewriteEngine with HTTPS check
  - Nginx: return 301 for HTTP requests
  - Express.js: Use express-sslify or custom middleware
  - Next.js: Handle at reverse proxy level (recommended)
- Enable HSTS header (max-age=31536000; includeSubDomains; preload)
- Consider HSTS preload list submission for high-security sites
- Use TLS 1.2 minimum (disable TLS 1.0/1.1)

## Cryptography (ASVS V11)

### Documentation & Planning
- Maintain documented policies for cryptographic key management (follow NIST SP 800-57)
- Perform regular cryptographic discovery to identify all encryption, hashing, and signing operations
- Document which keys protect which data types
- Create migration plan for post-quantum cryptography (PQC) readiness

### Secure Implementation
- Use only industry-validated cryptographic libraries and implementations:
  - Node.js: crypto (built-in), sodium/libsodium, bcrypt/argon2
  - PHP: openssl extension, sodium extension, password_hash()
  - Python: cryptography library, PyCryptodome
  - NEVER implement custom cryptographic algorithms
- Design systems with "crypto agility" (ability to swap algorithms and update keys without major redesign)
- Enforce minimum 128 bits of security across all algorithms:
  - Symmetric: AES-128 minimum (AES-256 recommended)
  - Asymmetric: 256-bit ECC or 3072-bit RSA minimum
  - Hashing: SHA-256 minimum

### Encryption Standards
- Use authenticated encryption modes (AES-GCM recommended)
- NEVER use weak modes like ECB
- Avoid outdated padding schemes (PKCS#1 v1.5)
- Use encrypt-then-MAC pattern when authenticated encryption not available
- NEVER reuse nonces or initialization vectors (IVs) for the same key
- Generate IVs using cryptographically secure random generation

### Hashing & Key Derivation
- Use only approved hash functions (SHA-256, SHA-384, SHA-512, SHA-3)
- NEVER use MD5, SHA-1, or other compromised algorithms
- Use computationally intensive key derivation functions for password storage:
  - bcrypt (minimum 10 rounds)
  - scrypt
  - Argon2id (recommended)
- Use 256-bit minimum output for collision-resistant hashing
- Use 128-bit minimum for second preimage resistance

### Random Number Generation
- Generate all security-sensitive values using cryptographically secure PRNGs:
  - Node.js: crypto.randomBytes()
  - PHP: random_bytes()
  - Python: secrets module
- Ensure ≥128 bits of entropy for all security tokens
- NEVER use Math.random(), rand(), or similar non-cryptographic generators
- Avoid UUIDs for cryptographic purposes

### Data Protection
- Implement full memory encryption for highly sensitive data during processing
- Minimize time sensitive data is exposed in memory
- Encrypt sensitive data immediately after processing
- Use constant-time operations to prevent timing-based information leaks

### Key Management
- Rotate cryptographic keys on a regular schedule
- Store keys securely using key management systems (KMS) or hardware security modules (HSM)
- NEVER hardcode cryptographic keys in source code
- Separate key management from application logic

## File Access Control

- Restrict access to sensitive files via web server configuration:
  - Apache: Use `<Files>` directive to deny access to config.php, .env, .htpasswd
  - Nginx: Use location blocks with deny all
  - Node.js: Ensure sensitive files are outside webroot
- Disable directory listings:
  - Apache: Options -Indexes
  - Nginx: autoindex off
- Place configuration files outside public webroot when possible
- Never commit sensitive files to version control (.gitignore them)

## Rate Limiting

Implement rate limiting for all user-facing endpoints:

### Critical Endpoints (Strict limits)
- Login: 5 attempts per 15 minutes per IP
- Password reset: 3 attempts per 15 minutes per IP
- Registration: 5 attempts per hour per IP
- Contact forms: 3 submissions per 15 minutes per IP

### API Endpoints (Moderate limits)
- Authenticated APIs: 100 requests per minute per user
- Public APIs: 20 requests per minute per IP

### Implementation
- Use Redis for distributed rate limiting (production)
- Use in-memory stores for single-server setups (development)
- File-based rate limiting:
  - Use file locking (flock()) to prevent race conditions
  - Implement automatic cleanup of old entries
  - Store in temp directory with restrictive permissions (0700)
- Libraries:
  - Express.js: express-rate-limit, rate-limiter-flexible
  - PHP: Custom implementation with file/Redis backend
- Return 429 Too Many Requests with Retry-After header

## Error Handling & Logging (ASVS V16)

### Logging Infrastructure & Documentation
- Maintain an inventory documenting logging at each application layer:
  - Events logged
  - Log formats (prefer structured/JSON logs)
  - Storage locations
  - Access controls
  - Retention periods
- Synchronize time sources with UTC timestamps or explicit offsets across distributed systems
- Transmit logs to isolated systems separate from production environments
- Protect logs from unauthorized modification with integrity controls

### Security Event Logging
Log all security-relevant events with sufficient metadata for investigation:
- **Authentication events**:
  - Successful and failed login attempts (with IP, timestamp, username)
  - MFA validation attempts
  - Password reset requests
- **Authorization events**:
  - Failed authorization decisions
  - Privilege escalation attempts
  - Control bypass attempts
- **Security violations**:
  - Rate limit violations
  - CSRF token validation failures
  - Input validation failures (with sanitized input)
  - Suspicious patterns (credential stuffing, brute force)
- **System errors**:
  - Unexpected errors and exceptions
  - Backend failures (TLS errors, service unavailability)
  - Configuration changes

### Log Entry Structure
Each log entry should include:
- Timestamp (UTC or with explicit offset)
- Event type/severity (debug, info, warn, error)
- User identifier (if authenticated)
- IP address and user agent
- Request ID for tracing
- Action performed or attempted
- Outcome (success/failure)
- Relevant context (resource accessed, error codes)

### Sensitive Data in Logs
- NEVER log passwords, password hashes, or password hints
- NEVER log API keys, tokens, or session IDs in plain text
- NEVER log credit card numbers, CVVs, or PINs
- NEVER log personal identification numbers (SSN, passport numbers)
- Allow logging of hashed or masked session tokens for debugging (with caution)
- Sanitize user input before logging to prevent log injection attacks
- Treat logs as sensitive assets requiring protection equivalent to the data they reference

### Error Handling Requirements
- NEVER expose stack traces, internal paths, database structure, or technology details to users
- Return generic error messages to users:
  - "Invalid credentials" (NOT "Password incorrect" or "Username not found")
  - "An error occurred" (NOT specific database errors)
  - "Access denied" (NOT role/permission details)
  - "Service temporarily unavailable" (for backend failures)
- Implement safe failure modes:
  - Use circuit breakers or degradation patterns when external resources fail
  - Prevent fail-open conditions (never continue processing if validation fails)
  - Fail securely (default to deny, not allow)
- Use try-catch blocks to handle errors gracefully
- Implement centralized error handling middleware
- Implement last-resort exception handlers to catch unhandled exceptions (Level 3)

## Environment Management

- NEVER use production credentials in development/staging
- ALWAYS use different API keys per environment
- ALWAYS use different database instances per environment
- Keep `.env.example` updated with all required variables (use placeholder values)
- Document what each environment variable does
- Use `.env.local` for local development secrets (git ignored)
- Validate required environment variables at application startup (fail fast if missing)
- Use different CSRF token secrets per environment

## Dependency Management & Maintenance

### Regular Updates
- Run dependency updates regularly:
  - Node.js: `npm update` or `bun update`
  - PHP: `composer update`
  - React: Update via npm/bun
- Check for security vulnerabilities:
  - Node.js: `npm audit` or `bun audit`
  - PHP: `composer audit`

### Dependency Security
- Review dependencies before adding (check download count, last update, known issues)
- Minimize dependency count (fewer dependencies = smaller attack surface)
- Use official, well-maintained packages from trusted sources

### Code Review
- Review code for security issues before merging to main
- Test authentication flows with invalid credentials and expired sessions
- Test authorization by attempting to access resources without permission
- Test rate limiting by exceeding limits
- Test CSRF protection by submitting requests without token
- Test input validation with malicious inputs (XSS, SQL injection attempts)

## Security Testing Checklist (ASVS-Based)

Before deploying to production, verify:

### Data Protection (V14)
- [ ] Sensitive data classified and documented
- [ ] Sensitive data never sent in URLs/query strings
- [ ] Data retention policies implemented
- [ ] Cache-Control: no-store set for sensitive data responses
- [ ] Clear-Site-Data header implemented for logout
- [ ] Sensitive metadata removed from uploaded files

### Input Validation & Injection Prevention (V1)
- [ ] Input validation on all user inputs (type, length, format)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (context-appropriate output encoding)
- [ ] WYSIWYG content sanitized (DOMPurify or equivalent)
- [ ] Command injection prevention (parameterized commands)
- [ ] XML parser configured to prevent XXE
- [ ] CSV exports sanitized (no formula injection)
- [ ] Deserialization uses allowlists

### Authentication (V6)
- [ ] Password policy enforced (minimum 8 chars, no complexity requirements)
- [ ] Passwords validated against top 3,000 common passwords
- [ ] Password paste functionality enabled
- [ ] MFA implemented for sensitive applications
- [ ] Credential stuffing protection (rate limiting + detection)
- [ ] User enumeration prevented (consistent errors and timing)
- [ ] Password reset secure (doesn't bypass MFA)
- [ ] No password hints or security questions
- [ ] Cryptographically secure token generation

### Session Management (V7)
- [ ] Session documentation complete (timeouts, policies)
- [ ] Session tokens have ≥128 bits of entropy
- [ ] New tokens issued on authentication
- [ ] Inactivity timeout implemented
- [ ] Absolute maximum session lifetime implemented
- [ ] Logout completely terminates sessions
- [ ] Users can view and terminate active sessions
- [ ] Session security flags set (httpOnly, secure, sameSite)
- [ ] Re-authentication required for sensitive changes

### CSRF Protection
- [ ] CSRF protection on all state-changing requests
- [ ] CSRF tokens cryptographically secure (≥128 bits)
- [ ] Tokens validated server-side
- [ ] Tokens rotated after validation

### Cryptography (V11)
- [ ] Cryptographic inventory documented
- [ ] Industry-validated libraries used (no custom crypto)
- [ ] Minimum 128-bit security level enforced
- [ ] Authenticated encryption used (AES-GCM)
- [ ] No weak cipher modes (ECB) or algorithms (MD5, SHA-1)
- [ ] Password hashing uses bcrypt/scrypt/Argon2
- [ ] Cryptographically secure PRNG for all security tokens
- [ ] Keys stored securely (not hardcoded)
- [ ] Key rotation schedule documented

### HTTP Security
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] TLS 1.2 minimum (TLS 1.0/1.1 disabled)
- [ ] HSTS header set (max-age=31536000)
- [ ] Security headers configured (securityheaders.com score A+):
  - X-Frame-Options or CSP frame-ancestors
  - X-Content-Type-Options: nosniff
  - Referrer-Policy
  - Content-Security-Policy
  - Permissions-Policy
- [ ] CORS configured (no wildcard in production)

### Error Handling & Logging (V16)
- [ ] Logging inventory documented
- [ ] Error messages generic (no information disclosure)
- [ ] No stack traces exposed to users
- [ ] Security events logged (auth, authz, violations)
- [ ] Structured logging with UTC timestamps
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] Log integrity controls implemented
- [ ] Logs transmitted to isolated system
- [ ] Safe failure modes (circuit breakers, fail secure)
- [ ] Last-resort exception handlers implemented

### File Security
- [ ] File upload validation (MIME type, size, content)
- [ ] Sensitive files protected (.env not accessible)
- [ ] Directory listings disabled
- [ ] Configuration files outside webroot

### Rate Limiting
- [ ] Rate limiting on authentication endpoints (5/15min)
- [ ] Rate limiting on password reset (3/15min)
- [ ] Rate limiting on registration (5/hour)
- [ ] Rate limiting on contact forms (3/15min)
- [ ] 429 responses with Retry-After header

### Environment & Dependencies
- [ ] Environment variables properly configured
- [ ] .env and sensitive files in .gitignore
- [ ] Required env vars validated at startup
- [ ] Different credentials per environment
- [ ] Dependencies updated and vulnerability-free (audit passed)
- [ ] Dependency review completed
