# Week 6: Window Functions

## Why This Week Matters So Much

Window functions are the center of modern SQL interviews.

They let you compute per-row analytics without collapsing the table. That makes them perfect for:

- ranking
- running totals
- lag/lead comparisons
- dedup
- streak detection
- retention and cohort work

## The Mental Model

`OVER (PARTITION BY ... ORDER BY ...)` means:

"For this row, look at other rows in the same partition, ordered in a meaningful way, and compute something over that ordered neighborhood."

## Functions To Internalize

- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `LAG`
- `LEAD`
- `SUM() OVER`
- `AVG() OVER`
- `FIRST_VALUE`
- `LAST_VALUE`

## Frame Awareness

Do not stop at function names. You need frame intuition too:

- `ROWS` is physical row-based
- `RANGE` is value-based
- default frames can surprise you

## Interview Lens

If you can translate a business question into partition, order, and frame, you are already halfway to the answer.
