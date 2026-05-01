# Chapter 9: The Database Design Process

## The Goal

Good database design is not about memorizing rules. It is about building a schema that is:

- correct (reflects reality faithfully)
- consistent (cannot store contradictory facts)
- efficient (supports the queries your application actually runs)
- maintainable (can evolve without catastrophic rewrites)

Most real-world databases fail on one of these because the design process was rushed.

## The Four Phases of Database Design

### Phase 1: Requirements Analysis

Before drawing any ER diagram or writing any DDL, you must understand:

1. What **entities** exist in this domain?
2. What **facts** do we need to store about each entity?
3. What **relationships** exist between entities?
4. What **questions** (queries) will the application ask?
5. What **constraints** must always be true (business rules)?
6. What is the expected **data volume** and **access pattern**?

Key questions to ask stakeholders:

- "Can a customer have multiple addresses?" (cardinality question)
- "Can an order be modified after it is placed?" (update pattern)
- "What happens when a customer is deleted — do we keep their orders?" (referential action)
- "How often will we read vs write this data?" (OLTP vs OLAP decision)
- "What are the most critical queries this system needs to support?" (index design starts here)

Mistakes in Phase 1 are the most expensive. A schema built on wrong requirements will be fundamentally wrong, not just slow.

### Phase 2: Conceptual Design

Produce an Entity-Relationship (ER) model. This is database-agnostic — no SQL, no data types, no indexes. Just entities, attributes, and relationships.

Deliverables:
- ER diagram (boxes for entities, diamonds for relationships, ovals for attributes)
- Relationship cardinalities and participation constraints
- A written description of each entity and its meaning

This phase is done with business stakeholders, not just engineers. The ER model is the contract between domain understanding and technical implementation.

### Phase 3: Logical Design

Convert the ER model into a relational schema: tables, columns, data types, primary keys, foreign keys, and constraints.

Steps:
1. Convert entities to tables.
2. Convert attributes to columns, assigning correct data types.
3. Implement relationship cardinalities as foreign keys.
4. Create junction tables for M:N relationships.
5. Apply normalization (1NF through BCNF at minimum).
6. Verify all business rules are expressible as constraints.

Deliverables:
- DDL (`CREATE TABLE` statements)
- Documented functional dependencies
- Verification that the schema is in at least 3NF

### Phase 4: Physical Design

Now you think about performance: indexes, partitioning, materialized views, and storage configuration.

Steps:
1. Identify the most frequent and most critical queries.
2. Design indexes to support those queries (use the left-prefix rule for composites, partial indexes for subsets, covering indexes where possible).
3. Decide on partitioning strategy for tables expected to grow very large.
4. Decide on materialized views for expensive aggregations that do not need to be real-time.
5. Plan `VACUUM` and `ANALYZE` frequency for high-write tables.

Do not index everything. Every index has a write cost. Design indexes for real query patterns, not hypothetical ones.

## A Complete Worked Example: Ride-Share Platform

### Phase 1 Requirements

- Riders request rides.
- Drivers accept and complete rides.
- Each ride has a status progression: requested → accepted → picked_up → completed (or cancelled).
- Payments are processed after completion.
- The platform needs to track driver ratings.
- Analytics need: completion rate, average fare, surge impact, driver earnings, rider retention.

### Phase 2 Conceptual Model

Entities: `Rider`, `Driver`, `Ride`, `Payment`

Relationships:
- Rider **places** Ride (1:N — one rider, many rides)
- Driver **accepts** Ride (1:N — one driver, many rides)
- Ride **has** Payment (1:1 — one payment per completed ride)

### Phase 3 Logical Design

```sql
CREATE TABLE rideshare.riders (
    rider_id integer PRIMARY KEY,
    city text NOT NULL,
    signup_date date NOT NULL
);

CREATE TABLE rideshare.drivers (
    driver_id integer PRIMARY KEY,
    city text NOT NULL,
    rating numeric(3,2)
);

CREATE TABLE rideshare.rides (
    ride_id bigint PRIMARY KEY,
    rider_id integer NOT NULL REFERENCES riders,
    driver_id integer NOT NULL REFERENCES drivers,
    requested_ts timestamptz NOT NULL,
    completed_ts timestamptz,
    status text NOT NULL,
    actual_fare numeric(10,2)
);

CREATE TABLE rideshare.payments (
    payment_id bigint PRIMARY KEY,
    ride_id bigint UNIQUE NOT NULL REFERENCES rides,
    gross_amount numeric(10,2) NOT NULL,
    paid_ts timestamptz
);
```

