# Date and Time Cheatsheet

- truncate grain: `DATE_TRUNC('month', ts)`
- extract component: `EXTRACT(DOW FROM ts)`
- compute age: `AGE(ts1, ts2)`
- add/subtract intervals: `ts + INTERVAL '7 days'`
- generate ranges: `generate_series(start, stop, step)`

Rules:

- use `timestamptz` for event data
- aggregate to the correct time grain first
- prefer range predicates over wrapping indexed columns in functions
