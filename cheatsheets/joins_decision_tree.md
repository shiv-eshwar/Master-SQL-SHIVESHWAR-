# Joins Decision Tree

- need only matching rows -> `INNER JOIN`
- keep all left rows -> `LEFT JOIN`
- need existence only -> `EXISTS`
- need missing rows -> `NOT EXISTS`
- need latest related row -> consider `LATERAL` or `DISTINCT ON`
- joining table to itself -> self-join or recursive CTE

Always ask:

1. what is the left table grain?
2. what is the right table grain?
3. can this join create duplicates?
