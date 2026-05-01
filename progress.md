# Progress Tracker

Use this file once per week. Keep it honest and brief.

## Weekly Checklist

- [ ] Week 1: foundations and data types
- [ ] Week 2: `SELECT` mechanics and `NULL`
- [ ] Week 3: joins
- [ ] Week 4: aggregation and `GROUP BY`
- [ ] Week 5: subqueries and CTEs
- [ ] Week 6: window functions
- [ ] Week 7: dates, strings, arrays, `jsonb`
- [ ] Week 8: hard patterns part 1
- [ ] Week 9: hard patterns part 2
- [ ] Week 10: performance and indexes
- [ ] Week 11: internals and transactions
- [ ] Week 12: interview mastery and mocks

## Spaced Repetition Prompts

Answer these from memory after each week:

1. What does one row represent before and after each `GROUP BY`?
2. When would I use a join instead of a window function?
3. What is the difference between `WHERE`, `HAVING`, and `QUALIFY`-like filtering done manually in PostgreSQL?
4. What does `NULL` mean in this problem?
5. Which alternative solutions can solve the same problem?
6. What follow-up question would an interviewer ask next?

## Timing Log

Track how fast you solve representative questions:

| Date | Problem | Pattern | Time | Correct? | Notes |
|------|---------|---------|------|----------|-------|
|      |         |         |      |          |       |

## Weakness Log

Write recurring issues here:

- I confuse `RANK()` vs `DENSE_RANK()`.
- I forget that `NOT IN` breaks with `NULL`.
- I overuse CTEs when a window function is cleaner.

Delete those examples and replace them with your real weak spots.

## Interview Checklist

Before saying a query is done, ask yourself:

- [ ] Did I define the output grain?
- [ ] Did I handle ties explicitly?
- [ ] Did I think about duplicates?
- [ ] Did I think about `NULL` behavior?
- [ ] Did I choose the right time grain?
- [ ] Can I explain performance trade-offs?
