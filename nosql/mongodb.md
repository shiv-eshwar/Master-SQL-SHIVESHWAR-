# MongoDB: From Basics to Advanced

## Why a Separate Guide for MongoDB?

MongoDB is the most widely deployed document database. As a data scientist, you will encounter it in:
- application databases where data is shipped as JSON
- data pipelines that pull from MongoDB into analytical systems
- real-time dashboards built directly on document stores
- interview system design questions where you must justify database choice

This guide covers everything you need to understand, use, and talk about MongoDB confidently in a senior context.

---

## Part 1: The Document Model

### What Is a Document?

A document is a JSON-like object that contains key-value pairs, arrays, and nested documents. In MongoDB, documents are stored as **BSON** (Binary JSON), which is a binary-encoded superset of JSON with additional types.

```json
{
  "_id": ObjectId("648abc123def456789012345"),
  "customer_id": 5,
  "signup_date": ISODate("2023-02-21"),
  "country": "India",
  "is_premium": true,
  "orders": [
    {
      "order_id": 10006,
      "order_ts": ISODate("2023-03-02T08:10:00Z"),
      "status": "delivered",
      "total": 129400
    }
  ],
  "metadata": {
    "acquisition_channel": "Affiliate",
    "device_type": "desktop"
  }
}
```

This is radically different from the relational model. A single document can represent what would be 3-4 tables in a relational schema.

### Collections and Databases

- A **document** is the unit of storage (equivalent to a row).
- A **collection** is a group of documents (equivalent to a table, but with no schema enforcement by default).
- A **database** is a group of collections.

MongoDB does not require all documents in a collection to have the same structure. This schema flexibility is the main selling point for rapidly evolving application data.

### The _id Field

Every document must have an `_id` field. If you do not provide one, MongoDB generates an `ObjectId`.

An `ObjectId` is a 12-byte value that encodes:
- 4 bytes: Unix timestamp (seconds)
- 5 bytes: random value (machine + process unique)
- 3 bytes: incrementing counter

This means ObjectIds are sortable by insertion time and globally unique without coordination.

---

## Part 2: CRUD Operations

### Insert

```javascript
// Insert one document
db.customers.insertOne({
  customer_id: 13,
  signup_date: new Date("2023-08-01"),
  country: "India",
  is_premium: false
})

// Insert multiple documents
db.customers.insertMany([
  { customer_id: 14, country: "US" },
  { customer_id: 15, country: "UK" }
])
```

### Find (Read)

```javascript
// Find all
db.customers.find()

// Find with filter
db.customers.find({ country: "India" })

// Find with projection (include specific fields)
db.customers.find(
  { country: "India" },
  { customer_id: 1, signup_date: 1, _id: 0 }
)

// Find with comparison operators
db.customers.find({ customer_id: { $gt: 5 } })

// Find with logical operators
db.customers.find({
  $and: [
    { country: "India" },
    { is_premium: true }
  ]
})

// Find inside nested document
db.customers.find({ "metadata.acquisition_channel": "Organic" })

// Find inside array
db.customers.find({ "orders.status": "delivered" })

// Limit and skip (pagination)
db.customers.find().skip(10).limit(5)

// Sort
db.customers.find().sort({ signup_date: -1 })
```

### Comparison Query Operators

| Operator | SQL Equivalent | Meaning |
|----------|---------------|---------|
| `$eq` | `=` | equal |
| `$ne` | `<>` | not equal |
| `$gt` | `>` | greater than |
| `$gte` | `>=` | greater than or equal |
| `$lt` | `<` | less than |
| `$lte` | `<=` | less than or equal |
| `$in` | `IN (...)` | value in array |
| `$nin` | `NOT IN (...)` | value not in array |
| `$exists` | `IS [NOT] NULL` | field exists |

### Update

```javascript
// Update one (first matching document)
db.customers.updateOne(
  { customer_id: 5 },
  { $set: { is_premium: true } }
)

// Update many
db.customers.updateMany(
  { country: "India" },
  { $set: { currency: "INR" } }
)

// Upsert: insert if not found
db.customers.updateOne(
  { customer_id: 99 },
  { $set: { country: "India", is_premium: false } },
  { upsert: true }
)

// Increment a numeric field
db.customers.updateOne(
  { customer_id: 5 },
  { $inc: { order_count: 1 } }
)

// Add to array
db.customers.updateOne(
  { customer_id: 5 },
  { $push: { tags: "high_value" } }
)

// Add to array without duplicates
db.customers.updateOne(
  { customer_id: 5 },
  { $addToSet: { tags: "high_value" } }
)
```

