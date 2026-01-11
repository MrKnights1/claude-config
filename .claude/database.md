# Database Guidelines

## Migration Files

- ALWAYS create migration files for schema changes
- NEVER modify database directly in production
- Name migrations: `{number}_{description}_{issue-number}.sql`
  - Example: `001_add_user_roles_73.sql`
  - Example: `002_create_events_table_45.sql`
- Add indexes for frequently queried columns
- Test migrations on copy of production data
- Document schema changes in migration comments

---

## Migration Best Practices

- NEVER modify existing migrations (create new one instead)
- ALWAYS backup database before running migrations in production
- Use transactions for multi-step migrations
- Make migrations reversible when possible (include DOWN/rollback logic)
- Test both up AND down migrations
- Keep migrations small and focused (one logical change per migration)
- Run migrations as part of deployment process
- Version control all migrations

---

## Migration Structure

Each migration should have:
1. **Up migration**: Apply the change
2. **Down migration**: Rollback the change (if possible)
3. **Comments**: Explain why change is needed

### Example Migration (SQL)
```sql
-- Migration: 005_add_user_roles_73.sql
-- Issue: #73
-- Description: Add role column to support admin/user permissions
-- Author: developer@example.com
-- Date: 2025-01-01

-- Up Migration
BEGIN;

ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'user';
CREATE INDEX idx_users_role ON users(role);

COMMIT;

-- Down Migration (commented, run manually if needed)
-- BEGIN;
-- DROP INDEX idx_users_role;
-- ALTER TABLE users DROP COLUMN role;
-- COMMIT;
```

### Example Migration (ORM - Knex.js)
```typescript
// migrations/20250101_add_user_roles.ts
import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.string('role', 20).notNullable().defaultTo('user');
    table.index('role');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.alterTable('users', (table) => {
    table.dropIndex('role');
    table.dropColumn('role');
  });
}
```

---

## Primary Key Best Practices

### Use Unsigned Integers for IDs
```sql
-- Good: Unsigned gives double the positive range
CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,  -- MySQL
  -- or
  id SERIAL PRIMARY KEY,                        -- PostgreSQL (always unsigned)
  ...
);
```

### Why Unsigned?
- IDs are always positive (no need for negative values)
- Double the range: ~4.3 billion vs ~2.1 billion for signed INT
- Makes intent clear that IDs should never be negative
- Catches bugs if negative values are accidentally used

### ID Type Guidelines
| Table Size | Recommended Type |
|------------|------------------|
| < 16 million rows | `MEDIUMINT UNSIGNED` (MySQL) |
| < 4 billion rows | `INT UNSIGNED` / `SERIAL` |
| > 4 billion rows | `BIGINT UNSIGNED` / `BIGSERIAL` |

### Alternative: UUIDs
```sql
-- Use for distributed systems or when IDs shouldn't be guessable
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- PostgreSQL
  ...
);
```

---

## Dangerous Operations

Handle these with extra care:

### Adding NOT NULL Columns
```sql
-- Step 1: Add as nullable
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Populate data
UPDATE users SET phone = 'unknown' WHERE phone IS NULL;

-- Step 3: Add NOT NULL constraint (separate migration)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

### Dropping Columns
```sql
-- Step 1: Deprecate in code (stop using column)
-- Step 2: Wait for deployment to propagate
-- Step 3: Drop column in later migration
ALTER TABLE users DROP COLUMN deprecated_field;
```

### Renaming Columns
```sql
-- Option 1: Direct rename (if DB supports and no downtime needed)
ALTER TABLE users RENAME COLUMN old_name TO new_name;

-- Option 2: Safe multi-step rename
-- 1. Add new column
-- 2. Copy data
-- 3. Update code to use new column
-- 4. Drop old column
```

### Large Data Migrations
```sql
-- Use batch processing, not single transaction
DO $$
DECLARE
  batch_size INT := 1000;
  offset_val INT := 0;
BEGIN
  LOOP
    UPDATE users
    SET status = 'active'
    WHERE id IN (
      SELECT id FROM users
      WHERE status IS NULL
      LIMIT batch_size OFFSET offset_val
    );

    EXIT WHEN NOT FOUND;
    offset_val := offset_val + batch_size;
    COMMIT;
  END LOOP;
END $$;
```

---

## ORM Usage Patterns

### Query Builder Best Practices
```typescript
// Good: Select specific columns
const users = await db('users')
  .select('id', 'email', 'name')
  .where('status', 'active');

