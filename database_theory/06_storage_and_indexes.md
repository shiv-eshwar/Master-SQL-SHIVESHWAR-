# Chapter 6: Storage Engines and Indexes

## How Data Lives on Disk

Understanding physical storage turns "why is this query slow?" from a mystery into a diagnosis.

### Pages and Heap Files

PostgreSQL stores table data in **heap files** — files organized as a collection of fixed-size **pages** (8KB by default).

Each page contains:
- a page header with metadata
- an array of item pointers (offsets to row locations within the page)
- row data (tuples) growing from the bottom
- free space in the middle

When you `SELECT * FROM employees`, PostgreSQL reads pages from disk (or the buffer pool if cached). Reading one page means reading all tuples on that page.

This has a critical implication: if you frequently read all columns of all rows, a sequential scan of the heap file is often the fastest option. Indexes only help when you are reading a small fraction of rows.

### The Buffer Pool

PostgreSQL maintains a shared memory area called the **buffer pool** (controlled by `shared_buffers`). Pages are cached here in memory. A page already in the buffer pool costs nothing extra to read. A page not in the buffer pool requires an I/O, which is 100-1000x slower than memory access.

This is why EXPLAIN ANALYZE shows `(Buffers: hit=X miss=Y)`: hits are free, misses are expensive.

### Write-Ahead Log (WAL)

Before any change is written to a data page, it is first recorded in the WAL. This ensures durability: if the system crashes after a commit, the WAL can be replayed to reconstruct the committed change.

WAL is also used for:
- streaming replication (WAL is shipped to replicas)
- logical replication (WAL is decoded into row-level changes)
- point-in-time recovery

## What an Index Is

An index is a separate data structure maintained alongside the heap file. It trades write overhead and storage for faster lookups.

The key insight: without an index, finding rows that match `WHERE employee_id = 7` requires scanning every page of the heap file. With a B-tree index on `employee_id`, it requires reading O(log n) pages.

Every index has a cost:
- writes are slower (index must be updated on INSERT, UPDATE, DELETE)
- storage is used
- the query planner must evaluate whether the index is worth using

## B-Tree Indexes: The Most Important Index Type

A **B-tree** (Balanced Tree) is a self-balancing tree where all leaf nodes are at the same depth and each node contains multiple keys.

Structure:
```
               [300, 700]
              /    |    \
          [100,200] [400,500,600] [800,900]
         / | \       ...              ...
       leaf pages (point to heap tuples)
```

Every leaf page stores:
- index key values in sorted order
- pointers (item IDs) to the corresponding heap page and row offset

### Why B-Trees Are Good at What They Do

- **Equality lookups**: `WHERE employee_id = 7` — traverse from root to leaf in O(log n)
- **Range scans**: `WHERE salary BETWEEN 100000 AND 200000` — find start leaf, walk forward
- **Sort avoidance**: if `ORDER BY salary` and there is a B-tree index on `salary`, the planner can read the index in order and skip the sort step
- **Prefix matching**: `WHERE email LIKE 'asha%'` — works because B-tree is sorted by value prefix

### What B-Trees Cannot Do Efficiently

- `WHERE email LIKE '%menon'` — suffix search requires a full scan because values are sorted by prefix, not suffix
- `WHERE lower(email) = 'asha.menon@company.com'` — function on the indexed column breaks the index scan (unless an expression index is defined)
- Full-text search

## Composite Indexes

A composite index covers multiple columns: `CREATE INDEX idx ON employees (department_id, salary DESC)`.

**Left-prefix rule**: a composite index on `(A, B, C)` can be used for:
- queries filtering on `A` alone
- queries filtering on `A` and `B`
- queries filtering on `A`, `B`, and `C`

It **cannot** efficiently serve:
- queries filtering only on `B` (no leading column)
- queries filtering only on `C`

Column order in a composite index matters enormously. Put the most selective equality predicate first, then range predicates, then sort columns.

## Partial Indexes

An index only on a subset of rows:

