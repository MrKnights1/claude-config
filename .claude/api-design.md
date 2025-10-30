# API Design Standards

## RESTful Conventions

- Use RESTful conventions (GET, POST, PUT, PATCH, DELETE). Prefer PATCH over PUT for partial updates
- Use plural nouns for endpoints (`/users`, not `/user`)
- Return proper HTTP status codes (200, 201, 400, 401, 404, 500)
- Use consistent response format (e.g., `{ data, error, message }`)
- Document all endpoints with examples

## HTTP Status Codes

- **200 OK**: Successful GET, PATCH, PUT, DELETE
- **201 Created**: Successful POST (include `Location` header with new resource URL)
- **204 No Content**: Successful DELETE with no response body
- **400 Bad Request**: Invalid input/validation error
- **401 Unauthorized**: Not authenticated (missing/invalid token)
- **403 Forbidden**: Authenticated but not authorized
- **404 Not Found**: Resource doesn't exist
- **409 Conflict**: Resource conflict (e.g., duplicate email)
- **422 Unprocessable Entity**: Validation errors (detailed)
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Unexpected server error

## Response Format

Use consistent response structure:

```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 150
  }
}
```

Error response:

```json
{
  "success": false,
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "VALIDATION_ERROR",
    "fields": {
      "email": "Invalid email format",
      "password": "Must be at least 8 characters"
    }
  }
}
```

## Pagination

- ALWAYS paginate list endpoints
- Default page size: 20 items
- Maximum page size: 100 items
- Query params: `?page=1&pageSize=20`
- Include pagination metadata in response

## URL Structure

```
GET    /users              # List all users (paginated)
GET    /users/:id          # Get specific user
POST   /users              # Create new user
PATCH  /users/:id          # Update user
DELETE /users/:id          # Delete user
GET    /users/:id/orders   # Get orders for user
```

---

# Logging Standards

## What to Log

- Log all security events (authentication, authorization failures)
- Use appropriate log levels (debug, info, warn, error)
- Include request IDs for tracing
- NEVER log sensitive data (passwords, tokens, credit cards)
- Use structured logging (JSON format)
- Include timestamps and context in logs

## Log Levels

- **debug**: Detailed information for debugging
- **info**: General informational messages
- **warn**: Warning messages (non-critical issues)
- **error**: Error messages (requires attention)

## Log Format

```json
{
  "timestamp": "2025-10-30T10:30:00Z",
  "level": "error",
  "message": "Failed to fetch user",
  "requestId": "abc-123-def",
  "userId": "user-456",
  "error": "Database connection timeout"
}
```

## What NOT to Log

- Passwords or password hashes
- API keys or tokens
- Credit card numbers
- Social security numbers
- Personal identification numbers
- Session IDs (in production)
