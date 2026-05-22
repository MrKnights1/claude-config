# Database Guidelines

Universal rules for relational databases. Engine-agnostic. SQL examples illustrate principles, not mandates for a specific product.

---

## Migrations

### Core Rules

- Every schema change ships as a versioned, version-controlled migration file. Never run ad-hoc DDL against production.
- Once a migration is merged, treat it as immutable. Fix mistakes with a new migration, never by editing history.
- One logical change per migration. Small migrations are reversible; large ones are not.
- Test migrations against a recent production-data clone before production. Migration that runs in 2 seconds on dev can take 2 hours on prod-scale data.
- Take a backup immediately before destructive operations in production.

### Naming

Use a **timestamp prefix**, not a sequence number. Timestamps prevent the merge conflicts that hit projects using sequential numbering: two parallel branches both create migration `0042`, and one has to be renamed and re-ordered after merge. Timestamps don't collide because each branch's local clock produces a unique value.

`{timestamp}_{verb_noun}.{ext}` — the property that matters is the timestamp sorts chronologically and is unique per migration. Exact format is whatever the migration tool generates; common shapes:

| Shape | Example |
|---|---|
| Compact | `20230615143022_create_users_table` |
| Separated | `2026_02_27_161559_add_unique_slug_to_products` |
| Date + same-day counter | `2026_03_04_000000_create_user_carts_table` |

The name part is `snake_case`, verb-first (`create_users_table`, `add_email_to_users`, `drop_legacy_orders`) — describes the action, not just the subject. Use the file extension the migration tool expects.

### Reversibility

Every migration has an UP and a DOWN. Test both. Migrations that cannot be reversed (data loss, format change) must be flagged and require a snapshot before apply.

### Expand-Contract for Schema Changes That Can Break the App

Any rename, type change, or column drop must use expand-contract — never modify the live shape in one step. The pattern runs over multiple deploys so the application is always compatible with the schema it sees.

| Phase | Action | App state |
|-------|--------|-----------|
| Expand | Add new column/table/index alongside the old | Reads/writes old |
| Dual-write | App writes to both old and new | Reads old, writes both |
| Backfill | Copy historical data into the new shape in batches | Reads old, writes both |
| Switch reads | App reads from new | Reads new, writes both |
| Contract | Drop old column/table after a soak period | Reads/writes new only |

Each phase is its own deploy with its own rollback point.

### Locking Operations to Watch

These operations take exclusive locks on large tables and block writes. Reach for the engine's non-blocking/online equivalent if one exists, or restructure the change into multiple safe steps.

| Operation | Safer approach |
|-----------|----------------|
| Add an index on a large table | Use the engine's non-blocking/online index build if available. |
| Set a column to `NOT NULL` on a full table | Add nullable → backfill in batches → enforce the constraint with the engine's "validate later" mechanism, then promote to `NOT NULL`. |
| Change a column's type | Expand-contract: add a new column with the target type, dual-write, backfill, switch reads, drop the old column. |
| Add a column with a non-constant default on a large table | Add nullable, backfill in batches, then set the default. |

### Batched Backfills

Long-running `UPDATE` over a large table holds locks and bloats logs. Process in batches with a primary-key range, commit per batch, and throttle.

```sql
-- Loop in application code or stored procedure: bounded by primary key, small batch, commit each iteration
UPDATE users SET status = 'active'
WHERE id BETWEEN :lo AND :hi AND status IS NULL;
```

---

## Primary Keys

### Choosing a Key Type

| Need | Choice | Why |
|------|--------|-----|
| Internal-only PK, single-writer system | Auto-increment integer (`BIGINT`) | Smallest index, sequential inserts, no fragmentation |
| Externally exposed, distributed writers, or merging from multiple sources | UUIDv7 | Time-ordered → sequential B-tree inserts, low fragmentation, globally unique |
| Externally exposed ID where guessability is unacceptable | UUIDv7 (or v4 with separate internal integer PK) | Non-enumerable |
| Legacy / wide adoption | UUIDv4 only when nothing else fits | Random → fragmentation, ~3× slower inserts at scale, ~40% larger index |

UUIDv7 embeds a millisecond timestamp prefix, so new IDs sort to the end of the B-tree and behave like auto-increment for insert performance. UUIDv4 is random and causes page splits, fragmentation, and index bloat at scale.

### Sizing

Choose the smallest type that fits the projected row count over the table's lifetime. PK width multiplies across every index and every foreign key.

