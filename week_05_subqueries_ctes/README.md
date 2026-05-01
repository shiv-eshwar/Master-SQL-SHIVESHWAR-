# Week 5: Subqueries and CTEs

## What This Week Teaches

Subqueries and CTEs are about decomposition.

Strong SQL writers break large problems into logical layers, each with a clear grain. Weak SQL writers try to write the whole answer in one huge statement and then get lost.

## Mental Models

- Scalar subquery: returns one value
- Table subquery: returns a relation
- Correlated subquery: depends on the outer row
- CTE: a named intermediate result

## Important Judgment

CTEs are not automatically faster. They are primarily a readability tool. In modern PostgreSQL, the planner can inline many CTEs, but you should still understand that query shape matters.

## Recursive CTEs

Recursive CTEs are the SQL answer to:

- org charts
- category trees
- path expansion
- repeated parent-child traversal

## Interview Lens

When you say, "I’ll solve this in three layers," interviewers relax. It signals control. Good CTE design is communication, not just syntax.
