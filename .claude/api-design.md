# API Design Standards

## RESTful Conventions

- Model resources as nouns; model actions as HTTP methods (GET, POST, PATCH, PUT, DELETE).
- Use plural nouns for collection endpoints (`/users`, not `/user`).
- Use kebab-case in URL path segments (`/user-profiles`, not `/userProfiles` or `/user_profiles`).
- Use a consistent JSON property naming convention across the API — camelCase for APIs consumed primarily by JavaScript/JSON clients, snake_case for APIs primarily consumed by Python/Ruby clients. Pick one and apply it everywhere.
- Use PATCH for partial updates; reserve PUT for full resource replacement.
- Return HTTP status codes that match RFC 9110 semantics (see status code table below).
- Keep response shape consistent across endpoints.
- Optimize URL hierarchy for the consumer, not the underlying data model.

---

## HTTP Status Codes

Status codes carry contractual meaning per RFC 9110. Pick the most specific code that applies.

### Success (2xx)

| Code | Name | Use Case |
|------|------|----------|
| 200 | OK | Successful GET, PATCH, PUT, or DELETE returning a body |
| 201 | Created | Successful POST that created a resource — include a `Location` header pointing to the new resource |
| 202 | Accepted | Request accepted for asynchronous processing |
| 204 | No Content | Successful request with no response body (often DELETE) |

### Redirection (3xx)

| Code | Name | Use Case |
|------|------|----------|
| 301 | Moved Permanently | Resource has a new permanent URL |
| 304 | Not Modified | Conditional GET matched — client may use cached copy |
| 307 | Temporary Redirect | Same method, different URL, one-time |
| 308 | Permanent Redirect | Same method, new permanent URL |

### Client Errors (4xx)

| Code | Name | Use Case |
|------|------|----------|
| 400 | Bad Request | Request cannot be parsed — malformed JSON, missing required headers, invalid encoding |
| 401 | Unauthorized | Authentication missing or invalid |
| 403 | Forbidden | Authenticated but lacks permission for this resource |
| 404 | Not Found | Resource does not exist (or caller may not learn of its existence) |
| 405 | Method Not Allowed | HTTP method not supported for this resource — include `Allow` header |
| 406 | Not Acceptable | Cannot produce response matching `Accept` header |
| 409 | Conflict | State conflict — duplicate, version mismatch, concurrent modification |
| 410 | Gone | Resource permanently removed |
| 412 | Precondition Failed | `If-Match` / `If-None-Match` precondition failed |
| 415 | Unsupported Media Type | Request body content type not supported |
| 422 | Unprocessable Content | Request parsed successfully but failed semantic or business validation |
| 428 | Precondition Required | Conditional request required to prevent lost updates |
| 429 | Too Many Requests | Rate limit exceeded — include `Retry-After` |

The 400 vs 422 distinction is structural vs semantic: 400 for syntax errors the parser rejected, 422 for valid JSON that violated validation rules.

### Server Errors (5xx)

| Code | Name | Use Case |
|------|------|----------|
| 500 | Internal Server Error | Unexpected server error |
| 502 | Bad Gateway | Upstream service returned an invalid response |
| 503 | Service Unavailable | Maintenance, overload, or circuit breaker open — include `Retry-After` when known |
| 504 | Gateway Timeout | Upstream service did not respond in time |

---

## Error Response Format

Use RFC 9457 Problem Details for HTTP APIs (`application/problem+json`) as the error response format. RFC 9457 obsoletes RFC 7807 and is the current standard.

### Standard Fields

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Recommended | URI identifying the error type (use `about:blank` if none) |
| `title` | Recommended | Short, plain-text summary of the error type |
| `status` | Recommended | HTTP status code, mirrored from the response |
| `detail` | Optional | Plain-text explanation specific to this occurrence |
| `instance` | Optional | URI identifying the specific occurrence |

Extension members are allowed and encouraged for machine-readable context (error codes, field-level details, request IDs).