### Delete

```javascript
// Delete one
db.customers.deleteOne({ customer_id: 99 })

// Delete many
db.customers.deleteMany({ country: "Test" })
```

---

## Part 3: Schema Design

### Embedding vs Referencing

This is the most important design decision in MongoDB. It is the equivalent of normalization in the relational world.

**Embedding** means storing related data inside the same document.

```json
{
  "_id": ObjectId("..."),
  "customer_id": 5,
  "orders": [
    { "order_id": 10006, "status": "delivered", "total": 129400 },
    { "order_id": 10011, "status": "placed", "total": 65000 }
  ]
}
```

**Referencing** means storing a reference (ID) to a document in another collection.

```json
// customers collection
{ "_id": ObjectId("..."), "customer_id": 5, "country": "India" }

// orders collection
{ "_id": ObjectId("..."), "customer_id": 5, "status": "delivered", "total": 129400 }
```

### When to Embed

Embed when:
- The embedded data is always read with the parent (reading a customer always includes their recent orders)
- The relationship is "owns" or "contains" (a blog post owns its comments)
- The embedded data is small and bounded (a few tags, not thousands of order lines)
- The embedded data is not shared between multiple parents

### When to Reference

Reference when:
- Related documents are independently queried (orders are queried by order_id, not always through customers)
- The related collection is large and unbounded (a customer could have 10,000 orders over 20 years)
- The data is shared between multiple parents
- The application needs to update related data frequently and independently

### The Denormalized vs Normalized Spectrum

MongoDB encourages denormalization (embedding) for read performance at the cost of update complexity. This is the opposite of the relational recommendation.

**The golden rule**: model your documents for how you query them, not for theoretical purity.

### Common Schema Patterns

**Pattern 1: Attribute Pattern**

Use when you have many similar key-value pairs that vary by document type. Instead of sparse columns, use an array of attribute objects.

```json
{
  "product_id": 101,
  "name": "Laptop",
  "attributes": [
    { "key": "color", "value": "silver" },
    { "key": "weight_kg", "value": 1.4 },
    { "key": "ram_gb", "value": 16 }
  ]
}
```

**Pattern 2: Bucket Pattern**

Group many fine-grained documents into time-based or size-based buckets. Great for IoT sensors or time-series data.

```json
{
  "sensor_id": "temp-001",
  "date": "2025-01-01",
  "readings": [
    { "ts": ISODate("2025-01-01T00:00:00Z"), "value": 22.3 },
    { "ts": ISODate("2025-01-01T00:01:00Z"), "value": 22.5 }
    // ... 1440 readings for one day
  ],
  "count": 1440,
  "min": 20.1,
  "max": 25.8
}
```

Reduces the number of documents from 1440 per sensor per day to 1. Aggregates are pre-computed.

**Pattern 3: Computed Pattern**

Pre-compute aggregates and store them on the parent document.

```json
{
  "customer_id": 5,
  "order_count": 4,
  "lifetime_value": 229900,
  "last_order_ts": ISODate("2023-06-01T10:00:00Z")
}
```

Updated when new orders are created (`$inc`, `$set` in `updateOne`). Avoids expensive aggregation queries on every read.

**Pattern 4: Subset Pattern**

Store the most-needed subset of related data in the parent document. Keep the full data in a separate collection.

```json
// customer document: only last 10 orders embedded
{
  "customer_id": 5,
  "recent_orders": [
    { "order_id": 10012, "status": "delivered", "total": 37000 }
    // max 10 entries
  ]
}

// full order history in separate collection
```

---

## Part 4: Aggregation Pipeline

The aggregation pipeline is MongoDB's equivalent of SQL's `GROUP BY`, `JOIN`, `HAVING`, window functions, and subqueries combined.

A pipeline is a sequence of stages. Each stage transforms the stream of documents flowing through it.

### Core Pipeline Stages

| Stage | SQL Equivalent | Description |
|-------|---------------|-------------|
| `$match` | `WHERE` | Filter documents |
| `$group` | `GROUP BY` | Aggregate by key |
| `$sort` | `ORDER BY` | Sort documents |
| `$project` | `SELECT` | Reshape documents (include/exclude/compute fields) |
| `$limit` | `LIMIT` | Keep first N documents |
| `$skip` | `OFFSET` | Skip first N documents |
| `$unwind` | (unnest array) | Flatten array into one document per element |
| `$lookup` | `LEFT JOIN` | Join to another collection |
| `$addFields` | computed columns | Add new computed fields |
| `$count` | `COUNT(*)` | Count matching documents |
| `$facet` | multiple aggregations | Run multiple pipelines in parallel |
| `$bucket` | histogram | Group into value ranges |