| Projected rows | Integer width |
|---------------|---------------|
| < 2 billion | 32-bit (`INT` / `INTEGER` / `SERIAL`) |
| ≥ 2 billion | 64-bit (`BIGINT` / `BIGSERIAL`) |

Use unsigned where the engine supports it (MySQL). Default to 64-bit when migration cost later would be high.

### Hybrid External/Internal IDs

For systems that need a public, non-guessable ID but also want integer PK performance: keep an `id BIGINT` primary key and add a `public_id UUID` column with a unique index. Internal joins use the integer; external APIs use the UUID.

---

## Foreign Keys and Referential Integrity

- Declare foreign keys at the database level. The engine sees concurrent changes the application cannot and enforces integrity under all isolation levels.
- Application-level integrity enforcement does not survive concurrent writers and breaks under any non-serializable isolation.
- `ON DELETE` action: choose explicitly. `CASCADE` for owned child rows, `RESTRICT` (default) for references that must block deletion, `SET NULL` for optional references.
- Index every foreign key column. The engine does not create this index automatically and lookups during cascade/restrict will scan the child table without it.
- For cross-service or sharded boundaries where FKs are not possible, enforce in the application AND run a scheduled reconciliation job that detects orphans.

---

## Indexing

### When to Add an Index

- Column appears in a `WHERE`, `JOIN`, `ORDER BY`, or `GROUP BY` on a query that runs frequently or scans many rows.
- Foreign key columns (always).
- Unique constraints (engine creates the index automatically).

### When Not to Add an Index

- Tables under ~10K rows — sequential scan is faster than index lookup.
- Columns with very low cardinality (boolean, small enum) without a partial-index predicate.
- Write-heavy tables where the cost per insert/update outweighs read benefit. Every index doubles the write cost for the columns it covers.

### Composite Index Column Order

Order columns in a composite index by **how the query filters them**, not by selectivity alone. Rules:

1. Columns used with equality (`=`, `IN`) come first.
2. Columns used with range (`<`, `>`, `BETWEEN`) come last.
3. `ORDER BY` columns follow equality columns and match the query's direction.
4. The leftmost prefix determines reuse — `(a, b, c)` serves queries on `(a)`, `(a, b)`, `(a, b, c)` but not `(b)` or `(c)`.



### Specialized Indexes

| Use | Index type |
|-----|------------|
| Filter on a small subset of rows | Partial index with `WHERE` predicate |
| Sort or filter on expression | Expression / functional index |
| Full-text search | Engine-native full-text index (GIN / FULLTEXT / etc.) |
| Cover a query entirely from index | Include all `SELECT` columns in the index (covering index / `INCLUDE`) |

### Naming

`idx_{table}_{col1}_{col2}[_partial|_gin]` — predictable, greppable, sorts together.

---

## Query Patterns

### Always

- Parameterize every value that comes from outside the query. Concatenation into SQL is the SQL-injection root cause and no input filtering substitutes for it.
- Project only the columns needed. `SELECT *` blocks covering-index optimizations and ships unused bytes.
- Add `LIMIT` to queries expected to return one row.
- Run `EXPLAIN` / `EXPLAIN ANALYZE` on any query that touches a large table. Look for sequential scans on large tables, large gaps between estimated and actual rows, and nested loops over big inputs.

### N+1 Prevention

The N+1 pattern (one parent query + one child query per parent) is the most common ORM performance bug. Detection: count queries per request and watch for any loop that issues a query.

Three fixes, in order of preference:

| Pattern | When | How |
|---------|------|-----|
| Join in a single query | The parent + children fit in one result | `JOIN` and read children from the row |
| Eager / batch loading | Children needed for all parents, ORM-mediated | Collect parent IDs, issue one `WHERE child.parent_id IN (...)` query |
| DataLoader / per-request batching | Children fetched from many code paths in one request | Coalesce all requests in a tick, issue one batched query, distribute results |

Avoid blanket "always eager-load" — it inverts the problem into over-fetching.

### Pagination

| Use | Pattern | Why |
|-----|---------|-----|
| Sequential browsing, feeds, sync, infinite scroll | Keyset (cursor) pagination | O(page size) per page at any depth |
| Jump to arbitrary page number | Offset / limit, only on small datasets | O(offset) — degrades catastrophically deep |

Keyset query shape: `WHERE (sort_col, id) < (:cursor_sort, :cursor_id) ORDER BY sort_col DESC, id DESC LIMIT :n`. The index must match the sort columns and direction. At deep pages, keyset is thousands of times faster than offset.

