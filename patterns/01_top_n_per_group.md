# Top-N Per Group

## Use When

You need the latest, highest, or first `N` rows inside each group.

## Core Tools

- `ROW_NUMBER()`
- `RANK()`
- `DISTINCT ON`
- `LATERAL`

## Canonical Pattern

Partition by the group key, order rows by the scoring rule, then filter to the top ranks.

## Worked Ideas

- latest order per customer
- top 2 salaries per department
- highest-impression post per content type

## Interview Note

Always say how you want ties handled.
