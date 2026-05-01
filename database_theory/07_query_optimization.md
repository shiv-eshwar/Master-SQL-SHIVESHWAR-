# Chapter 7: Query Optimization

## The Query Lifecycle

When you submit a SQL query, it travels through four stages before results appear:

```
SQL text
  → Parser       (syntax tree)
  → Rewriter     (view expansion, rule application)
  → Planner/Optimizer  (physical execution plan)
  → Executor     (results)
```

Understanding each stage tells you what can go wrong and where to look.

## Stage 1: Parser

The parser checks syntax and converts the SQL text into a parse tree (an AST — Abstract Syntax Tree). This is purely syntactic: it knows nothing about whether the table exists or the column names are valid.

Syntax errors are caught here.

## Stage 2: Query Rewriter

The rewriter applies transformations before optimization:
- Expands view references to their underlying definitions
- Applies row security policies
- Applies rewrite rules defined with `CREATE RULE`

After the rewriter, the query is expressed entirely in terms of base tables.

## Stage 3: The Planner (Optimizer)

This is the most important and most complex stage. The planner must find the lowest-cost way to execute the query.

It has to answer questions like:
- Which indexes should I use?
- In what order should I join the tables?
- Should I use a hash join, a merge join, or a nested loop?
- Should I compute a subquery once or re-execute it per row?

### The Cost Model

The planner assigns costs in abstract units. Each operation type has an associated cost:
- `seq_page_cost`: cost of reading one page sequentially (default 1.0)
- `random_page_cost`: cost of a random page read (default 4.0 — random I/O is ~4x more expensive)
- `cpu_tuple_cost`: CPU cost per row evaluated
- `cpu_operator_cost`: CPU cost per operator evaluated

The planner computes the total estimated cost of each candidate plan and chooses the cheapest.

### Statistics: The Planner's Oracle

The planner does not know the actual data. It estimates row counts using **statistics** stored in `pg_statistic` (readable via `pg_stats`).

Statistics include:
- **most common values** and their frequencies
- **histogram buckets** (distribution of values across the range)
- **null fraction**
- **ndistinct**: estimated number of distinct values

When statistics are stale (after large inserts/updates without `ANALYZE`), the planner makes poor row count estimates, leading to bad plan choices.

**Rule**: always run `ANALYZE` after loading large amounts of new data. `autovacuum` does this automatically for routine workloads.

### Estimated vs Actual Rows: The Key Debug Signal

```sql
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department_id = 20;
```

Output includes:
```
Seq Scan on employees  (cost=0.00..1.10 rows=7 width=95) (actual time=0.012..0.025 rows=7 loops=1)
```

- `rows=7` (estimate) matches `rows=7` (actual): statistics are good.

When estimates are wildly off (e.g., estimated 10, actual 100,000), the planner was working with bad statistics and likely chose a bad plan.

## Join Order and the N! Problem

For a query joining N tables, there are N! possible join orderings. For 10 tables, that is 3.6 million possibilities.

The planner cannot evaluate all of them for large N. PostgreSQL uses:
- **Dynamic programming** for N ≤ `join_collapse_limit` (default 8): exact optimal for small joins
- **Genetic algorithm (GEQO)** for N > `geqo_threshold` (default 12): approximate but fast

For most queries, the default limits are fine. If you have a query joining 15+ tables, the planner may need hints or query restructuring.

## Join Algorithms

For any two relations being joined, the planner chooses one of three algorithms:

### Nested Loop Join

```
for each row in outer relation:
    for each matching row in inner relation:
        emit (outer_row, inner_row)
```

Cost: O(outer_rows × inner_rows) in the worst case, but O(outer_rows × log(inner_rows)) if the inner relation has an index.

**Best when**:
- The outer side is small
- The inner side has a usable index on the join key
- The join is selective (very few matching rows)

### Hash Join

```
Phase 1 (Build): scan inner relation, build an in-memory hash table keyed on join column
Phase 2 (Probe): scan outer relation, probe hash table for matches
```

Cost: O(outer_rows + inner_rows)

**Best when**:
- No index exists on join columns
- Both sides are large
- The smaller side fits in working memory (work_mem)