### Example 1: Orders by Status

```javascript
db.orders.aggregate([
  { $group: {
      _id: "$status",
      order_count: { $sum: 1 },
      total_discount: { $sum: "$discount_amount" }
  }},
  { $sort: { order_count: -1 } }
])
```

Equivalent SQL:
```sql
SELECT status, COUNT(*) AS order_count, SUM(discount_amount) AS total_discount
FROM ecommerce.orders
GROUP BY status
ORDER BY order_count DESC;
```

### Example 2: Monthly Revenue

```javascript
db.orders.aggregate([
  { $match: { status: "delivered" } },
  { $group: {
      _id: {
        year: { $year: "$order_ts" },
        month: { $month: "$order_ts" }
      },
      monthly_orders: { $sum: 1 }
  }},
  { $sort: { "_id.year": 1, "_id.month": 1 } }
])
```

### Example 3: Unwind Array and Aggregate

```javascript
// If each order document embeds its items as an array
db.orders.aggregate([
  { $unwind: "$items" },
  { $group: {
      _id: "$items.product_id",
      total_quantity_sold: { $sum: "$items.quantity" }
  }},
  { $sort: { total_quantity_sold: -1 } },
  { $limit: 10 }
])
```

### Example 4: Lookup (Join)

```javascript
db.orders.aggregate([
  { $lookup: {
      from: "customers",
      localField: "customer_id",
      foreignField: "customer_id",
      as: "customer_info"
  }},
  { $unwind: "$customer_info" },
  { $project: {
      order_id: 1,
      status: 1,
      "customer_info.country": 1
  }}
])
```

### Example 5: Window-Style Running Total

```javascript
db.orders.aggregate([
  { $sort: { order_ts: 1 } },
  { $group: {
      _id: null,
      orders: { $push: { order_id: "$order_id", order_ts: "$order_ts" } }
  }},
  { $unwind: { path: "$orders", includeArrayIndex: "position" } },
  { $addFields: {
      running_count: { $add: ["$position", 1] }
  }}
])
```

Note: MongoDB 5.0+ added `$setWindowFields` which supports proper window functions:

```javascript
db.orders.aggregate([
  { $setWindowFields: {
      partitionBy: "$customer_id",
      sortBy: { order_ts: 1 },
      output: {
        cumulative_order_count: {
          $count: {},
          window: { documents: ["unbounded", "current"] }
        }
      }
  }}
])
```

---

## Part 5: Indexes in MongoDB

### Single Field Index

```javascript
db.customers.createIndex({ customer_id: 1 })  // 1 = ascending, -1 = descending
```

### Compound Index

```javascript
db.orders.createIndex({ customer_id: 1, order_ts: -1 })
// Supports: { customer_id: X } queries
// Supports: { customer_id: X, order_ts: { $lt: Y } } queries
// Does NOT efficiently support: { order_ts: Y } alone
```

The left-prefix rule is the same as in relational databases.

### Text Index (Full-Text Search)

```javascript
db.products.createIndex({ product_name: "text", description: "text" })

// Search
db.products.find({ $text: { $search: "wireless headphones" } })
```

### Multikey Index (Indexes on Arrays)

When you index an array field, MongoDB creates an index entry for each array element. This automatically enables efficient queries like:

```javascript
db.customers.createIndex({ "orders.status": 1 })
db.customers.find({ "orders.status": "delivered" })
```

### Partial Index

```javascript
db.rides.createIndex(
  { requested_ts: 1 },
  { partialFilterExpression: { status: "completed" } }
)
```

### TTL Index (Time-To-Live)

Automatically deletes documents after a specified time. Excellent for sessions, caches, logs.

```javascript
db.sessions.createIndex(
  { created_at: 1 },
  { expireAfterSeconds: 3600 }  // delete documents 1 hour after created_at
)
```

### Covered Query

A query is "covered" by an index when all the fields needed (filter + projection) are in the index. No document fetch required — only the index is read.

```javascript
// Index
db.customers.createIndex({ country: 1, customer_id: 1 })

// This query is covered (country + customer_id in index, only those fields projected)
db.customers.find(
  { country: "India" },
  { customer_id: 1, _id: 0 }
).explain("executionStats")
```

