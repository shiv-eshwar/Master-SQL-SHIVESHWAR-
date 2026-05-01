# Window Functions Cheatsheet

- ranking: `ROW_NUMBER`, `RANK`, `DENSE_RANK`
- comparisons: `LAG`, `LEAD`
- aggregates per row: `SUM() OVER`, `AVG() OVER`
- partition = group context
- order = sequence inside group
- frame = which rows are visible to the current row

Typical template:

```sql
function_name(...) OVER (
    PARTITION BY key_cols
    ORDER BY sort_cols
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```