// Bad: Select all columns
const users = await db('users').select('*');

// Good: Use transactions
await db.transaction(async (trx) => {
  const userId = await trx('users').insert({ email });
  await trx('profiles').insert({ userId, name });
});

// Good: Eager loading to avoid N+1
const users = await User.query()
  .withGraphFetched('orders')
  .where('status', 'active');
```

### Model Patterns
```typescript
// Define relationships in models
class User extends Model {
  static tableName = 'users';

  static relationMappings = {
    orders: {
      relation: Model.HasManyRelation,
      modelClass: Order,
      join: {
        from: 'users.id',
        to: 'orders.user_id'
      }
    }
  };
}
```

### Avoiding N+1 Queries
```typescript
// Bad: N+1 query
const users = await User.query();
for (const user of users) {
  const orders = await user.$relatedQuery('orders'); // N queries!
}

// Good: Eager loading
const users = await User.query().withGraphFetched('orders'); // 2 queries

// Good: Join for filtering
const usersWithOrders = await User.query()
  .joinRelated('orders')
  .where('orders.status', 'completed');
```

---

## Connection Pooling

### Configuration Guidelines
```typescript
// knex.js example
const config = {
  client: 'pg',
  connection: process.env.DATABASE_URL,
  pool: {
    min: 2,                    // Minimum connections
    max: 10,                   // Maximum connections
    acquireTimeoutMillis: 30000, // Wait time for connection
    idleTimeoutMillis: 10000,  // Close idle connections after
    reapIntervalMillis: 1000,  // Check for idle connections
  }
};
```

### Pool Size Guidelines
| Environment | Min | Max | Notes |
|-------------|-----|-----|-------|
| Development | 1 | 5 | Lower to save resources |
| Production | 2 | 10-20 | Based on expected load |
| Serverless | 1 | 1 | Use external pooler |

### Connection Pool Best Practices
- NEVER create new connections per request
- Use connection pooler for serverless (PgBouncer, Prisma Accelerate)
- Monitor connection usage and adjust pool size
- Set appropriate timeouts to prevent connection leaks
- Release connections promptly (use `finally` blocks)

```typescript
// Good: Connection is automatically returned to pool
async function getUser(id: string) {
  return await db('users').where('id', id).first();
}

// Bad: Manual connection management (avoid)
const connection = await db.client.acquireConnection();
try {
  // ... use connection
} finally {
  db.client.releaseConnection(connection);
}
```

---

## Database Seeding

### Seed File Structure
```
seeds/
├── 01_users.ts           # Run first (base data)
├── 02_categories.ts      # Dependencies on users
├── 03_products.ts        # Dependencies on categories
└── development/          # Dev-only seed data
    └── sample_data.ts
```

### Seed Best Practices
```typescript
// seeds/01_users.ts
export async function seed(knex: Knex): Promise<void> {
  // Clear existing data (development only!)
  if (process.env.NODE_ENV === 'development') {
    await knex('users').del();
  }

  // Insert seed data
  await knex('users').insert([
    { id: 'admin-1', email: 'admin@example.com', role: 'admin' },
    { id: 'user-1', email: 'user@example.com', role: 'user' },
  ]);
}
```

### Seed Guidelines
- Use fixed IDs for reference data (easier testing)
- NEVER run destructive seeds in production
- Separate reference data from test data
- Use factories for large datasets

---

## Indexing Strategy

### When to Add Indexes
- Foreign key columns used in JOINs
- Columns in WHERE clauses (frequently filtered)
- Columns in ORDER BY (frequently sorted)
- Columns in GROUP BY
- Unique constraints (automatically indexed)

### When NOT to Add Indexes
- Small tables (< 1000 rows)
- Columns rarely used in queries
- Columns with low cardinality (boolean, status with few values)
- Tables with heavy INSERT/UPDATE operations

### Index Types
```sql
-- B-tree (default, most common)
CREATE INDEX idx_users_email ON users(email);

-- Partial index (for filtered queries)
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';

-- Composite index (multi-column)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);

-- Unique index
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);