### Error Response Example

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation failed",
  "status": 422,
  "detail": "One or more fields failed validation.",
  "instance": "/api/users",
  "code": "VALIDATION_ERROR",
  "requestId": "req_abc123",
  "errors": [
    { "field": "email", "code": "INVALID_FORMAT", "message": "Invalid email format" },
    { "field": "password", "code": "TOO_SHORT", "message": "Must be at least 8 characters" }
  ]
}
```

### Single Resource Response

```json
{
  "id": "usr_123",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

Wrap collections and paginated responses in an envelope with `data` and `meta`/`links`; return single resources flat.

---

## Standard Error Codes

Use machine-readable error codes as an extension field of the Problem Details response. Codes are stable contract; human-readable messages may change.

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
| `GONE` | Resource has been permanently deleted |

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
```

### Response Headers (Authentication)

```
WWW-Authenticate: Bearer realm="api"    # On 401 responses
```

---

## Request Validation

### Content-Type Requirements

- POST, PATCH, PUT: Require `Content-Type: application/json` (or the specific media type expected).
- GET, DELETE: No body expected.
- File uploads: `Content-Type: multipart/form-data`.

Reject mismatched content types with 415 Unsupported Media Type.

### Validation Order

1. Authentication (401 if missing or invalid)
2. Authorization (403 if not permitted)
3. Content type (415 if unsupported)
4. Request parsing and structure (400 if malformed)
5. Semantic and business validation (422 if invalid data)

### Field-Level Error Format

Return all validation errors in a single response — do not fail-fast on the first error.

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation failed",
  "status": 422,
  "code": "VALIDATION_ERROR",
  "errors": [
    { "field": "email", "code": "INVALID_FORMAT", "message": "Invalid email format" },
    { "field": "email", "code": "ALREADY_EXISTS", "message": "Email already in use" },
    { "field": "age", "code": "OUT_OF_RANGE", "message": "Must be at least 18" }
  ]
}
```

---

## Pagination

Paginate every list endpoint. Unbounded collections will eventually break.

### Pagination Style Selection

| Style | Use For | Avoid For |
|-------|---------|-----------|
| Cursor-based | Large, frequently-changing collections, infinite scroll, event feeds | Random page access |
| Offset/page-based | Small, stable collections, admin tables, parallel page fetching | Large or mutable collections |

Cursor-based pagination is the default for production APIs. Offset pagination skips or duplicates rows when items are inserted or deleted during traversal, and degrades to O(N) on large tables.

### Defaults and Limits

- Default page size: 20 items.
- Maximum page size: 100 items.
- Reject `limit` values above the maximum with 400.

### Cursor-Based Query Parameters

```
GET /api/users?cursor=eyJpZCI6MTIzfQ&limit=20
```

### Cursor-Based Response

```json
{
  "data": [...],
  "meta": {
    "limit": 20,
    "hasMore": true
  },
  "links": {
    "next": "/api/users?cursor=eyJpZCI6MTQzfQ&limit=20",
    "prev": "/api/users?cursor=eyJpZCI6MTAzfQ&limit=20"
  }
}
```

### Offset-Based Query Parameters

```
GET /api/users?page=2&pageSize=20
```

### Offset-Based Response

```json
{
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

Cursors must be opaque to the client. Base64-encode the underlying state.

---

## Filtering, Sorting & Search

### Filtering

```
GET /api/users?status=active&role=admin
GET /api/orders?createdAfter=2025-01-01&createdBefore=2025-12-31
```

### Sorting

```
GET /api/users?sort=createdAt         # Ascending (default)
GET /api/users?sort=-createdAt        # Descending (leading minus)
GET /api/users?sort=name,-createdAt   # Multiple fields, in order
```

### Search

```
GET /api/users?q=john                 # Full-text search
GET /api/users?email_contains=@gmail  # Field-specific search
```

Document allowed sort fields and filter operators per endpoint. Reject unknown fields with 400.

---

## URL Structure

### Standard CRUD Operations

```
GET    /api/users              # List users (paginated)
GET    /api/users/:id          # Get a specific user
POST   /api/users              # Create a user
PATCH  /api/users/:id          # Partial update
PUT    /api/users/:id          # Full replacement
DELETE /api/users/:id          # Delete a user
```

### Nested Resources

Nest only one level deep. Beyond that, use top-level resources with filters.

```
GET    /api/users/:id/orders   # List a user's orders
POST   /api/users/:id/orders   # Create an order for a user
GET    /api/orders?userId=:id  # Equivalent — preferred for deep relations
```

### Actions (Non-CRUD Operations)

When an operation does not map to CRUD, use a verb sub-resource on POST.

```
POST   /api/users/:id/activate
POST   /api/users/:id/reset-password
POST   /api/orders/:id/cancel
```

### Bulk Operations

```
POST   /api/users/bulk           # Bulk create
PATCH  /api/users/bulk           # Bulk update
DELETE /api/users/bulk           # Bulk delete (with body)
```

Bulk endpoints must return per-item status — partial failure is the default expectation.

### Resource Identifiers

- IDs should be opaque strings, not sequential integers, in public APIs.
- User-supplied IDs must conform to RFC 1034 character rules (letters, digits, hyphen) when used in URL paths.

---

## Caching Headers

HTTP caching is governed by RFC 9111. Every cacheable GET response must declare its caching policy explicitly.

### Cacheable Responses

```
Cache-Control: public, max-age=3600          # Cache for 1 hour, shared caches OK
Cache-Control: private, max-age=300          # User-specific, browser only
ETag: "abc123"                               # Strong validator
Last-Modified: Wed, 01 Jan 2025 00:00:00 GMT # Weak validator
Vary: Accept, Accept-Language, Authorization # Vary on request headers that change the response
```

### Non-Cacheable Responses

```
Cache-Control: no-store
```

`no-store` means do not cache at all. `no-cache` means cache but revalidate before use — these are not equivalent.

### Conditional Requests

```
# Client request
If-None-Match: "abc123"
If-Modified-Since: Wed, 01 Jan 2025 00:00:00 GMT

# Server returns 304 Not Modified if unchanged, with no body
```

### Conditional Updates (Lost-Update Prevention)

```
PATCH /api/users/:id
If-Match: "abc123"
```

Return 412 Precondition Failed if the ETag does not match. Return 428 Precondition Required if `If-Match` is missing on a mutating request that requires it.

Return at least one validator (`ETag` or `Last-Modified`) on every cacheable response — they cut bandwidth and round trips even when `max-age` is short.

---

## CORS

- Reject `Access-Control-Allow-Origin: *` on any endpoint that accepts credentials or returns user-specific data.
- Maintain an explicit origin allowlist; reflect the matched origin back in `Access-Control-Allow-Origin`.
- Include `Vary: Origin` on responses where the allowed origin depends on the request.
- Set `Access-Control-Max-Age` to cache preflights — most browsers cap this at 7200 seconds (2 hours).
- Restrict `Access-Control-Allow-Methods` and `Access-Control-Allow-Headers` to what the endpoint actually accepts.
- Set `Access-Control-Allow-Credentials: true` only when cookies or `Authorization` headers must cross origins.

---

## Idempotency

### Idempotent Methods

- GET, HEAD, PUT, DELETE are idempotent by HTTP definition — multiple identical requests have the same effect as one.
- POST and PATCH are not idempotent by default.

### Idempotency-Key Header

For POST endpoints that create resources or trigger side effects, accept an `Idempotency-Key` request header per the IETF draft (`draft-ietf-httpapi-idempotency-key-header`).

```
POST /api/payments
Idempotency-Key: 1f4c3b8e-2a5d-4e7f-9c8a-3b2d1e0f5a6c
Content-Type: application/json
```

### Idempotency Rules

- Store the response (status code and body) keyed by `(client_or_account_id, idempotency_key)`.
- On a repeated request with the same key and same request body, return the stored response.
- On a repeated request with the same key but a different request body, return 422 with a clear error code.
- Keys should be opaque, client-generated, with at least 128 bits of entropy — UUIDv4 is the standard choice.
- Limit key length (Stripe uses 255 characters as a cap).
- Expire stored idempotency records after a documented retention window (typically 24 hours).
- Never use identifiers that contain PII as idempotency keys.

---

## Rate Limiting

Return rate limit metadata on every response, not only on 429s, so clients can adapt before they are throttled.

### Response Headers (IETF Draft)

```
RateLimit: limit=100, remaining=95, reset=30
RateLimit-Policy: 100;w=60
```

- `limit` — the current quota
- `remaining` — calls left in the current window
- `reset` — seconds until the window resets
- `w` — window size in seconds

### On 429 Responses

```
Retry-After: 60                          # Seconds until retry is permitted
```

`Retry-After` may also accept an HTTP-date.

---

## API Documentation

### Required for Every Endpoint

- HTTP method and URL pattern
- Path, query, header, and body parameters with types and constraints
- Request body schema with at least one example
- Response body schema for each documented status code, with examples
- Authentication and authorization requirements
- Error responses and their codes
- Rate limits

### OpenAPI Specification

- Maintain an OpenAPI 3.1 specification covering every endpoint. OpenAPI 3.1 aligns with JSON Schema 2020-12.
- Store the spec in version control alongside the code that implements it.
- Generate documentation, client SDKs, and request validators from the spec — do not maintain them by hand.
- Lint the spec in CI (e.g. with Spectral) to catch drift and style violations.
- Include both success and common error response examples for every operation.
- Tag operations to group related endpoints in the rendered docs.

---

# Logging Standards

> For security-specific logging requirements, see `security.md`.

## Log Format

- Emit logs as structured JSON, one event per line.
- Use UTC ISO-8601 timestamps with millisecond precision and explicit `Z` suffix.
- Use consistent field names across all services in the system.
- Include severity as a top-level `level` field.

## What to Log

- All inbound API request completion events (method, path, status, duration)
- All outbound calls to other services
- Authentication and authorization decisions, success and failure
- All errors and unexpected exceptions
- State changes to important domain entities
- Rate limit violations and other security-relevant events

## Log Levels

| Level | Use Case |
|-------|----------|
| `debug` | Detailed diagnostic information; disabled in production by default |
| `info` | Normal operations — request completed, action performed, state changed |
| `warn` | Recoverable issue, deprecated feature used, unusual but handled condition |
| `error` | Failure requiring attention — request failed, dependency unavailable, unexpected exception |

## Log Entry Format

```json
{
  "timestamp": "2025-01-01T10:30:00.000Z",
  "level": "info",
  "message": "Request completed",
  "service": "users-api",
  "traceId": "0af7651916cd43dd8448eb211c80319c",
  "spanId": "b7ad6b7169203331",
  "requestId": "req_abc123",
  "method": "POST",
  "path": "/api/users",
  "statusCode": 201,
  "durationMs": 45,
  "userId": "usr_456",
  "clientIp": "192.168.1.1"
}
```

### Error Log Entry

```json
{
  "timestamp": "2025-01-01T10:30:00.000Z",
  "level": "error",
  "message": "Database connection failed",
  "service": "users-api",
  "traceId": "0af7651916cd43dd8448eb211c80319c",
  "spanId": "b7ad6b7169203331",
  "requestId": "req_abc123",
  "error": {
    "type": "ConnectionError",
    "message": "Connection timeout after 5000ms",
    "stack": "..."
  },
  "context": {
    "database": "primary",
    "operation": "query"
  }
}
```

## What NOT to Log

- Passwords, password hashes, or password reset codes
- API keys, bearer tokens, refresh tokens, session IDs (mask if absolutely needed: `sk_...abc`)
- Credit card numbers, CVVs, PINs (mask: `****1234`)
- Government identifiers (SSN, passport, national ID)
- Health records or other regulated PII
- Full request or response bodies that may contain any of the above
- `Authorization`, `Cookie`, `Set-Cookie`, and `X-API-Key` header values

Sanitize all user-supplied data before logging — strip carriage returns, line feeds, and delimiter characters to prevent log injection.

---

## Distributed Tracing

### W3C Trace Context

Propagate trace context using the W3C `traceparent` and `tracestate` HTTP headers. These are the interoperable standard for distributed tracing across services and vendors.

```
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
tracestate: vendor1=value1,vendor2=value2
```

### traceparent Format

`version-traceId-parentId-flags`

- `version` — 2 hex digits, currently `00`
- `traceId` — 32 hex digits identifying the trace
- `parentId` — 16 hex digits identifying the parent span
- `flags` — 2 hex digits (`01` = sampled)

### Propagation Rules

- Every inbound request must be inspected for `traceparent`. If absent, generate a new trace ID at the edge.
- Every outbound request must include the current `traceparent`.
- `tracestate` must be preserved when propagating; vendors may prepend their own entry.
- `traceId` and `spanId` must appear on every log entry emitted within an active span.

### Request ID

Generate a per-request opaque `requestId` at the edge in addition to the trace ID, and return it on every response (typically `X-Request-Id`). The trace ID identifies the full distributed trace; the request ID identifies one API call and is what support and customers can quote.

```
X-Request-Id: req_abc123
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```
