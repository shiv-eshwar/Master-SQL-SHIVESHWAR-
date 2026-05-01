# Week 4: Aggregation and GROUP BY

## The Big Distinction

`GROUP BY` collapses rows.

That is the key difference between aggregation and window functions. If your output should have one row per department, user, or month, `GROUP BY` is likely involved.

## Mental Models

1. First define the group key.
2. Then ask what statistic you want per group.
3. Then check whether duplicate rows from earlier joins polluted the result.

## Aggregates To Know

- `COUNT(*)`
- `COUNT(column)`
- `SUM`
- `AVG`
- `MIN` / `MAX`
- `STRING_AGG`
- `ARRAY_AGG`
- `BOOL_AND` / `BOOL_OR`

## PostgreSQL Feature To Love

`FILTER` is often clearer than wrapping every aggregate in `CASE WHEN`.

Example idea:

```sql
COUNT(*) FILTER (WHERE status = 'delivered')
```

## Rollups

You should know the vocabulary even if it is less common in interviews:

- `ROLLUP`
- `CUBE`
- `GROUPING SETS`

## Interview Lens

A surprising number of hard problems are "just" aggregation after the right preprocessing step. The art is getting to the right grouped table first.