-- Full-text search (PostgreSQL)
CREATE INDEX idx_posts_search ON posts USING gin(to_tsvector('english', title || ' ' || body));
```

### Index Naming Convention
```
idx_{table}_{column(s)}[_type]
```
Examples:
- `idx_users_email`
- `idx_orders_user_id_created_at`
- `idx_posts_search_gin`

---

## Query Optimization

### General Rules
- ALWAYS use parameterized queries (prevent SQL injection)
- Avoid `SELECT *` (specify needed columns)
- Use `EXPLAIN ANALYZE` to analyze query performance
- Avoid N+1 queries (use JOINs or eager loading)
- Use pagination for large result sets
- Add appropriate indexes based on query patterns

### Query Analysis
```sql
-- Analyze query execution plan
EXPLAIN ANALYZE
SELECT u.*, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
GROUP BY u.id;

-- Look for:
-- - Seq Scan on large tables (add index)
-- - High actual rows vs estimated rows (update statistics)
-- - Nested loops on large datasets (consider hash join)
```

### Common Optimizations
```sql
-- Use EXISTS instead of COUNT for existence check
-- Bad
SELECT * FROM users WHERE (SELECT COUNT(*) FROM orders WHERE user_id = users.id) > 0;

-- Good
SELECT * FROM users WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = users.id);

-- Use LIMIT for single row queries
-- Bad
SELECT * FROM users WHERE email = 'test@example.com';

-- Good
SELECT * FROM users WHERE email = 'test@example.com' LIMIT 1;

-- Batch inserts
-- Bad: Multiple INSERT statements
INSERT INTO logs (message) VALUES ('log1');
INSERT INTO logs (message) VALUES ('log2');

-- Good: Single INSERT with multiple values
INSERT INTO logs (message) VALUES ('log1'), ('log2'), ('log3');
```

---

## Backup & Recovery

### Backup Strategy
| Type | Frequency | Retention | Use Case |
|------|-----------|-----------|----------|
| Full backup | Daily | 30 days | Complete restore |
| Incremental | Hourly | 7 days | Point-in-time recovery |
| Transaction logs | Continuous | 7 days | Minimal data loss |

### Backup Commands (PostgreSQL)
```bash
# Full backup
pg_dump -Fc database_name > backup_$(date +%Y%m%d).dump

# Restore from backup
pg_restore -d database_name backup_20250101.dump

# Point-in-time recovery (requires WAL archiving)
pg_restore --target-time="2025-01-01 12:00:00" -d database_name
```

### Backup Best Practices
- Test restore process regularly (monthly)
- Store backups in different location than database
- Encrypt backup files at rest
- Monitor backup job success/failure
- Document recovery procedures
- Calculate Recovery Point Objective (RPO) and Recovery Time Objective (RTO)

---

## Soft Deletes vs Hard Deletes

### Soft Deletes
```sql
-- Add deleted_at column
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 'user-1';

-- Query active records
SELECT * FROM users WHERE deleted_at IS NULL;

-- Create partial index for performance
CREATE INDEX idx_users_active ON users(email) WHERE deleted_at IS NULL;
```

### When to Use Soft Deletes
- Audit trail required
- Data recovery needs
- Referential integrity concerns
- Legal/compliance requirements

### When to Use Hard Deletes
- GDPR "right to be forgotten"
- Performance-critical tables
- Temporary/session data
- No audit requirements

---

## Audit Logging

### Audit Table Pattern
```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id VARCHAR(100) NOT NULL,
  action VARCHAR(20) NOT NULL,  -- INSERT, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  user_id VARCHAR(100),
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_created_at ON audit_log(created_at);
```

### Trigger-Based Auditing (PostgreSQL)
```sql
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user_id)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id)::text,
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
    current_setting('app.current_user_id', true)
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply to table
CREATE TRIGGER users_audit
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

---

## Database Testing

### Test Database Setup
```typescript
// Use separate test database
const testConfig = {
  ...config,
  connection: process.env.TEST_DATABASE_URL
};

// Reset before each test suite
beforeAll(async () => {
  await db.migrate.latest();
  await db.seed.run();
});

// Clean after each test
afterEach(async () => {
  await db('users').del();
  await db('orders').del();
});

// Destroy connection after all tests
afterAll(async () => {
  await db.destroy();
});
```

### Transaction-Based Test Isolation
```typescript
// Wrap each test in transaction, rollback after
let trx: Knex.Transaction;

beforeEach(async () => {
  trx = await db.transaction();
});

afterEach(async () => {
  await trx.rollback();
});

it('creates user', async () => {
  await trx('users').insert({ email: 'test@example.com' });
  const user = await trx('users').where('email', 'test@example.com').first();
  expect(user).toBeDefined();
  // Rollback happens in afterEach - no cleanup needed
});
```