If the hash table does not fit in memory, it spills to disk — a **hash batch** — which is much slower. You will see this in EXPLAIN as `Batches: 8` instead of `Batches: 1`.

### Merge Join

```
Sort both relations on the join key
Walk both sorted sequences simultaneously, emitting matching pairs
```

Cost: O(n log n) for sorts + O(n) for merge

**Best when**:
- Both sides are already sorted (e.g., from an index scan)
- The join is on an equality condition
- Both sides are large

Merge join avoids the random access cost of nested loop and the memory cost of hash join when sort can be avoided.

## Execution Plan Nodes You Must Recognize

### Scan Nodes

- **Seq Scan**: reads all pages of the table sequentially. Fine for large fractions of the table.
- **Index Scan**: traverses index, then fetches matching heap pages. Random access. Good for small result sets.
- **Index Only Scan**: traverses index, does NOT touch heap (all needed columns are in the index). Requires the index to include all needed columns.
- **Bitmap Index Scan + Bitmap Heap Scan**: two-phase approach. First pass builds a bitmap of matching pages. Second pass reads those pages in physical order (reducing random I/O). Used when index scan would have too many random reads.
- **CTE Scan**: scans the result of a materialized CTE.

### Join Nodes

- **Nested Loop**: described above
- **Hash Join**: described above
- **Merge Join**: described above

### Aggregation Nodes

- **Aggregate**: non-parallel aggregation over one group
- **HashAggregate**: builds a hash table of group keys and computes aggregates per bucket
- **GroupAggregate**: merges pre-sorted input to compute group aggregates

### Other Nodes

- **Sort**: explicit sort (expensive if large, potentially spills to disk)
- **Limit**: stops after N rows
- **Append**: union of multiple relations (used in partition pruning)
- **Gather** / **Gather Merge**: collects results from parallel workers

## How to Read EXPLAIN ANALYZE Output

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT e.full_name, d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.base_salary > 150000;
```

Key fields to look at:

| Field | Meaning |
|-------|---------|
| `cost=X..Y` | Estimated startup cost (X) and total cost (Y) |
| `rows=N` | Estimated output rows |
| `width=N` | Estimated average row width in bytes |
| `actual time=X..Y` | Actual wall-clock time (ms) for startup..total |
| `actual rows=N` | Actual rows returned |
| `loops=N` | How many times this node was executed |
| `Buffers: hit=X miss=Y` | Buffer pool hits and misses |
| `Planning time` | How long the optimizer took |
| `Execution time` | Total wall-clock time for the query |

**The key diagnostic pattern**:

If `rows` (estimated) << `actual rows`, the planner underestimated. It may have chosen a Nested Loop join when a Hash Join would have been faster.

If `rows` >> `actual rows`, the planner overestimated. It may have chosen a Hash Join when a Nested Loop with an index would have been cheaper.

Run `ANALYZE tablename` to refresh statistics and re-run.

## Common Performance Anti-Patterns

**SELECT * in production**: reads and transfers all columns even if you need two. Wastes I/O and memory.

**Non-SARGable predicates**: as covered in Chapter 6, functions on indexed columns prevent index usage.

**Implicit type cast in join condition**: `WHERE orders.customer_id = customers.id` where one is `integer` and the other is `bigint` may force a cast, breaking the index.

**Correlated subquery re-executed per row**: replace with a JOIN or a lateral join where possible.

**Unnecessary DISTINCT**: if the query produces distinct results naturally, adding DISTINCT adds a sort/hash step for nothing.

**ORDER BY in a CTE**: a CTE result that will be filtered further does not need to be sorted. The sort is wasted work.

## Interview Lens

Optimization questions in MAANG interviews:

- "How would you debug a slow query?" → EXPLAIN ANALYZE, check estimated vs actual rows, identify the worst node, check statistics.
- "What is the difference between a hash join and a nested loop join?" → describe algorithms and when each wins.
- "Your query is slow after deploying a new feature. What do you check?" → new data distribution changed estimates, new join added, missing index, statistics not updated.
- "What does 'cost' mean in EXPLAIN?" → estimated abstract units, not milliseconds.
- "Why does my query get slower at month-end when there is more data?" → statistics may not reflect recent growth, planner underestimates, plan degrades.
