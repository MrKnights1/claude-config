# Security Review Guide

This guide describes how to conduct security reviews of code changes. For security coding guidelines, see `security.md`.

---

## Review Process

### 1. Get the Changes
```bash
# View pending changes
git diff main...HEAD

# Or for specific files
git diff main...HEAD -- src/
```

### 2. Identify High-Risk Areas

Prioritize review of changes in:
1. **Authentication/Authorization** - Login, sessions, permissions
2. **Input Handling** - Forms, API inputs, file uploads
3. **Database Operations** - Queries, migrations
4. **API Endpoints** - New or modified routes
5. **Dependencies** - New packages added
6. **Configuration** - Environment variables, secrets

### 3. Review Order

1. Check for obvious issues first (hardcoded secrets, SQL injection)
2. Review high-risk areas thoroughly
3. Check remaining changes for best practice violations
4. Verify security headers and configurations

### 4. When to Flag for Human Review

ALWAYS escalate to human review when:
- Authentication or authorization logic changes
- Cryptographic implementations
- Payment or financial data handling
- Personal data (PII) processing changes
- New external service integrations
- Security configuration changes

---

## Review Checklists

### Authentication & Authorization
- [ ] No credentials hardcoded in code
- [ ] Password hashing uses bcrypt/scrypt/Argon2
- [ ] Session tokens are cryptographically secure
- [ ] Session regenerated after login
- [ ] Logout properly invalidates session
- [ ] Permission checks on all protected routes
- [ ] No privilege escalation vulnerabilities
- [ ] MFA not bypassed

### Input Validation & Sanitization
- [ ] All user input validated (type, length, format)
- [ ] Input sanitized before use
- [ ] Output encoded for context (HTML, JS, URL)
- [ ] File uploads validated by content, not extension
- [ ] File upload size limits enforced
- [ ] No dynamic code execution with user input

### Database Security
- [ ] All queries use parameterized statements
- [ ] No string concatenation in SQL
- [ ] ORM used correctly (no raw queries with user input)
- [ ] Database credentials not in code
- [ ] Migrations don't expose sensitive data

### API Security
- [ ] Authentication required on protected endpoints
- [ ] Authorization checked for resource access
- [ ] Rate limiting implemented
- [ ] Input validation on all parameters
- [ ] Sensitive data not in URLs
- [ ] CORS configured correctly (no wildcard in prod)
- [ ] Proper HTTP methods used

### Secrets & Configuration
- [ ] No secrets in code (API keys, passwords, tokens)
- [ ] Secrets loaded from environment variables
- [ ] .env files in .gitignore
- [ ] No secrets in logs
- [ ] Different secrets per environment

### Dependencies
- [ ] New dependencies from trusted sources
- [ ] No known vulnerabilities (`npm audit` / `composer audit`)
- [ ] Dependencies actively maintained
- [ ] Minimal new dependencies added

### Error Handling
- [ ] No stack traces exposed to users
- [ ] Generic error messages returned
- [ ] Errors logged server-side with context
- [ ] No sensitive data in error messages

### Session & Cookies
- [ ] Secure cookie flags set (httpOnly, secure, sameSite)
- [ ] Session timeout implemented
- [ ] CSRF protection on state-changing requests

---

## Severity Levels

| Severity | Description | Examples |
|----------|-------------|----------|
| **Critical** | Immediate exploitation risk, requires urgent fix | SQL injection, hardcoded prod credentials, auth bypass |
| **High** | Significant vulnerability, fix before deploy | XSS, missing auth on sensitive endpoint, weak crypto |
| **Medium** | Potential risk under certain conditions | Missing rate limiting, verbose errors, weak validation |
| **Low** | Best practice deviation, minor risk | Missing security headers, suboptimal config |

---

## Report Format

```markdown
## Security Review: [Branch Name or PR #]

**Reviewer:** Claude
**Date:** YYYY-MM-DD
**Scope:** [Files/areas reviewed]

### Summary

[1-2 sentence overview of findings]

- Critical: X
- High: X
- Medium: X
- Low: X

### Findings

#### [CRITICAL] SQL Injection in User Search
- **File:** src/routes/users.ts:45
- **Issue:** User input directly concatenated into SQL query
- **Risk:** Attacker can read/modify/delete database data
- **Fix:** Use parameterized query

#### [HIGH] Missing Authentication on Admin Endpoint
- **File:** src/routes/admin.ts:12
- **Issue:** /api/admin/users endpoint has no auth middleware
- **Risk:** Unauthorized access to admin functions
- **Fix:** Add authMiddleware to route

### Checklist Results

#### Passed
- [x] No hardcoded secrets
- [x] Parameterized queries used
- [x] Input validation present

#### Failed
- [ ] Rate limiting on login endpoint
- [ ] CSRF token validation

#### Not Applicable
- [ ] File uploads (no file upload in changes)

### Recommendations

1. Fix critical and high issues before merge
2. Add rate limiting to authentication endpoints
3. Consider adding CSRF protection
```

---

## What to Look For

### SQL Injection
- String concatenation in database queries
- User input passed directly to query methods
- Missing parameterization

### XSS (Cross-Site Scripting)
- User input rendered without encoding
- Dynamic HTML generation with user data
- Missing output sanitization

### Hardcoded Secrets
- API keys, passwords, tokens in source code
- Credentials in configuration files
- Secrets committed to git history

### Missing Auth
- Endpoints without authentication middleware
- Missing authorization checks for resources
- Privilege escalation possibilities

### Insecure Direct Object Reference
- Resource access without ownership verification
- Missing user-to-resource relationship checks

---

## Quick Commands

```bash
# Check for secrets in code
grep -r "password\|secret\|api_key\|token" --include="*.ts" --include="*.js" src/

# Check for SQL injection patterns
grep -r "query.*\${" --include="*.ts" --include="*.js" src/

# Run dependency audit
npm audit
# or
composer audit

# Check git history for secrets
git log -p | grep -i "password\|secret\|api_key"
```
