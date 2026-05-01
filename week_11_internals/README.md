# Week 11: Internals, Transactions, and Production Thinking

## Why This Matters For Senior Interviews

At senior level, correctness includes concurrency.

Two perfectly written queries can still produce wrong business outcomes if you do not understand transaction isolation, locking, and visibility.

## Topics

- MVCC
- dead tuples and vacuum
- transaction isolation levels
- row locking
- materialized views
- partitioning

## Simple Mental Model For MVCC

PostgreSQL often keeps multiple row versions alive temporarily so readers do not block writers. That is why vacuum exists.

## Interview Lens

You are not trying to become a full database administrator here. You are trying to explain:

- why race conditions happen
- why repeatable reads matter
- why `FOR UPDATE` changes behavior
- why partitioning can help on huge tables
