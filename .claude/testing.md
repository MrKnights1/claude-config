# Testing Requirements

## Test Coverage

- Write tests for all business logic and critical paths
- Minimum test coverage percentage (e.g., 80%)
- Test file naming convention (e.g., `*.test.ts` or `*.spec.ts`)
- Include integration tests for API endpoints

## Unit Tests

- Test individual functions in isolation
- Mock external dependencies (API calls, database)
- Test edge cases: empty arrays, null values, boundary conditions
- Test error handling: invalid inputs, exceptions
- Place test files next to source files OR in `/tests` directory

## Integration Tests

- Test API endpoints end-to-end
- Use test database (not production or development database)
- Test authentication and authorization flows
- Test database transactions and rollbacks
- Clean up test data after each test

## Testing Best Practices

- ALWAYS run tests before pushing to remote
- NEVER commit failing tests
- Keep tests fast (unit tests < 100ms, integration < 1s each)
- Use descriptive test names that explain what is being tested
- One assertion per test (or closely related assertions)
- Avoid testing implementation details (test behavior, not internal state)

## Test Edge Cases and Error Conditions

- Test with empty inputs
- Test with null/undefined values
- Test with invalid data types
- Test with boundary values (min/max)
- Test concurrent operations
- Test timeout scenarios

## Database Testing

- Use transactions for multi-step database operations
- Test rollback behavior on errors
- Test unique constraints
- Test foreign key constraints
- Clean up test data properly
