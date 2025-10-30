# Security Guidelines

## Data Protection

- NEVER store passwords, API keys, tokens, or secrets in plain text
- ALWAYS use environment variables for secrets (process.env.SECRET_NAME), never hardcode them
- Ensure .gitignore includes .env, .env.local, and similar files
- Hash passwords using bcrypt with minimum 10 rounds before storing in database
- Use separate environment variables for different environments (dev, staging, production)

## Input Validation

- Use parameterized queries or ORM methods to prevent SQL injection (never concatenate user input into SQL)
- ALWAYS validate user input type (string, number, email, etc.)
- ALWAYS validate input length (min/max characters)
- ALWAYS validate input format using regex or validation libraries (zod, joi, yup)
- ALWAYS sanitize HTML output to prevent XSS (escape <, >, &, ", ')
- ALWAYS validate file upload types by checking file content, not just extension
- ALWAYS limit file upload sizes (e.g., max 5MB for images)

## Authentication & Authorization

- Verify user is authenticated and has permission to access requested resource before processing
- Use secure session cookies (httpOnly: true, secure: true, sameSite: 'strict')
- Implement rate limiting on login endpoints (e.g., 5 attempts per 15 minutes)
- Require strong passwords (min 8 chars, uppercase, lowercase, number, symbol)
- Follow principle of least privilege: users should only access what they need
- NEVER trust client-side authorization checks, always verify server-side

## Network Security

- Configure CORS to allow only specific origins (NEVER use '\*' in production)
- Set security headers:
  - Content-Security-Policy: restrict resource loading
  - X-Frame-Options: DENY (prevent clickjacking)
  - X-Content-Type-Options: nosniff
  - Strict-Transport-Security: max-age=31536000
- Implement CSRF protection for state-changing requests (POST, PUT, DELETE) using tokens or double-submit cookie pattern

## Error Handling

- NEVER expose stack traces, internal paths, database structure, or technology details to users
- Return generic error messages to users (e.g., "Invalid credentials" not "Password incorrect")
- Log detailed security events server-side (failed logins, unauthorized access attempts)
- Use try-catch blocks to handle errors gracefully

## Environment Management

- NEVER use production credentials in development/staging
- ALWAYS use different API keys per environment
- ALWAYS use different database instances per environment
- Keep `.env.example` updated with all required variables (but with placeholder values)
- Document what each environment variable does
- Use `.env.local` for local development secrets (git ignored)
- Validate required environment variables at application startup

## Maintenance

- Run `bun update` regularly to keep dependencies updated
- Run `bun audit` to check for known vulnerabilities in dependencies
- Review code for security issues before merging to main
- Test authentication flows with invalid credentials and expired sessions
- Test authorization by attempting to access resources without permission
