# Week 1: Foundations and Data Types

## What You Are Really Learning

SQL feels easy when the data behaves and hard when types, constraints, and row meaning are fuzzy. This week fixes that. A table is not just "rows and columns." It is a typed contract.

If you get types wrong:

- math becomes lossy
- timestamps shift silently
- joins break
- constraints fail late instead of early

## Mental Models

1. A table is a typed multiset of rows.
2. A primary key says what one row means.
3. Data types are business rules encoded in the database.
4. Constraints are interview-friendly proof that you think about data quality.

## PostgreSQL Types You Must Know

- Integers: `smallint`, `integer`, `bigint`
- Exact decimal: `numeric(p, s)`
- Floating point: `real`, `double precision`
- Text: `text`, `varchar(n)`, `char(n)`
- Time: `date`, `timestamp`, `timestamptz`, `interval`
- Boolean: `boolean`
- Structure: arrays, `jsonb`
- Identifiers: `uuid`

## Interview Notes

- Use `numeric` for money when correctness matters.
- Use `timestamptz` for event data unless you have a strong reason not to.
- Prefer `text` over arbitrary `varchar(n)` unless there is a true business limit.
- Know how to cast and why implicit casts can surprise you.

## PostgreSQL-Specific Goodies

- `INSERT ... RETURNING`
- `UPDATE ... FROM`
- `DELETE ... USING`
- `GENERATED ALWAYS AS IDENTITY`
- `ON CONFLICT`

## Common Traps

- storing timestamps as text
- using `double precision` for currency
- confusing `timestamp` with `timestamptz`
- missing `NOT NULL` on required business columns
- not defining the row grain with a key

## Interview Lens

Even on hard SQL questions, senior candidates implicitly use week-1 skills. They decide the correct grain, notice if a date is local or zoned, and avoid accidental precision loss. That is why "basic" topics are not basic.
