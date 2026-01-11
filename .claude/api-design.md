# API Design Standards

## RESTful Conventions

- Use RESTful conventions (GET, POST, PATCH, DELETE)
- Use PATCH for updates (not PUT)
- Use plural nouns for endpoints (`/users`, not `/user`)
- Use kebab-case for multi-word resources (`/user-profiles`, not `/userProfiles`)
- Return proper HTTP status codes
- Use consistent response format across all endpoints
- Document all endpoints with examples

---

## API Versioning

### URL Path Versioning (Recommended)
```
/api/v1/users
/api/v2/users
```

### Header Versioning (Alternative)
```
Accept: application/vnd.api+json; version=1
```

### Versioning Rules
- Increment major version for breaking changes
- Support at least one previous version during transition
- Document deprecation timeline (minimum 6 months notice)
- Include version in API documentation

### What Requires Version Bump
- Removing or renaming endpoints
- Removing or renaming fields
- Changing field types
- Changing authentication requirements
- Changing error response format

### What Does NOT Require Version Bump
- Adding new endpoints
- Adding new optional fields
- Adding new error codes
- Performance improvements

---

## HTTP Status Codes

### Success (2xx)
| Code | Name | Use Case |
|------|------|----------|
| 200 | OK | Successful GET, PATCH, DELETE |
| 201 | Created | Successful POST (include `Location` header) |
| 202 | Accepted | Request accepted for async processing |
| 204 | No Content | Successful DELETE with no response body |

### Client Errors (4xx)
| Code | Name | Use Case |
|------|------|----------|
| 400 | Bad Request | Invalid input, malformed JSON |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 405 | Method Not Allowed | HTTP method not supported |
| 409 | Conflict | Resource conflict (duplicate email) |
| 422 | Unprocessable Entity | Validation errors (detailed) |
| 429 | Too Many Requests | Rate limit exceeded |

### Server Errors (5xx)
| Code | Name | Use Case |
|------|------|----------|
| 500 | Internal Server Error | Unexpected server error |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Maintenance or overload |
| 504 | Gateway Timeout | Upstream service timeout |

---

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { },
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": "Invalid email format",
      "password": "Must be at least 8 characters"
    },
    "requestId": "req_abc123"
  }
}
```

### Single Resource Response
```json
{
  "success": true,
  "data": {
    "id": "usr_123",
    "email": "user@example.com",
    "name": "John Doe",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

---

## Standard Error Codes

Use consistent application-level error codes:

### Authentication & Authorization
| Code | Description |
|------|-------------|
| `AUTH_REQUIRED` | Authentication required |
| `AUTH_INVALID` | Invalid credentials |
| `AUTH_EXPIRED` | Token expired |
| `AUTH_FORBIDDEN` | Not authorized for this resource |
| `AUTH_MFA_REQUIRED` | MFA verification required |

### Validation
| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Input validation failed |
| `INVALID_FORMAT` | Invalid data format |
| `MISSING_FIELD` | Required field missing |
| `INVALID_TYPE` | Wrong data type |

### Resource
| Code | Description |
|------|-------------|
| `NOT_FOUND` | Resource not found |
| `ALREADY_EXISTS` | Resource already exists |
| `CONFLICT` | Resource state conflict |
| `DELETED` | Resource has been deleted |

### Rate Limiting
| Code | Description |
|------|-------------|
| `RATE_LIMITED` | Too many requests |
| `QUOTA_EXCEEDED` | API quota exceeded |

### Server
| Code | Description |
|------|-------------|
| `INTERNAL_ERROR` | Internal server error |
| `SERVICE_UNAVAILABLE` | Service temporarily unavailable |
| `UPSTREAM_ERROR` | External service error |

---

## Authentication Headers

### Request Headers
```
Authorization: Bearer <access_token>
X-API-Key: <api_key>                    # For service-to-service
X-Request-ID: <unique_id>               # For request tracing
```

### Response Headers (Authentication)
```
WWW-Authenticate: Bearer realm="api"    # On 401 responses
X-RateLimit-Limit: 100                  # Requests allowed per window
X-RateLimit-Remaining: 95               # Requests remaining
X-RateLimit-Reset: 1640995200           # Unix timestamp of reset
Retry-After: 60                         # Seconds until retry (on 429)
```

---

## Request Validation

### Content-Type Requirements
- POST/PATCH: Require `Content-Type: application/json`
- GET/DELETE: No body expected
- File uploads: `Content-Type: multipart/form-data`

### Validation Order
1. Authentication (401 if missing/invalid)
2. Authorization (403 if not permitted)
3. Request format (400 if malformed)
4. Business validation (422 if invalid data)

### Validation Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": ["Invalid email format", "Email already in use"],
      "age": ["Must be at least 18"]
    }
  }
}
```

---

## Pagination

- ALWAYS paginate list endpoints
- Default page size: 20 items
- Maximum page size: 100 items
- Use consistent query parameters

### Query Parameters
```
GET /api/v1/users?page=2&pageSize=20
GET /api/v1/users?cursor=abc123&limit=20  # Cursor-based alternative
```

### Pagination Response
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 2,
    "pageSize": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}
```

