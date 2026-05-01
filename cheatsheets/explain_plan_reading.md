# EXPLAIN Plan Reading Cheatsheet

- `Seq Scan`: scans the whole table
- `Index Scan`: walks an index to fetch matching rows
- `Index Only Scan`: can satisfy query from index alone
- `Hash Join`: build hash table, then probe
- `Merge Join`: combine sorted streams
- `Nested Loop`: repeated inner lookup per outer row

Always compare:

- estimated rows vs actual rows
- cost vs actual time
- loops count
- filter selectivity
