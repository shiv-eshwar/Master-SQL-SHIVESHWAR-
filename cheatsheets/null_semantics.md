# NULL Semantics Cheatsheet

- `NULL` means unknown
- `WHERE` keeps only `TRUE`
- `NULL = x` -> unknown
- `NULL <> x` -> unknown
- use `IS NULL` and `IS NOT NULL`
- use `IS DISTINCT FROM` for null-safe comparison
- use `COALESCE` to fill fallback values
- use `NULLIF(a, b)` to turn equality into `NULL`

Classic trap:

`NOT IN` behaves badly if the subquery can return `NULL`.
