# Index Decision Tree

- equality or range lookup on scalar columns -> B-tree
- frequent subset queries -> partial index
- expression repeatedly filtered -> expression index
- many-value document search -> GIN for `jsonb`
- append-heavy very large tables with natural ordering -> BRIN may help

Checklist:

1. what predicate repeats often?
2. what columns define filtering?
3. what columns define ordering?
4. is the index selective enough?
5. what write overhead will this add?
