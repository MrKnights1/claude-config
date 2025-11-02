# Security Guidelines

## Data Protection

- NEVER store passwords, API keys, tokens, or secrets in plain text
- ALWAYS use environment variables for secrets (process.env.SECRET_NAME in Node.js, $_ENV in PHP), never hardcode them
- Ensure .gitignore includes .env, .env.local, .htpasswd, config.php, and similar sensitive files
- Hash passwords using bcrypt with minimum 10 rounds (PHP: password_hash(), Node.js: bcrypt library)
- Use separate environment variables for different environments (dev, staging, production)

## Input Validation & Sanitization

- Use parameterized queries or ORM methods to prevent SQL injection (NEVER concatenate user input into SQL)
- ALWAYS validate user input type (string, number, email, etc.)
- ALWAYS validate input length (min/max characters)
- ALWAYS validate input format using regex or validation libraries (zod, joi, yup)
- ALWAYS sanitize HTML output to prevent XSS:
  - Escape <, >, &, ", ' characters
  - PHP: htmlspecialchars($input, ENT_QUOTES, 'UTF-8')
  - React: Use JSX (auto-escapes), or DOMPurify for rich content
  - Node.js: Use libraries like validator, xss, or DOMPurify
- ALWAYS validate file upload types by checking file content (MIME type), not just extension
- ALWAYS limit file upload sizes (e.g., max 5MB for images, max 10MB for documents)
- Validate data on both client-side (UX) AND server-side (security)

## Authentication & Authorization

- Verify user is authenticated and has permission to access requested resource before processing
- Use secure session cookies:
  - httpOnly: true (prevent JavaScript access)
  - secure: true (HTTPS only)
  - sameSite: 'strict' or 'lax' (CSRF protection)
  - PHP: session.cookie_httponly=1, session.cookie_secure=1, session.cookie_samesite="Strict"
  - Express.js: Use express-session with proper cookie settings
- Implement rate limiting on sensitive endpoints (login, password reset, contact forms):
  - 3-5 attempts per 15 minutes for login
  - 3 attempts per 15 minutes for contact forms
  - Use express-rate-limit (Node.js) or custom file/Redis-based limiting
  - Include file locking to prevent race conditions in file-based systems
- Require strong passwords (min 8 chars, uppercase, lowercase, number, symbol)
- Follow principle of least privilege: users should only access what they need
- NEVER trust client-side authorization checks, always verify server-side
- Regenerate session IDs after login to prevent session fixation

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

## Error Handling & Logging

- NEVER expose stack traces, internal paths, database structure, or technology details to users
- Return generic error messages to users:
  - "Invalid credentials" (NOT "Password incorrect" or "Username not found")
  - "An error occurred" (NOT specific database errors)
  - "Access denied" (NOT role/permission details)
- Log detailed security events server-side:
  - Failed login attempts with IP, timestamp, username
  - Unauthorized access attempts
  - Rate limit violations
  - CSRF token validation failures
  - Input validation failures with sanitized input
- Use try-catch blocks to handle errors gracefully
- Implement centralized error handling middleware
- Never log sensitive data (passwords, tokens, credit cards)
- Use structured logging with log levels (debug, info, warn, error)

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

## Security Testing Checklist

Before deploying to production, verify:

- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Security headers configured (use securityheaders.com to test)
- [ ] CSRF protection implemented and tested
- [ ] Rate limiting active on sensitive endpoints
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output escaping)
- [ ] Session security (httpOnly, secure, sameSite flags)
- [ ] Sensitive files protected (config files not accessible)
- [ ] Error messages generic (no information disclosure)
- [ ] Logging configured (security events tracked)
- [ ] Dependencies updated and vulnerability-free
- [ ] CORS configured (no wildcard in production)
- [ ] File upload validation (size, type, content checks)
- [ ] Environment variables properly configured
- [ ] .env and sensitive files in .gitignore
