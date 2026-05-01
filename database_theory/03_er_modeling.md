# Chapter 3: Entity-Relationship Modeling

## What ER Modeling Is For

Before you write a single `CREATE TABLE`, you need to understand what you are modeling. Entity-Relationship (ER) modeling gives you a language for thinking through the structure of a domain before committing to a physical schema.

An ER model is a communication tool. It helps you talk to business stakeholders who do not know SQL, verify your understanding of the domain, and catch design mistakes before they are expensive to fix.

## The Three Building Blocks

### 1. Entities

An **entity** is a thing in the real world that is distinguishable from other things. In a database, an entity type becomes a table.

Rules for identifying entities:
- Does it have attributes you want to store?
- Does it have an independent existence (its own identity)?
- Do other things relate to it?

Examples from our HR schema: `Employee`, `Department`, `PerformanceReview`.

**Weak entities** depend on a strong entity for their existence and identification. A `SalaryHistory` record only makes sense in the context of an `Employee`. Its identifying key is a combination of its own partial key (e.g., `effective_date`) and the parent's primary key.

### 2. Attributes

An **attribute** is a property of an entity.

**Simple attribute**: atomic, cannot be subdivided. `email`, `salary`, `hire_date`.

**Composite attribute**: made of sub-attributes. A `full_address` is composed of `street`, `city`, `state`, `postal_code`. In practice, store composites as separate columns so you can filter on them independently.

**Derived attribute**: computed from other attributes. `age` is derived from `birth_date` and the current date. Do not store derived attributes unless computation is expensive and values are queried frequently.

**Multivalued attribute**: an entity can have multiple values for this attribute. An employee might have multiple phone numbers. These become a separate child table (one row per phone number per employee).

**Key attribute**: the attribute or set of attributes that uniquely identifies each entity instance. Becomes the primary key.

### 3. Relationships

A **relationship** is an association between two or more entity types.

#### Cardinality

Cardinality describes how many instances of one entity can relate to instances of another.

**One-to-One (1:1)**: One employee has one HR profile. One HR profile belongs to one employee. Use this when you want to split a wide table for performance or security reasons.

**One-to-Many (1:N)**: One department has many employees. Each employee belongs to exactly one department. This is the most common relationship. Implemented with a foreign key on the "many" side.

**Many-to-Many (M:N)**: One order contains many products. One product appears in many orders. Cannot be directly represented in a relational table. Always resolved with a **junction table** (also called a bridge table or associative entity).

```
orders ——— order_items ——— products
```

`order_items` has its own attributes (`quantity`, `unit_price`) and its primary key is the composite of `(order_id, product_id)`.

#### Participation

**Total participation**: every instance of the entity must participate in the relationship. Drawn as a double line. Implemented with `NOT NULL` on the foreign key.

Example: every `Employee` must belong to a `Department`. The `department_id` foreign key is `NOT NULL`.

**Partial participation**: some instances may not participate. Drawn as a single line. Implemented with a nullable foreign key.

Example: some `Employees` may have no `Manager` (the CEO). The `manager_id` foreign key is nullable.

#### Self-Referencing Relationships

An entity that relates to itself. The canonical example is the employee-manager relationship: both the employee and the manager are rows in the same `employees` table.

Implemented with a self-referencing foreign key: `manager_id REFERENCES employees(employee_id)`.

## Converting an ER Diagram to a Relational Schema

Follow these rules mechanically:

**Rule 1: Every strong entity becomes a table.**

```
Employee → hr.employees(employee_id PK, full_name, email, ...)
Department → hr.departments(department_id PK, department_name, ...)
```

**Rule 2: Every simple attribute becomes a column.**

**Rule 3: Composite attributes → expand into individual columns.**

**Rule 4: Derived attributes → do not store; compute in queries.**

**Rule 5: Multivalued attributes → new child table with a foreign key back to the parent.**

```
Employee phones → hr.employee_phones(employee_id FK, phone_number, phone_type)
```

**Rule 6: Weak entities → table whose primary key is (parent PK + partial key).**

```
SalaryHistory → hr.salary_history(employee_id FK, effective_date, salary_amount)
PK: (employee_id, effective_date)
```

**Rule 7: 1:1 relationship → add the foreign key to whichever side makes more semantic sense.**

Usually place the foreign key on the side that participates partially (the side that does not always have a match).

**Rule 8: 1:N relationship → add the foreign key to the "many" side.**

`employees.department_id REFERENCES departments(department_id)`

**Rule 9: M:N relationship → create a junction table.**

```
CREATE TABLE ecommerce.order_items (
    order_id bigint REFERENCES orders,
    product_id integer REFERENCES products,
    quantity integer,
    unit_price numeric,
    PRIMARY KEY (order_id, product_id)
);
```

## A Worked Example: E-commerce Domain

### Entities Identified

- Customer
- Order
- Product
- Category (one-to-many with Product)

### Relationships

- Customer places Order (1:N — one customer, many orders)
- Order contains Product (M:N — through order_items)
- Product belongs to Category (N:1)

### Cardinality and Participation

- Every Order must have a Customer (total participation, NOT NULL FK)
- A Customer may have zero or many Orders (partial participation from Customer side)
- Every order_items row must have both an Order and a Product (total participation, NOT NULL FKs)

### Resulting Schema Tables

```
customers(customer_id PK, signup_date, country, ...)
products(product_id PK, product_name, unit_price, category_id FK, ...)
orders(order_id PK, customer_id FK NOT NULL, order_ts, status, ...)
order_items(order_id FK, product_id FK, quantity, unit_price, PK: both)
```

This is exactly the `ecommerce` schema seeded in this repo.

## Common ER Design Mistakes

**Storing the result of a join.** If you find yourself storing `department_name` inside the `employees` table, you have embedded a join result. That column should live only in `departments`.

**Missing the junction table.** If you try to store multiple product IDs in a single order row as a comma-separated list, that is a multivalued attribute mistake. It breaks normalization, makes querying painful, and loses referential integrity.

**Overusing 1:1 splits.** Splitting a table into two 1:1 tables when there is no real separation of concern adds join overhead without benefit.

**Confusing entity with attribute.** If you find yourself adding columns like `phone_1`, `phone_2`, `phone_3`, you have mistakenly made a multivalued attribute into columns. Create a child table instead.

## Interview Lens

ER design questions appear as system design problems:

- "Design the database for an Uber-like app."
- "Design the schema for a social network feed."
- "Design a schema to track user experiments."

Your approach should always be:
1. Identify entities.
2. Identify their key attributes.
3. Identify relationships and cardinalities.
4. Draw or verbalize the ER model.
5. Convert to tables with primary and foreign keys.
6. Discuss normalization and any intentional denormalization.
