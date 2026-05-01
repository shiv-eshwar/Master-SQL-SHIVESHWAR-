# Week 3: Joins Mastery

## The Mental Model

A join is a filtered Cartesian product.

That sentence sounds scary, but it removes mystery. The database conceptually starts with combinations of rows, then keeps the combinations allowed by the join condition.

## Join Types You Must Feel, Not Just Know

- `INNER JOIN`: keep matching pairs
- `LEFT JOIN`: keep all left rows, fill missing right side with `NULL`
- `FULL OUTER JOIN`: keep everything from both sides
- `CROSS JOIN`: explicit Cartesian product
- self-join: a table joined to itself for relationships such as employee-manager

## Senior-Level Details

- Put right-table filters in the `ON` clause when preserving left rows matters.
- Use `EXISTS` for semi-joins.
- Use `NOT EXISTS` for anti-joins.
- Be careful with fanout. One bad join can duplicate downstream aggregates.

## PostgreSQL Feature To Learn Well

`LATERAL` says:

"For each row from the left table, run this subquery using values from that row."

That is excellent for:

- top-N per group
- nearest event lookups
- "latest related record" patterns

## Interview Lens

Hard SQL questions often hide their real difficulty in join shape. If you cannot describe the row grain before and after each join, stop and do that first.
