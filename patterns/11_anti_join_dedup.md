# Anti-Join and Dedup

## Use When

You need missing rows, only unmatched rows, or one winner row among duplicates.

## Core Tools

- `NOT EXISTS`
- `LEFT JOIN ... IS NULL`
- `ROW_NUMBER()`
- `DISTINCT ON`

## Worked Ideas

- customers with no orders
- products never purchased
- keep latest record per key

## Interview Note

Know why `NOT IN` can break in the presence of `NULL`.
