# PostgreSQL for Data Scientists

This repo is a complete PostgreSQL interview-training system for a future senior data scientist.

The goal is not just to memorize syntax. It is to build the mental models that let you look at a new SQL question, recognize the pattern fast, and write the right query under time pressure.

## How To Use This Repo

Use each week in the same rhythm:

1. Read the weekly `README.md` for intuition, mental models, and interview framing.
2. Run `01_examples.sql` line by line in PostgreSQL.
3. Solve `02_practice.sql` without looking at answers.
4. Compare with `03_solutions.sql`.
5. Run `EXPLAIN ANALYZE` on your version and the reference version.
6. Revisit the linked pattern docs and cheatsheets when you get stuck.

## Learning Principles

- Intuition before syntax.
- Patterns before random questions.
- Multiple correct solutions matter.
- Performance discussion matters.
- Interview communication matters as much as correctness.

## Repo Map

- `setup/`: local PostgreSQL workflow, seeding, and schema docs
- `week_01_foundations/` ... `week_12_interview_mastery/`: the main course
- `patterns/`: canonical hard-problem patterns
- `cheatsheets/`: compressed reference notes
- `problems/`: hard-problem index and worked solutions by pattern
- `mocks/`: timed interview drills
- `progress.md`: study tracker and spaced-repetition prompts

## Suggested 12-Week Path

### Weeks 1-3

Build the base:

- data types
- `SELECT` mechanics
- `NULL`
- joins
- subquery intuition

### Weeks 4-6

Build the core interview engine:

- aggregation
- CTEs
- recursive CTEs
- window functions

### Weeks 7-9

Build PostgreSQL power and hard-pattern fluency:

- dates and time
- strings and regex
- arrays and `jsonb`
- top-N per group
- gaps and islands
- sessionization
- cohort retention
- funnel analysis

### Weeks 10-12

Build senior-level judgment:

- indexing
- `EXPLAIN ANALYZE`
- MVCC
- locking
- partitioning
- timed interview drills

## Interview Mindset

For most SQL interviews, train yourself to do this in order:

1. Restate the task in plain English.
2. Identify grain: "What does one output row represent?"
3. Identify pattern: ranking, dedup, gaps and islands, retention, funnel, running total, etc.
4. Sketch the query in layers.
5. Validate with a tiny sample in your head.
6. Discuss performance and edge cases.

## Fast Setup

If PostgreSQL is installed already:

```sql
\i setup/seed/00_create_databases.sql
```

Then connect to each database and run the seed file:

```sql
\c sql_hr
\i setup/seed/01_hr.sql
```

Repeat for `sql_ecommerce`, `sql_social`, and `sql_rideshare`.

## What "Mastery" Means Here

By the end of this repo, you should be able to:

- solve medium SQL questions routinely in under 5 minutes
- solve hard SQL questions in 5-10 minutes with clean structure
- explain why one approach is better than another
- spot common traps with `NULL`, duplicates, ties, and time handling
- talk about indexes and execution plans like a senior practitioner

## Practical Advice

- Write queries in layers, not all at once.
- Always name the grain of each CTE.
- Prefer correctness first, then simplify.
- In interview settings, say your assumptions out loud.
- In PostgreSQL, learn and use `DISTINCT ON`, `FILTER`, `LATERAL`, and `generate_series` well. They are high-leverage tools.
