# Local PostgreSQL Notes

This repo assumes you already have PostgreSQL installed locally.

## Useful `psql` Commands

```sql
\l          -- list databases
\c dbname   -- connect to a database
\dt         -- list tables
\d tabname  -- describe a table
\df         -- list functions
\timing     -- show query runtime
\x auto     -- expanded display when helpful
\pset null '<NULL>'
```

## Recommended Session Defaults

These settings make learning easier in `psql`:

```sql
\timing on
\x auto
\pset null '<NULL>'
```

## Interview-Friendly Habits

- Always alias tables clearly.
- Use lowercase SQL keywords if that feels natural, but stay consistent.
- Format long queries into named CTE layers.
- Prefer explicit column lists over `SELECT *`.

## Extensions Worth Knowing

You do not need all of these for interviews, but you should know they exist:

- `pg_stat_statements`: query monitoring
- `tablefunc`: includes `crosstab`
- `uuid-ossp` or `pgcrypto`: UUID generation

## Seeding Order

1. Run `setup/seed/00_create_databases.sql`
2. Connect to `sql_hr` and run `setup/seed/01_hr.sql`
3. Connect to `sql_ecommerce` and run `setup/seed/02_ecommerce.sql`
4. Connect to `sql_social` and run `setup/seed/03_social.sql`
5. Connect to `sql_rideshare` and run `setup/seed/04_rideshare.sql`

## Why Multiple Databases?

Different schemas trigger different query instincts:

- HR teaches joins, slowly changing salary tables, and org hierarchies.
- E-commerce teaches revenue, cohort, funnel, and product analytics.
- Social teaches graph-like relationships, engagement metrics, and dedup.
- Ride-share teaches event streams, sessionization, latency, and operational SQL.

## Performance Workflow

Get used to this loop from the first week:

```sql
EXPLAIN ANALYZE
SELECT ...
```

Do not wait until week 10 to look at plans. Build the habit early.
