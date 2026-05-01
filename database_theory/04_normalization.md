# Chapter 4: Normalization

## Why Normalization Exists

Normalization is the process of structuring a relational schema to reduce redundancy and protect data integrity. It does not exist to satisfy academic purity. It exists because redundancy causes **update anomalies**.

There are three types of update anomaly:

**Insertion anomaly**: you cannot add new information without also adding other, unrelated information. If department location is stored in the employees table, you cannot record a new department until at least one employee works there.

**Update anomaly**: changing one fact requires updating multiple rows. If department location appears on every employee row, moving a department means updating hundreds of rows. Miss one and you have inconsistent data.

**Deletion anomaly**: deleting one fact accidentally deletes another. If the last employee in a department is deleted, the department itself disappears from the database.

Normalization eliminates these problems by ensuring each fact is stored exactly once.

## Functional Dependencies: The Foundation

A **functional dependency** (FD) is a constraint between two attribute sets. We say X → Y (X determines Y) if for every valid state of the relation, whenever two tuples agree on X, they also agree on Y.

Example in a hypothetical unnormalized table:

```
orders_bad(order_id, customer_id, customer_email, product_id, product_name, quantity)
```

Functional dependencies:
- `order_id, product_id → quantity` (correct: quantity is per order-product pair)
- `customer_id → customer_email` (customer_email depends on customer_id, not on the full key)
- `product_id → product_name` (product_name depends only on product_id)

The last two are the problem. They are partial dependencies: they depend on a subset of the candidate key, not the full key.

## First Normal Form (1NF)

**Rule**: every column must contain only atomic (indivisible) values. No repeating groups, no arrays, no comma-separated lists.

**Violation example**:

```
employee_id | full_name | phone_numbers
1           | Asha     | 9999999999, 8888888888
```

**Fix**: create a child table.

```
employee_phones(employee_id, phone_number, phone_type)
```

1NF also requires:
- all rows are distinct (or there is a primary key)
- column names are unique
- column order is irrelevant

Modern PostgreSQL allows array columns and JSON, but you should treat them carefully: querying into an array or JSON field bypasses the FD protections that normalized schemas give you.

## Second Normal Form (2NF)

**Rule**: the relation is in 1NF AND every non-key attribute is **fully functionally dependent** on the entire primary key. There are no **partial dependencies** (where an attribute depends only on part of a composite key).

2NF is only relevant when the primary key is composite.

**Violation example**:

```
order_items_bad(order_id, product_id, quantity, product_name, product_category)
PK: (order_id, product_id)
```

`product_name` and `product_category` depend only on `product_id`, not on the full key `(order_id, product_id)`. This is a partial dependency.

**Fix**: move product attributes to a separate products table.

```
order_items(order_id, product_id, quantity)
products(product_id, product_name, product_category)
```

## Third Normal Form (3NF)

**Rule**: the relation is in 2NF AND there are no **transitive dependencies**: no non-key attribute depends on another non-key attribute.

**Violation example**:

```
employees_bad(employee_id, department_id, department_name, department_location)
```

Here:
- `employee_id → department_id` (direct)
- `department_id → department_name` (transitive)
- `department_id → department_location` (transitive)

`department_name` and `department_location` are transitively dependent on `employee_id` through `department_id`. The department name has nothing to do with the employee; it is a fact about the department.

**Fix**: separate the department information.

```
employees(employee_id, department_id FK, ...)
departments(department_id PK, department_name, department_location)
```

This is exactly the structure in `hr.employees` and `hr.departments`.

## Boyce-Codd Normal Form (BCNF)

**Rule**: for every non-trivial functional dependency X → Y, X must be a **superkey**.

BCNF is stricter than 3NF. In 3NF, a non-key attribute can determine another non-key attribute as long as neither is part of a candidate key. BCNF closes this loophole.

BCNF violations are rare in practice and often require preserving a functional dependency at the cost of decomposition. Most well-designed schemas in 3NF are already in BCNF.

**When BCNF differs from 3NF**: only when a relation has multiple overlapping candidate keys where one candidate key is composite. These situations are uncommon but appear in certain scheduling or assignment schemas.

## Fourth Normal Form (4NF)

**Rule**: the relation is in BCNF AND it contains no non-trivial **multivalued dependencies** (MVDs).

A multivalued dependency X →→ Y exists when, for a given X value, there is a set of Y values that are independent of any other attributes.

**Example**:

Suppose an employee can have multiple skills and multiple certifications, and these are stored together:

```
employee_skills_certs(employee_id, skill, certification)
```

Rows might be:
```
(1, Python, AWS)
(1, Python, GCP)
(1, SQL, AWS)
(1, SQL, GCP)
```

Every combination of skill and certification must appear for each employee. This is a multivalued dependency: `employee_id →→ skill` and `employee_id →→ certification`.

**Fix**: decompose into two tables.

```
employee_skills(employee_id, skill)
employee_certifications(employee_id, certification)
```

## Fifth Normal Form (5NF) / Project-Join Normal Form

**Rule**: every join dependency in the relation is implied by the candidate keys.

5NF handles the rare case where a relation can be losslessly decomposed into three or more tables. In practice you will almost never encounter genuine 5NF violations in application design. It is important to know it exists, not to apply it routinely.

## Denormalization: When to Break the Rules

Normalization is the right default. But data scientists need to know when to denormalize deliberately.

**When denormalization is valid**:

1. **Read-heavy analytical workloads.** Joining 5 tables on every analytical query is expensive. A pre-joined, wider fact table avoids runtime join overhead at query time.

2. **Reporting dimensions.** A dimension table like `dim_customers` in a data warehouse intentionally stores `country_name` alongside `country_code` to avoid a join to a tiny lookup table on every report query.

3. **Aggregation caching.** If you compute `total_orders_per_customer` frequently and it never changes retroactively, storing it pre-computed can be justified.

**When denormalization is NOT valid**:

- For transactional (OLTP) data where updates are frequent and correctness is critical.
- As a way to avoid learning how to write joins properly.
- When the query you are optimizing runs infrequently.

**Rule of thumb**: normalize first, denormalize second, always with a documented reason and an awareness of which update anomalies you are accepting.

## Practical Normalization Checklist

For each table you design, ask:

1. Does every column contain atomic values? (1NF)
2. If the PK is composite, does every non-key column depend on the whole PK? (2NF)
3. Does every non-key column depend directly on the PK rather than transitively through another non-key column? (3NF)
4. Is every functional determinant a superkey? (BCNF)
5. Are there independent multi-valued facts stored in the same table? (4NF)

Answering no to any question tells you exactly how to fix the schema.

## Interview Lens

Normalization questions appear in:
- "What is the problem with this schema?" (identify the anomaly type)
- "How would you redesign this table?" (apply normalization)
- "Why does this query produce duplicate rows?" (likely a join against a non-normalized table causing fan-out)
- "When would you intentionally denormalize?" (data warehouse discussion)

The magic answer to "why do duplicate rows appear?" is almost always:
"A join is multiplying rows because the driving table has a many-to-many relationship with the joined table, or because the joined table was not normalized and stores repeated data."