### Common Rewrites

```sql
-- Existence check: use EXISTS, not COUNT(*) > 0
SELECT 1 FROM orders WHERE user_id = :id LIMIT 1;          -- good
SELECT COUNT(*) FROM orders WHERE user_id = :id;           -- scans all matches

-- Batch insert
INSERT INTO logs (message) VALUES ('a'), ('b'), ('c');     -- good
-- Multiple single INSERTs                                 -- one round-trip per row

-- Aggregation: filter before grouping
SELECT user_id, COUNT(*) FROM events
WHERE created_at >= :since GROUP BY user_id;               -- good — index on created_at applies
```

---

## Transactions and Concurrency

### Transaction Scope

- Keep transactions short. Long transactions hold locks, increase deadlock probability, and bloat MVCC history.
- Never include user input, network calls, or external API calls inside a transaction. Acquire data first, then open the transaction, then commit.
- Touch tables in a consistent order across all transactions to prevent circular-wait deadlocks.

### Isolation Levels

Default to the engine's default (`READ COMMITTED` for Postgres, `REPEATABLE READ` for MySQL/InnoDB) unless the workload requires otherwise.

| Level | Use when |
|-------|----------|
| `READ COMMITTED` | General OLTP; reads see only committed data |
| `REPEATABLE READ` | Multi-statement transaction must see a stable snapshot |
| `SERIALIZABLE` | Correctness requires no anomalies; accept retries on conflict |

Snapshot isolation (`SERIALIZABLE` in Postgres, RCSI in SQL Server) reduces blocking without giving up consistency. Application code must handle serialization-failure retries.

### Deadlocks

- Application code must catch deadlock errors and retry the transaction with backoff.
- Missing indexes turn row-level locks into range/table scans that hold locks longer than necessary — index foreign keys and `WHERE` columns.

---

## Connection Pooling

### Sizing

Pool size is **not** "more is better". Past a point, more connections degrade throughput due to context-switching, lock contention, and shared-buffer pressure on the engine.

Starting formula (from PostgreSQL community, applies broadly): `pool_size = (cores × 2) + effective_spindle_count`. SSDs: `effective_spindle_count = 1`. Adjust from there based on observed wait times.

| Environment | Per-process max | Total across processes |
|-------------|-----------------|------------------------|
| Single-process app | ≈ `(cores × 2) + 1` | Same |
| Multi-process / multi-instance app | 5–10 per instance | Sum ≤ engine `max_connections` minus headroom for ops |
| Serverless (function-per-request) | 1 | Front with external pooler (PgBouncer, RDS Proxy, Supavisor) |

### External Poolers

Serverless and high-instance-count deployments must front the engine with a connection pooler. Each new database connection costs 50–100ms (TLS + auth + backend fork) and the engine cannot serve thousands of concurrent backends efficiently. Transaction-mode pooling (e.g. PgBouncer) gives the highest reuse but disallows session-scoped features (prepared statements caching across transactions, `LISTEN/NOTIFY`, session temp tables, `SET LOCAL`).

### Configuration

- Set acquisition timeout, idle timeout, and max lifetime explicitly. Defaults vary by driver and are rarely right.
- Return connections to the pool promptly — release in a `finally` equivalent, never hold across awaits that touch unrelated work.

---

## Timestamps

- Store all timestamps as UTC, in a timezone-aware type when the engine offers one (`TIMESTAMP WITH TIME ZONE` / `TIMESTAMPTZ`).
- Convert to a local zone only at the display boundary, using a zone-aware library and the IANA zone name (`Europe/Tallinn`), never a fixed offset.
- Every mutable row carries `created_at` and `updated_at` with engine-set defaults / triggers, not application clocks. Application clocks drift and skew across instances.
- Future timestamps (scheduled events) — store the user's IANA zone alongside the wall-clock time. UTC alone is wrong because zone rules change.

---

## Soft Delete and Data Retention

Soft delete (a `deleted_at` column) is **not** GDPR-compliant erasure. A "right to be forgotten" request requires actual destruction such that recovery is impossible without disproportionate effort. A `deleted_at` flag fails that test by design.

### Decision Matrix

| Need | Approach |
|------|----------|
| Recoverable mistakes ("undelete" within N days) | Soft delete with scheduled hard-purge job |
| Legal/compliance audit history of changes | Append-only audit table, separate from live row |
| GDPR / "right to be forgotten" | Hard delete of personal data; retain non-personal audit metadata (hashed subject ID, action, timestamp) only |
| High-volume ephemeral data (sessions, logs) | Hard delete with TTL |

