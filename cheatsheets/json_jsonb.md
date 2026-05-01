# JSON vs JSONB Cheatsheet

- `json` stores text-like JSON
- `jsonb` stores a binary representation optimized for querying
- use `jsonb` in most analytical and interview contexts

Useful operators:

- `->` get JSON value
- `->>` get text value
- `@>` contains
- `?` key exists

Useful builders:

- `jsonb_build_object`
- `jsonb_agg`
