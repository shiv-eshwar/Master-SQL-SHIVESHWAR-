# Chapter 2: The Relational Model

## Where It Comes From

Edgar Codd published "A Relational Model of Data for Large Shared Data Banks" in 1970. The paper did something radical: it applied rigorous mathematics (set theory and predicate logic) to data management, replacing the ad-hoc navigational databases of the time.

The relational model has three components:

1. **Data structure**: how data is represented (relations/tables)
2. **Data integrity**: what constraints the data must satisfy
3. **Data manipulation**: how data is retrieved and modified (relational algebra)

## Relations Are Mathematical Sets

A **relation** is a set of tuples. A **tuple** is an ordered list of values, one per attribute. A **domain** is the set of legal values for an attribute.

Critical points:

- A relation is a **set**: no duplicate rows, no ordering of rows.
- An actual SQL table is a **multiset** (bag): it allows duplicates unless you enforce a uniqueness constraint. This is a well-known compromise SQL makes against strict set theory.
- Row order in a table is meaningless. The only meaningful ordering comes from `ORDER BY` in a query.

## Keys: The Most Important Concept in Database Design

Every key type serves a purpose. Confusing them leads to bad schema design.

### Superkey
A set of one or more attributes whose combination uniquely identifies every tuple in a relation. A superkey can contain extra attributes.

### Candidate Key
A **minimal** superkey: no proper subset of it is also a superkey. A table can have multiple candidate keys.

Example in `hr.employees`:
- `employee_id` is a candidate key (unique integer per employee)
- `email` is also a candidate key (unique email per employee)
- `(employee_id, email)` is a superkey but not a candidate key because `employee_id` alone is already unique

### Primary Key
The candidate key you choose to be the main row identifier. Every table should have one.

Rules:
- Never NULL
- Never changes (if possible — changing a primary key causes cascading updates)
- Has no business meaning of its own (prefer surrogate keys for stability)

### Foreign Key
An attribute in one table that references the primary key of another table. It enforces **referential integrity**: you cannot reference a row that does not exist.

### Surrogate vs Natural Keys

**Natural key**: a key derived from a real-world attribute (e.g., email, national ID number, ISBN).

Problem: real-world data changes. An employee changes their name, email, or national ID. Now you have a cascade of updates.

**Surrogate key**: a system-generated identifier with no business meaning (e.g., `employee_id integer GENERATED ALWAYS AS IDENTITY`).

Recommendation: almost always prefer surrogate keys as primary keys, and treat natural keys as `UNIQUE NOT NULL` constraints.

### Composite Key
A primary key made of two or more columns. Common in junction tables.

Example: `order_items(order_id, line_number)` — neither column alone identifies a row, but together they do.

## Integrity Constraints

### Entity Integrity
No part of a primary key can be NULL. A NULL primary key is meaningless: you cannot identify what the row is about.

### Referential Integrity
Every foreign key value must either match a primary key value in the referenced table or be NULL (if the relationship is optional). This is enforced by `FOREIGN KEY` constraints with cascade behaviors:

- `ON DELETE CASCADE`: delete children when parent is deleted
- `ON DELETE RESTRICT`: refuse to delete parent if children exist
- `ON DELETE SET NULL`: set foreign key to NULL when parent is deleted

### Domain Integrity
Every value must belong to the domain (data type + constraint) defined for its attribute.

`CHECK` constraints, `NOT NULL`, and data types all enforce domain integrity.

## Relational Algebra: The Theory Behind SQL

SQL is based on relational algebra, an abstract language for manipulating relations. Understanding algebra makes SQL intuitive rather than magical.

### SELECT (σ) — Filter Rows

Filters tuples based on a condition. Corresponds to `WHERE` in SQL.

```
σ salary > 100000 (employees)
```

### PROJECT (π) — Choose Columns

Returns only specified attributes. Corresponds to `SELECT column_list`.

```
π full_name, salary (employees)
```

### JOIN (⋈) — Combine Relations

Combines two relations based on a condition. The natural join matches on equal attribute names.

```
employees ⋈ departments
```

### UNION (∪) — Combine Rows

Returns all tuples from both relations. Requires compatible schemas (same attribute types).

### INTERSECTION (∩) — Common Rows

Returns only tuples appearing in both relations.

### DIFFERENCE (−) — Rows in One but Not Other

Tuples in relation A that do not appear in relation B. This is the anti-join concept.

### PRODUCT (×) — Cartesian Product

All combinations of tuples from both relations. An unfiltered JOIN is a Cartesian product.

**Why this matters for SQL:** Every SQL query is a composition of these operations. When you understand this, weird behaviors stop being mysterious:

- `COUNT(DISTINCT ...)` is a PROJECT after a UNION that removes duplicates
- A Cartesian explosion in aggregation is an accidental unfiltered PRODUCT
- An anti-join is a DIFFERENCE expressed as `NOT EXISTS`

## Codd's 12 Rules (Simplified)

In 1985, Codd published 12 rules a system must follow to be called "relational." The most practically important ones:

**Rule 1 (Information Rule):** All information is represented as values in table cells. No pointers, no hidden record IDs visible to applications.

**Rule 2 (Guaranteed Access):** Every value can be accessed using the table name, primary key, and column name. Nothing else is needed.

**Rule 3 (Systematic NULL Handling):** NULLs must be handled uniformly as "missing or inapplicable" — not zero, not empty string.

**Rule 5 (Comprehensive Data Sublanguage):** There must be a language (SQL) supporting data definition, manipulation, integrity, and authorization.

**Rule 8 (Physical Data Independence):** Applications must not break when physical storage changes.

**Rule 9 (Logical Data Independence):** Applications must not break when logical schema changes (adding tables, adding columns).

## Why This Theory Matters in Interviews

MAANG interviewers will ask:

- "Why use a surrogate key instead of email as the primary key?"
- "What is referential integrity and how do you enforce it?"
- "Why can't you use a composite primary key here?"
- "What happens if you don't have a primary key on this table?"
- "What does a Cartesian product mean in the context of your join?"

You now have principled answers to all of these.
