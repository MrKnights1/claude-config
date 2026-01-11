# Testing Requirements

## Test Coverage

- Write tests for all business logic and critical paths
- Minimum test coverage: 80% for critical modules, 60% overall
- Test file naming: `*.test.ts`, `*.spec.ts`, or `*.test.js`
- Include unit, integration, and E2E tests as appropriate

---

## Test Organization

### File Structure
```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx       # Co-located unit test
├── services/
│   ├── auth.ts
│   └── auth.test.ts
tests/
├── integration/              # Integration tests
│   ├── api/
│   │   └── users.test.ts
│   └── database/
│       └── migrations.test.ts
├── e2e/                      # End-to-end tests
│   ├── auth.e2e.ts
│   └── checkout.e2e.ts
├── fixtures/                 # Shared test data
│   ├── users.json
│   └── products.json
└── helpers/                  # Test utilities
    ├── setup.ts
    └── factories.ts
```

### Naming Conventions
- Describe what is being tested: `should return user when valid ID provided`
- Group related tests with `describe` blocks
- Use consistent patterns: `[unit]`, `[integration]`, `[e2e]` prefixes if needed

---

## Unit Tests

- Test individual functions in isolation
- Mock external dependencies (API calls, database, file system)
- Test edge cases: empty arrays, null values, boundary conditions
- Test error handling: invalid inputs, exceptions
- Keep tests fast: < 100ms per test
- One logical assertion per test (related assertions OK)

### What to Unit Test
- Pure functions and utilities
- Business logic and calculations
- Data transformations
- Validation functions
- State management reducers/actions

### What NOT to Unit Test
- Framework internals (React, Express, etc.)
- Third-party library behavior
- Simple getters/setters with no logic
- Configuration files

---

## Integration Tests

- Test API endpoints end-to-end
- Use test database (NEVER production or development)
- Test authentication and authorization flows
- Test database transactions and rollbacks
- Clean up test data after each test
- Test external service integrations with mocks/stubs

### API Integration Test Pattern
```typescript
describe('POST /api/users', () => {
  beforeEach(async () => {
    await db.clean();
    await db.seed();
  });

  it('creates user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', password: 'secure123' });

    expect(response.status).toBe(201);
    expect(response.body.data.email).toBe('test@example.com');
  });

  it('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', password: 'secure123' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

---

## End-to-End (E2E) Tests

- Test critical user flows (login, checkout, signup)
- Run against staging environment or local with seeded data
- Keep E2E tests minimal and focused on happy paths
- Use page object pattern for maintainability
- Run E2E tests in CI before deployment

### Critical Flows to Test
- User registration and login
- Password reset flow
- Main business workflows (checkout, booking, etc.)
- Permission-based access (admin vs user)

---

## Mocking Best Practices

### When to Mock
- External APIs and services
- Database calls in unit tests
- Time-dependent functions (`Date.now()`, timers)
- File system operations
- Environment variables

### When NOT to Mock
- The code under test
- Simple data transformations
- Integration test dependencies (use real DB)

### Mock Patterns
```typescript
// Mock external service
jest.mock('../services/emailService', () => ({
  sendEmail: jest.fn().mockResolvedValue({ success: true })
}));

// Mock time
jest.useFakeTimers();
jest.setSystemTime(new Date('2025-01-01'));

// Mock environment
process.env.API_KEY = 'test-key';
```

---

## Test Fixtures & Factories

### Fixtures (Static Test Data)
```typescript
// tests/fixtures/users.ts
export const validUser = {
  email: 'test@example.com',
  name: 'Test User',
  role: 'user'
};

export const adminUser = {
  email: 'admin@example.com',
  name: 'Admin User',
  role: 'admin'
};
```

### Factories (Dynamic Test Data)
```typescript
// tests/helpers/factories.ts
export function createUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName(),
    createdAt: new Date(),
    ...overrides
  };
}

// Usage
const user = createUser({ role: 'admin' });
```

---

## Test Database Management

- Use separate database for tests (e.g., `app_test`)
- Reset database before each test suite
- Use transactions for test isolation when possible
- Seed minimal required data per test

### Database Test Setup
```typescript
// tests/helpers/setup.ts
beforeAll(async () => {
  await db.migrate.latest();
});

beforeEach(async () => {
  await db.seed.run();
});

afterEach(async () => {
  await db.clean();
});

afterAll(async () => {
  await db.destroy();
});
```

---

## CI/CD Integration

### Test Pipeline Order
1. Lint and type check (fastest)
2. Unit tests
3. Integration tests
4. E2E tests (slowest, run on staging)

### CI Configuration Requirements
- Run tests on every PR
- Block merge if tests fail
- Generate coverage reports
- Cache dependencies for speed
- Use test database in CI environment

### Parallel Test Execution
- Unit tests: Run in parallel (no shared state)
- Integration tests: May need sequential for DB access
- E2E tests: Run in parallel with isolated data

---

## Testing Best Practices

### DO
- Run tests before pushing to remote
- Write tests before or alongside code (TDD optional but encouraged)
- Test behavior, not implementation details
- Use descriptive test names that explain what is being tested
- Keep tests independent (no order dependencies)
- Clean up test data and side effects

### DON'T
- Commit failing tests
- Test private methods directly (test through public interface)
- Write tests that depend on other tests
- Use production data in tests
- Mock everything (integration tests need real dependencies)
- Ignore flaky tests (fix or delete them)

---

## Edge Cases Checklist

Always test these scenarios:

### Input Validation
- [ ] Empty strings and arrays
- [ ] Null and undefined values
- [ ] Invalid data types
- [ ] Boundary values (0, -1, MAX_INT)
- [ ] Special characters and unicode
- [ ] Very long strings
- [ ] Malformed JSON/data

### State & Timing
- [ ] Concurrent operations
- [ ] Race conditions
- [ ] Timeout scenarios
- [ ] Retry logic
- [ ] Empty state (no data)
- [ ] Loading states

### Error Conditions
- [ ] Network failures
- [ ] Database connection errors
- [ ] Invalid authentication
- [ ] Permission denied
- [ ] Resource not found
- [ ] Rate limiting

---

## Performance Testing (Optional)

For performance-critical applications:

- Benchmark critical functions
- Load test API endpoints
- Test with realistic data volumes
- Monitor memory usage in tests
- Set performance budgets (response time < 200ms)

```typescript
// Simple performance test
it('processes 1000 items under 100ms', () => {
  const items = Array(1000).fill(testItem);
  const start = performance.now();

  processItems(items);

  expect(performance.now() - start).toBeLessThan(100);
});
```