---

## Filtering, Sorting & Search

### Filtering
```
GET /api/v1/users?status=active&role=admin
GET /api/v1/orders?created_after=2025-01-01&created_before=2025-12-31
```

### Sorting
```
GET /api/v1/users?sort=createdAt         # Ascending (default)
GET /api/v1/users?sort=-createdAt        # Descending
GET /api/v1/users?sort=name,-createdAt   # Multiple fields
```

### Search
```
GET /api/v1/users?q=john                 # Full-text search
GET /api/v1/users?email_contains=@gmail  # Field-specific search
```

---

## URL Structure

### Standard CRUD Operations
```
GET    /api/v1/users              # List all users (paginated)
GET    /api/v1/users/:id          # Get specific user
POST   /api/v1/users              # Create new user
PATCH  /api/v1/users/:id          # Update user
DELETE /api/v1/users/:id          # Delete user
```

### Nested Resources
```
GET    /api/v1/users/:id/orders   # Get orders for user
POST   /api/v1/users/:id/orders   # Create order for user
```

### Actions (Non-CRUD Operations)
```
POST   /api/v1/users/:id/activate    # Action on resource
POST   /api/v1/users/:id/reset-password
POST   /api/v1/orders/:id/cancel
```

### Bulk Operations
```
POST   /api/v1/users/bulk           # Bulk create
PATCH  /api/v1/users/bulk           # Bulk update
DELETE /api/v1/users/bulk           # Bulk delete (with body)
```

---

## Caching Headers

### Cacheable Responses (GET requests)
```
Cache-Control: public, max-age=3600          # Cache for 1 hour
Cache-Control: private, max-age=300          # User-specific, 5 min
ETag: "abc123"                                # Version identifier
Last-Modified: Wed, 01 Jan 2025 00:00:00 GMT
```

### Non-Cacheable Responses
```
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
```

### Conditional Requests
```
# Client sends
If-None-Match: "abc123"
If-Modified-Since: Wed, 01 Jan 2025 00:00:00 GMT

# Server returns 304 Not Modified if unchanged
```

---

## Idempotency

### Idempotent Methods
- GET, DELETE are naturally idempotent
- PATCH should be designed to be idempotent
- POST is NOT idempotent by default

### Idempotency Keys for POST
```
POST /api/v1/payments
Idempotency-Key: unique-request-id-123

# Server stores result, returns same response for duplicate key
```

---

## API Documentation

### Required Documentation
- Endpoint URL and HTTP method
- Request parameters (path, query, body)
- Request/response examples
- Authentication requirements
- Error responses
- Rate limits

### OpenAPI/Swagger Specification
- Maintain OpenAPI spec for all endpoints
- Generate documentation from spec
- Use spec for client SDK generation
- Validate requests against spec in development

---

# Logging Standards

## What to Log

- All security events (authentication, authorization failures)
- API request/response metadata (not bodies with sensitive data)
- Use appropriate log levels (debug, info, warn, error)
- Include request IDs for tracing
- Use structured logging (JSON format)
- Include timestamps in UTC

---

## Log Levels

| Level | Use Case |
|-------|----------|
| **debug** | Detailed information for debugging (development only) |
| **info** | Request completed, user action, state change |
| **warn** | Recoverable issue, deprecated feature used |
| **error** | Error requiring attention, request failed |

---

## Log Entry Format

```json
{
  "timestamp": "2025-01-01T10:30:00.000Z",
  "level": "info",
  "message": "Request completed",
  "requestId": "req_abc123",
  "method": "POST",
  "path": "/api/v1/users",
  "statusCode": 201,
  "duration": 45,
  "userId": "usr_456",
  "ip": "192.168.1.1",
  "userAgent": "Mozilla/5.0..."
}
```

### Error Log Entry
```json
{
  "timestamp": "2025-01-01T10:30:00.000Z",
  "level": "error",
  "message": "Database connection failed",
  "requestId": "req_abc123",
  "error": {
    "name": "ConnectionError",
    "message": "Connection timeout after 5000ms",
    "stack": "..."
  },
  "context": {
    "database": "primary",
    "operation": "query"
  }
}
```

---

## What NOT to Log

- Passwords or password hashes
- API keys or tokens (mask if needed: `sk_...abc`)
- Credit card numbers (mask: `****1234`)
- Social security numbers
- Personal identification numbers
- Full request/response bodies with PII
- Session IDs in production (or mask them)

---

## Request Tracing

### Generate Request ID
- Generate unique ID at API gateway/entry point
- Pass through all services via `X-Request-ID` header
- Include in all log entries for that request
- Return in error responses for support reference

### Correlation Example
```
[req_abc123] --> API Gateway
[req_abc123] --> Auth Service
[req_abc123] --> User Service
[req_abc123] --> Database Query
[req_abc123] <-- Response 201 (45ms)
```