```sql
CREATE INDEX idx_completed_rides ON rides (requested_ts)
WHERE status = 'completed';
```

Benefits:
- smaller index (fewer rows)
- faster index scans (fewer pages to read)
- the planner will use it when the query includes `WHERE status = 'completed'`

Ideal when a large fraction of rows are "cold" (historical, inactive, cancelled) and you mostly query "hot" rows.

## Expression Indexes

Index a computed expression rather than a raw column value:

```sql
CREATE INDEX idx_lower_email ON employees (lower(email));
```

Now `WHERE lower(email) = 'asha.menon@company.com'` can use the index. Without this, the index on `email` would not help because the function wraps the column.

## Covering Indexes (INCLUDE)

A covering index stores additional columns that are not part of the key but are needed by queries:

```sql
CREATE INDEX idx_customer_order_ts ON orders (customer_id, order_ts DESC)
INCLUDE (status, total_amount);
```

A query that needs `customer_id`, `order_ts`, `status`, and `total_amount` can be answered entirely from the index without touching the heap — an **index-only scan**. This eliminates expensive heap fetches.

## GIN Indexes: For Full-Text and Arrays

A **Generalized Inverted Index (GIN)** maps each element of a multi-valued column to the set of rows containing it.

Use cases:
- Full-text search (`tsvector`)
- `jsonb` containment queries (`@>`)
- Array containment (`ANY`, `@>`)

```sql
CREATE INDEX idx_metadata_gin ON customers USING GIN (metadata);
-- Now: WHERE metadata @> '{"plan": "pro"}' can use the GIN index
```

## GiST Indexes: For Geometric and Range Data

A **Generalized Search Tree (GiST)** is a framework for implementing arbitrary tree-based indexes. Used for:
- geometric types (points, polygons — for location-based queries)
- range types (`daterange`, `tstzrange`)
- full-text search (as an alternative to GIN)

## BRIN Indexes: For Naturally Ordered Large Tables

A **Block Range INdex (BRIN)** stores the min and max values of a column for each range of physical pages.

Very small. Very fast to build. Only useful when data is physically ordered by the indexed column on disk.

Classic use case: event tables where rows are written in timestamp order. A BRIN on `event_ts` lets the planner skip large swaths of pages for time-range queries.

## How the Planner Chooses Whether to Use an Index

The planner estimates cost in units of "random page reads" and "sequential page reads." It chooses the cheapest plan.

An index scan is NOT always cheaper than a sequential scan. Key factors:

- **Selectivity**: what fraction of rows does the predicate match? If 80% of rows match, a sequential scan is often faster because an index would still read most of the heap.
- **Clustering**: are matching rows on the same physical pages (good for index use) or scattered across many pages (bad)?
- **Buffer pool**: if the whole table fits in memory, a seq scan is very fast and index overhead may not pay off.

Rule of thumb: indexes help when a query selects less than ~5-15% of rows. Beyond that, a sequential scan often wins.

## SARGability: Writing Index-Friendly Predicates

A predicate is **SARGable** (Search ARGument able) if the query engine can use an index to satisfy it.

Non-SARGable patterns (break index usage):

```sql
-- function on indexed column
WHERE date_trunc('month', hire_date) = '2023-01-01'

-- arithmetic on indexed column
WHERE salary * 1.1 > 200000

-- leading wildcard
WHERE email LIKE '%menon.com'
```

SARGable rewrites:

```sql
-- range predicate instead of function
WHERE hire_date >= '2023-01-01' AND hire_date < '2023-02-01'

-- move math to the literal side
WHERE salary > 200000 / 1.1

-- trailing wildcard is SARGable
WHERE email LIKE 'asha%'
```

## Interview Lens

Storage and index questions that appear in senior interviews:

- "Why isn't this query using the index I created?"
- "What is the difference between an index scan and a sequential scan?"
- "When would you choose a partial index?"
- "What is SARGability and why does it matter?"
- "What is an index-only scan and how do you enable it?"
- "If I add an index, what write overhead does that create?"
- "What is the left-prefix rule?"