Look for `IXSCAN` + `totalDocsExamined: 0` in the explain output — that means no document fetches.

---

## Part 6: Replication and Sharding in MongoDB

### Replica Sets

A **replica set** is a group of MongoDB nodes that maintain the same data. One node is the **primary** (handles all writes). The others are **secondaries** (replicate from primary, can serve reads).

```
Primary ─── Secondary ─── Secondary (Arbiter)
```

If the primary fails, secondaries hold an election and one becomes the new primary. Downtime is typically seconds.

### Read Preferences

```javascript
// Always read from primary (default - strongly consistent)
db.customers.find().readPref("primary")

// Read from nearest node (eventual consistency, lower latency)
db.customers.find().readPref("nearest")

// Read from secondaries (eventual consistency, read scaling)
db.customers.find().readPref("secondary")
```

### Sharding

For data that exceeds one machine's capacity. MongoDB supports:

**Hashed sharding**: hash(shard_key) distributes evenly.
```javascript
sh.shardCollection("ecommerce.orders", { customer_id: "hashed" })
```

**Range sharding**: value ranges map to specific shards.
```javascript
sh.shardCollection("ecommerce.orders", { order_ts: 1 })
```

The **shard key** choice is critical and permanent (very hard to change after the fact). Choose a key with high cardinality, even distribution, and alignment with query patterns.

---

## Part 7: Transactions in MongoDB

MongoDB 4.0+ supports multi-document ACID transactions within a replica set. MongoDB 4.2+ supports multi-document transactions across shards.

```javascript
const session = db.getMongo().startSession();
session.startTransaction();

try {
  db.accounts.updateOne(
    { account_id: "A" },
    { $inc: { balance: -100 } },
    { session }
  );
  db.accounts.updateOne(
    { account_id: "B" },
    { $inc: { balance: 100 } },
    { session }
  );
  session.commitTransaction();
} catch (error) {
  session.abortTransaction();
  throw error;
} finally {
  session.endSession();
}
```

Note: transactions in MongoDB carry overhead and should be used only when truly needed. If you are relying on transactions extensively, the relational model may be a better fit.

---

## Part 8: MongoDB vs PostgreSQL — When To Choose What

| Dimension | MongoDB | PostgreSQL |
|-----------|---------|-----------|
| Schema | Flexible, per-document | Rigid, enforced |
| Relationships | Embedding + manual lookups | Native joins |
| Transactions | Supported but expensive | Native, efficient |
| Query power | Strong aggregations, weaker ad-hoc | Full SQL + window functions |
| Full-text search | Built-in text index | Full-text + pg_trgm |
| JSON/document | Native BSON | JSONB (excellent) |
| Scaling | Designed for horizontal | Vertical + logical replication |
| Analytics | Good with aggregation pipeline | Better for complex SQL |
| Schema evolution | Easy (add fields to documents) | Managed migrations |

**Choose MongoDB when**:
- Your data is document-shaped and embedded structures naturally match query patterns
- Schema is evolving rapidly (early-stage product)
- Write throughput is very high and horizontal scaling is required
- Data is semi-structured or variable-structure

**Choose PostgreSQL when**:
- Data is well-structured with clear relationships
- You need complex joins, window functions, and ad-hoc SQL
- ACID guarantees are critical
- You want a single database that handles both OLTP and light analytics
- Your team knows SQL well

**The real answer** in most MAANG systems: both. MongoDB or DynamoDB serves the application layer (user-facing reads/writes). PostgreSQL or a warehouse like BigQuery/Snowflake serves analytics. A data pipeline moves data from the former to the latter.

---

## Part 9: Interview Lens

Questions you should be able to answer cold:

**Design questions**:
- "When would you embed vs reference in MongoDB?"
- "Design a MongoDB schema for a social network feed."
- "How would you handle schema migrations in MongoDB?"

**Performance questions**:
- "What is a covered query?"
- "What does a compound index on (country, signup_date) support? What doesn't it support?"
- "What is the bucket pattern and when do you use it?"

**Consistency questions**:
- "What is eventual consistency? When is it acceptable?"
- "How do read preferences affect consistency in a replica set?"
- "Why are MongoDB transactions more expensive than single-document operations?"

**Comparison questions**:
- "Why use MongoDB instead of PostgreSQL's JSONB?"
- "What is the main trade-off of MongoDB's flexible schema?"

The honest answer to the last question: flexible schemas shift data quality enforcement from the database to application code. This is not automatically good. It means bugs in application code can insert malformed documents with no defense, whereas a relational constraint would have rejected them.
