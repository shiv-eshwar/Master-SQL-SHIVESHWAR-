# Week 10: Performance, Indexes, and EXPLAIN

## The Shift In Thinking

Until now, the main question was "Can I get the right answer?"

Now the question becomes:

"Can I get the right answer with a plan that scales?"

## What To Learn

- B-tree index intuition
- composite indexes and left-prefix thinking
- partial indexes
- expression indexes
- `EXPLAIN ANALYZE`
- row-estimate mismatch

## SARGability

A query is easier to optimize when the planner can search directly on indexed values.

Good instinct:

- rewrite predicates so the indexed column appears plainly
- avoid wrapping indexed columns in unnecessary functions

## Interview Lens

You do not need to be a DBA. But you do need to sound like someone who respects data scale.