### Phase 4 Physical Design

```sql
-- Most common query: latest rides for a rider
CREATE INDEX idx_rides_rider_ts ON rides (rider_id, requested_ts DESC);

-- Analytics query: completed rides only
CREATE INDEX idx_rides_completed ON rides (requested_ts)
WHERE status = 'completed';

-- Payments lookup by ride
CREATE INDEX idx_payments_ride ON payments (ride_id);
```

## Common Design Anti-Patterns

### The "God Table"

A single table with hundreds of columns trying to represent many different entity types. Often created by adding nullable columns every time a new feature is added.

Symptoms:
- Many columns are NULL for most rows
- Rows of the same table represent fundamentally different things
- Queries become a maze of COALESCE and CASE WHEN

Fix: use proper entity decomposition. If products have different attributes depending on type, use either a class hierarchy pattern or a separate attribute table.

### Entity-Attribute-Value (EAV)

Storing attribute names and values as rows rather than columns:

```
entity_id | attribute_name | attribute_value
1         | color          | red
1         | weight         | 500
1         | material       | cotton
```

Problems:
- Cannot use column-level type constraints (all values are text)
- Queries require pivot operations for every report
- No referential integrity on attribute names
- Terrible performance for reading all attributes of an entity

EAV is sometimes justified for genuinely dynamic schemas (e.g., a generic form builder), but it is frequently misused as a shortcut to avoid schema design.

### String-Encoded Enums

Storing status values as arbitrary strings without a constraint.

```sql
-- Bad: no enforcement of valid values
status text NOT NULL

-- Better:
status text NOT NULL CHECK (status IN ('placed', 'shipped', 'delivered', 'cancelled'))

-- Or use a PostgreSQL enum type:
CREATE TYPE order_status AS ENUM ('placed', 'shipped', 'delivered', 'cancelled');
```

### Storing Computed Values Without Refresh Logic

Caching a computed aggregate (e.g., `total_orders` on the customer row) is tempting. But if the update logic is not airtight, the cached value goes stale silently. Consider materialized views instead, which can be refreshed explicitly.

### Soft Deletes Without Indexing Strategy

"Soft delete" means adding `is_deleted boolean` and filtering `WHERE is_deleted = false` everywhere, instead of actually deleting rows.

Problems:
- Every query needs the extra filter
- Indexes must cover the filter (partial index helps)
- Old data accumulates indefinitely

If soft deletes are needed, use a partial index and consider archiving rows to a separate table after a time threshold.

### Missing the Right Time Type

Storing timestamps as `timestamp` (no time zone) for event data that users in multiple time zones produce. All times shift when servers or time zones change.

Rule: use `timestamptz` for all event data. Use `date` for calendar-only dates that have no time component (birth date, hire date).

## Schema Evolution

Real databases change. Good physical design anticipates evolution:

- Adding a nullable column to a large table in PostgreSQL is nearly instantaneous (just a metadata change).
- Adding a `NOT NULL` column without a default requires a full table rewrite.
- Adding an index concurrently (`CREATE INDEX CONCURRENTLY`) avoids table locks.
- Renaming a column in a zero-downtime deployment requires a multi-step migration (add new column, backfill, update code, drop old column).

Plan your schema so that adding new features is additive (new tables, new columns) rather than disruptive (changing existing column types, splitting tables).

## The Data Scientist's Design Checklist

Before finalizing any schema:

1. Does every table have a primary key that uniquely and stably identifies each row?
2. Is every relationship represented by a properly constrained foreign key?
3. Are all required columns `NOT NULL`?
4. Are business rule constraints encoded in the database (`CHECK`, `UNIQUE`)?
5. Are timestamps stored as `timestamptz`?
6. Are enum-like values constrained to a valid set?
7. Is every M:N relationship resolved through a junction table?
8. Is the schema in at least 3NF (or is any denormalization intentional and documented)?
9. Are indexes designed for the actual query patterns, not hypothetical ones?
10. Is the schema evolution strategy documented?
