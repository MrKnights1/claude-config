# Database Guidelines

## Migration Files

- ALWAYS create migration files for schema changes
- NEVER modify database directly in production
- Name migrations: `{number}_{description}_{issue-number}.sql` (e.g., `001_add_user_roles_73.sql` or `002_create_events_table_45.sql`)
- Add indexes for frequently queried columns
- Test migrations on copy of production data
- Keep database queries optimized (avoid N+1 queries)
- Document schema changes in migration comments

## Migration Best Practices

- NEVER modify existing migrations (create new one instead)
- ALWAYS backup database before running migrations in production
- Use transactions for multi-step migrations
- Make migrations reversible when possible (include DOWN/rollback logic)
- Test both up AND down migrations
- Keep migrations small and focused (one logical change per migration)
- Run migrations as part of deployment process

## Migration Structure

Each migration should have:
1. **Up migration**: Apply the change
2. **Down migration**: Rollback the change (if possible)
3. **Comments**: Explain why change is needed

**Example migration:**
```sql
-- Migration: 005_add_user_roles_73.sql
-- Issue: #73
-- Description: Add role column to support admin/user permissions

-- Up Migration
ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'user';
CREATE INDEX idx_users_role ON users(role);

-- Down Migration
-- DROP INDEX idx_users_role;
-- ALTER TABLE users DROP COLUMN role;
```

## Dangerous Operations

- Adding NOT NULL columns: Add as nullable first, populate data, then add constraint
- Dropping columns: Deprecate first, then drop in later migration
- Renaming columns: Create new column, copy data, drop old column
- Large data migrations: Use batch processing, not single transaction

## Indexing Strategy

- Add indexes AFTER initial table creation (speeds up creation)
- Index foreign key columns used in JOINs
- Index columns used in WHERE clauses
- Index columns used in ORDER BY (for common sorting)
- Avoid over-indexing (slows down INSERT/UPDATE operations)
- Use partial indexes for common filtered queries
- Monitor slow queries and add indexes as needed

## Query Optimization

- ALWAYS use parameterized queries (prevent SQL injection)
- Avoid SELECT * (specify needed columns)
- Use EXPLAIN to analyze query performance
- Avoid N+1 queries (use JOINs or eager loading)
- Use database query logging in development
- Set up slow query logging in production
- Use connection pooling (don't create new connection per query)
