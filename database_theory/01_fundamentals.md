# Chapter 1: Database Fundamentals

## The Problem Databases Solve

Before databases existed, applications stored data in flat files: text files, CSV files, binary files managed by the application itself. This created four catastrophic problems:

**Data redundancy.** The same customer's address appears in the orders file, the invoices file, and the shipping file. When they move, you update one and forget the others. Now you have three different addresses for the same person.

**Data inconsistency.** A direct consequence of redundancy. Different parts of the system disagree about facts. There is no single source of truth.

**Data isolation.** Data that belongs together is scattered across files in different formats. Getting a simple business answer requires code that understands every file format and joins them manually.

**Concurrent access problems.** If two processes write the same file simultaneously, they corrupt each other's data. The file system has no concept of transactions.

A **Database Management System (DBMS)** solves all four problems at once by providing:

- a **centralized store** that is the single source of truth
- a **query language** that lets you ask questions without knowing how data is physically stored
- **transaction support** so concurrent access is safe
- **integrity enforcement** so bad data cannot enter the system

## Data Independence: The Core DBMS Promise

The most important idea in DBMS design is the separation between **how data is physically stored** and **how applications view data**.

This separation has two levels:

**Physical data independence** means you can change how data is laid out on disk — reorder columns, add compression, change the file format, switch storage engines — without breaking any application that queries the data.

**Logical data independence** means you can change the logical schema — add a new table, split a table into two, rename a column — without breaking applications that work on other parts of the schema.

Without these guarantees, every schema change breaks every application. With them, you can evolve a database over years without touching code that doesn't need to change.

## The Four Major Data Models

A **data model** is the abstraction used to represent and query data. The model determines how you think about your data, which questions are natural to ask, and which operations are efficient.

### 1. Relational Model

Data is organized as a collection of tables (relations). Each table has rows (tuples) and columns (attributes). Tables relate to each other through shared key values.

Invented by Edgar Codd at IBM in 1970. Still the dominant model for transactional systems.

Strengths: strong theoretical foundation, flexible queries, great for structured data with complex relationships, ACID guarantees.

Weaknesses: rigid schema, joins are expensive at extreme scale, poor fit for hierarchical or graph data.

Examples: PostgreSQL, MySQL, Oracle, SQL Server.

### 2. Document Model

Data is stored as self-describing documents, typically JSON or BSON. A document is a nested structure that can contain arrays and sub-documents. Related data is often embedded inside a single document rather than spread across tables.

Strengths: flexible schema, natural for hierarchical data, easy to read a complete entity in one operation.

Weaknesses: poor support for cross-document relationships, can lead to data duplication, weaker consistency guarantees.

Examples: MongoDB, Couchbase, DynamoDB (partially).

### 3. Key-Value Model

The simplest possible data model. A key maps to an arbitrary blob of data. The database has no knowledge of the value's structure.

Strengths: extremely fast reads and writes, trivially scalable horizontally.

Weaknesses: only look up by key; cannot query by value without scanning everything.

Examples: Redis, DynamoDB, Memcached.

### 4. Graph Model

Data is represented as nodes (entities) and edges (relationships). Both nodes and edges can carry properties.

Strengths: efficient traversal of relationships, natural for social networks, recommendation systems, fraud detection.

Weaknesses: poor for aggregate queries, less mature tooling, unfamiliar query languages (Cypher, Gremlin).

Examples: Neo4j, Amazon Neptune.

### 5. Column-Family (Wide-Column) Model

Data is stored by column family rather than by row. Excellent for analytics workloads that read a few columns across millions of rows.

Examples: Apache Cassandra, Apache HBase, Google Bigtable.

## DBMS Architecture: The Five Components

Every DBMS, regardless of data model, has five fundamental components:

**1. Storage engine.** Manages how data is physically written to and read from disk. Decides the file format, page layout, compression, and caching strategy.

**2. Query processor.** Parses queries written in the query language, validates them against the schema, and produces an internal representation (logical plan).

**3. Query optimizer.** Takes the logical plan and generates a physical execution plan. Chooses join algorithms, index access paths, and operation order to minimize cost.

**4. Transaction manager.** Ensures that concurrent queries do not corrupt each other's view of data. Implements isolation through locking or multiversion concurrency control.

**5. Recovery manager.** Uses a write-ahead log to ensure that completed transactions survive crashes and incomplete transactions are rolled back.

## SQL vs NoSQL: The Real Distinction

The "SQL vs NoSQL" framing is misleading. The real distinctions are:

| Dimension | Relational | Non-Relational |
|-----------|-----------|----------------|
| Schema | Fixed, enforced | Flexible, per-document |
| Query language | SQL (standardized) | Varies by system |
| Relationships | Join-based | Often embedding-based |
| Consistency | Strong ACID by default | Often eventual |
| Scaling | Vertical + managed horizontal | Designed for horizontal |
| Best fit | Complex queries, integrity | High write volume, flexible shape |

Neither model is universally better. Senior data scientists know when to reach for each one.

## Key Terms You Must Know Cold

- **Schema**: the structure of a database — its tables, columns, types, and constraints
- **Instance**: the actual data in a database at a point in time
- **Metadata**: data about data; stored in the system catalog
- **Query**: a request for data, expressed in a query language
- **Transaction**: a unit of work that is either fully completed or fully undone
- **Catalog / Data dictionary**: the DBMS's internal store of metadata about schemas, indexes, and statistics
