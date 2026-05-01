# Week 2: SELECT Mechanics and NULL Semantics

## The Core Insight

Most SQL confusion comes from forgetting that the database does not read your query top to bottom in the same order it conceptually executes it.

Logical order:

1. `FROM`
2. `WHERE`
3. `GROUP BY`
4. `HAVING`
5. `SELECT`
6. `ORDER BY`
7. `LIMIT`

That single idea explains why aliases sometimes work and sometimes do not.

## NULL Is Not "Empty"

`NULL` means unknown. Once you internalize that, weird behavior stops feeling weird:

- `NULL = 5` is unknown
- `NULL <> 5` is also unknown
- `WHERE` keeps only `TRUE`, not `FALSE` and not `UNKNOWN`

## Key Tools

- `COALESCE`
- `NULLIF`
- `CASE`
- `IS NULL`
- `IS DISTINCT FROM`
- `DISTINCT`
- `DISTINCT ON`

## PostgreSQL Power Move

`DISTINCT ON` is one of the fastest ways to say:

"After sorting rows the way I want, keep the first row in each group."

That is incredibly useful for:

- latest row per user
- top record per category
- dedup with tie-breaking

## Common Interview Traps

- `NOT IN` with `NULL`
- filtering after a `LEFT JOIN` and accidentally turning it into an inner join
- using `=` instead of `IS NULL`
- assuming `ORDER BY` happens before `SELECT`

## Interview Lens

When a hard problem fails, it often fails because of hidden `NULL`, duplicate, or filtering-order issues rather than because of the main pattern. Week 2 makes your queries robust.
