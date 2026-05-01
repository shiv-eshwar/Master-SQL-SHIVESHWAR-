# Week 7: Dates, Strings, Arrays, and JSONB

## Why This Week Matters

A lot of interview SQL looks hard only because the data is messy:

- time zones
- textual parsing
- nested JSON
- repeated values in arrays

This week gives you the tools for that mess.

## Dates and Time

You must be comfortable with:

- `DATE_TRUNC`
- `EXTRACT`
- `AGE`
- `INTERVAL`
- `generate_series`

The biggest time mistake is using the wrong grain. Day, week, month, and rolling 7-day windows are different questions.

## Strings and Regex

Know how to:

- normalize case
- trim and split text
- search with `LIKE` / `ILIKE`
- use regex operators when patterns matter

## Arrays and JSONB

Arrays are good for repeated scalar values. `jsonb` is good for semi-structured records. In PostgreSQL interviews, just knowing that `jsonb` is indexable and queryable already gives you an edge.

## Interview Lens

Real datasets are not perfectly normalized. Strong candidates can still derive clean metrics from imperfect event data.