### If Soft Delete Is Used

- Add `deleted_at TIMESTAMPTZ NULL`; never use a boolean.
- Every query against the table must filter `deleted_at IS NULL` — enforce with a view or a query helper, not by remembering.
- Partial unique indexes: `CREATE UNIQUE INDEX ... ON table (email) WHERE deleted_at IS NULL;` so a deleted row does not block re-registration.
- Schedule a hard-purge job that removes rows older than the retention window.

---

## Audit Logging

### Goals to Separate

| Goal | Mechanism |
|------|-----------|
| "Who changed this row, when, from what to what" | Append-only audit table, written by trigger or CDC |
| "Replay the system from any point in time" | Event sourcing or transaction-log capture |
| "Detect tampering" | Hash-chained audit rows or write to an isolated, append-only store |
| "Security forensics" | Database audit feature (engine-native) + isolated log sink |

### Append-Only Audit Table

A generic audit table separates audit data from the live row and survives schema changes:

```sql
CREATE TABLE audit_log (
  id            BIGSERIAL PRIMARY KEY,
  table_name    TEXT      NOT NULL,
  record_id     TEXT      NOT NULL,
  action        TEXT      NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  old_row       JSONB,
  new_row       JSONB,
  actor_id      TEXT,
  ip_address    INET,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_table_record ON audit_log (table_name, record_id);
CREATE INDEX idx_audit_created_at   ON audit_log (created_at);
```

Triggers write rows automatically on every `INSERT/UPDATE/DELETE` to audited tables.

### Change Data Capture (CDC)

For audit at scale, large numbers of tables, or downstream consumers (search indexes, analytics): use log-based CDC reading the engine's write-ahead/transaction log. CDC is asynchronous, lightweight on the source, and preserves commit order. It does **not** capture the application user — pair CDC with an application-set context variable (`SET LOCAL app.actor_id = ...`) or with engine-native audit.

### What Audit Must Never Contain

Passwords, password hashes, full payment card numbers, raw tokens, plaintext personal data subject to erasure requests. Treat audit rows as sensitive and apply the same access controls as the source data.

---

## Seeding

Seeds populate reference data (countries, roles, currencies) and small fixture sets. They are **not** a substitute for migrations.

- Reference seeds use fixed primary keys so tests and foreign-key references are stable across environments.
- Seeds are idempotent: re-running them does not duplicate or destroy rows. `INSERT ... ON CONFLICT DO NOTHING` / `MERGE` / equivalent upsert.
- Destructive seed steps (`TRUNCATE`) only run when an explicit environment guard is set (`SEED_DESTRUCTIVE=1`) and never on production.
- Large synthetic datasets belong to a factory/generator, not to checked-in seed files.

---

## Testing

### Test Database Is a Real Database

Integration tests run against a real instance of the same engine and version as production. SQLite-as-stand-in for Postgres/MySQL produces false greens — different SQL dialects, different transaction semantics, different type coercion.

### Isolation Between Tests

Two viable strategies; pick one per project.

| Strategy | Cost per test | Parallel-safe | Notes |
|----------|---------------|---------------|-------|
| Transaction wrap + rollback | ~1–4 ms | Yes, with per-test connection | Cannot test code that itself starts/commits transactions |
| Truncate-all between tests | ~20–500 ms | Difficult — needs per-test schema or DB | Tests can use real transactions |



### Setup Order

1. Apply all migrations to the test database before any tests run.
2. Seed reference data once per suite.
3. Per-test: either open transaction → run test → rollback, or run test → truncate affected tables.
4. Tear down connections in suite teardown, not per test.

### What to Test at the Database Layer

- Migrations apply cleanly and roll back cleanly on a clone of production schema.
- Constraints (unique, foreign key, check) actually reject the bad input — not just the application layer.
- Critical query plans do not regress (`EXPLAIN` assertion or query-plan snapshot) on representative data volumes.

---

## Normalization

- Default to 3NF / BCNF for transactional (OLTP) schemas. Inserts and updates touch one place, integrity is structural.
- Denormalize deliberately, with a documented reason and a maintenance plan (trigger, materialized view, or scheduled refresh). Never denormalize by accident through cut-and-paste schemas.
- Analytical (OLAP) workloads use star/snowflake or wide denormalized tables in a separate store, not the OLTP database.
