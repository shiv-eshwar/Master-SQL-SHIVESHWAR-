# Chapter 8: Distributed Databases

## Why Single-Node Databases Have Limits

A single PostgreSQL server is sufficient for most applications. But when:
- data volume exceeds one machine's disk
- write throughput exceeds one machine's I/O bandwidth
- read throughput requires more than one machine can serve
- geographic distribution requires low-latency access from multiple regions

...you need distributed database patterns.

Understanding distributed systems is a senior-level expectation in data engineering and data science roles.

## Replication

**Replication** is copying data from one database node (the primary) to one or more other nodes (replicas/standbys).

### Why Replicate?

1. **High availability**: if the primary fails, promote a replica. Downtime is seconds rather than hours.
2. **Read scaling**: route read queries to replicas so the primary handles only writes.
3. **Disaster recovery**: replicas in different data centers survive regional outages.
4. **Analytics isolation**: run heavy analytical queries on a replica without affecting the primary.

### Synchronous vs Asynchronous Replication

**Asynchronous replication**: the primary commits and returns success before the replica has acknowledged. The replica may lag behind. If the primary crashes, the replica may be slightly behind — some committed data may be lost.

This is the PostgreSQL default. The lag is usually milliseconds but can grow under write pressure.

**Synchronous replication**: the primary waits for the replica to confirm it has written the WAL before acknowledging the commit to the client. No data loss, but every write has added latency equal to the round-trip to the replica.

```sql
-- In postgresql.conf:
synchronous_standby_names = 'replica1'
synchronous_commit = on
```

### Logical vs Physical Replication

**Physical (streaming) replication**: replays the binary WAL stream. Replicas are byte-for-byte copies of the primary. Cannot replicate to a different PostgreSQL version or replicate a subset of tables.

**Logical replication**: decodes WAL changes into row-level events (INSERT, UPDATE, DELETE). Allows replicating specific tables, replicating to different PostgreSQL versions, and replicating to non-PostgreSQL targets.

## Sharding

**Sharding** is partitioning data horizontally across multiple independent database nodes, each owning a subset of rows.

### Why Shard?

When data volume or write throughput exceeds what one node can handle and cannot be solved by replication (which duplicates all data on every node).

### Sharding Strategies

**Range sharding**: rows are distributed by value range. All orders with `order_id` 1–1M on shard 1, 1M–2M on shard 2, etc.

Pros: range queries on the shard key stay on one shard.
Cons: uneven distribution if data is skewed. New records always go to the last shard (hotspot).

**Hash sharding**: rows are distributed by `hash(shard_key) % num_shards`.

Pros: even distribution, no hotspot.
Cons: range queries require all shards. Adding shards requires resharding (remapping all data).

**Consistent hashing**: a more sophisticated version of hash sharding that minimizes data movement when shards are added or removed. Used by Cassandra, DynamoDB.

The virtual ring idea: imagine all shard keys mapped onto a circle. Each shard node owns a range of the ring. Adding a new node only steals keys from its neighbors, not from all nodes.

### Cross-Shard Joins

The fundamental problem with sharding: joins across shards require network communication. This is extremely expensive.

Design principle: shard on the attribute you most commonly join on. For an e-commerce system that mostly joins orders to order_items, shard both tables on `customer_id` so a customer's data lives on the same shard.

### Local vs Distributed Transactions

A transaction touching one shard is a local transaction — fast and ACID as usual.

A transaction touching multiple shards is a **distributed transaction** — much harder to implement correctly.

## The CAP Theorem

Formulated by Eric Brewer in 2000, the CAP theorem states that a distributed system can guarantee at most two of:

**C — Consistency**: every read sees the most recent write (or an error, not stale data).

**A — Availability**: every request receives a non-error response (though not necessarily the most recent write).

**P — Partition Tolerance**: the system continues operating even when network partitions prevent some nodes from communicating.

In a real network, partitions can and do happen. So P is effectively mandatory. The real choice is between C and A during a partition:

- **CP systems** (consistency + partition tolerance): during a partition, some nodes will refuse to serve reads to avoid returning stale data. Examples: HBase, Zookeeper, etcd, PAXOS-based systems.

- **AP systems** (availability + partition tolerance): during a partition, all nodes continue serving requests, but some reads may return stale data. Examples: Cassandra, CouchDB, Riak.

**Important nuance**: CAP is about behavior during a partition event, which is rare. Most of the time, systems can provide both consistency and availability. The interesting question is what happens when the network fails.

## PACELC: A More Complete Model

The CAP theorem only describes partition scenarios. PACELC (pronounced "pass-elk") extends it:

"If there is a Partition, trade-off between Availability and Consistency. Else (when there is no partition), trade-off between Latency and Consistency."

This is more useful for day-to-day system design:
- A system configured for strong consistency will have higher latency because writes must be confirmed by multiple nodes
- A system configured for low latency will offer weaker consistency (reads may lag behind writes)

## Eventual Consistency

In AP systems, writes propagate asynchronously to all nodes. During the propagation window, different nodes may return different values for the same key.

Eventually (when no new writes occur and propagation completes), all nodes converge to the same value. This is **eventual consistency**.

Applications built on eventually consistent systems must tolerate:
- Reading stale data
- Conflicting concurrent writes (resolved by last-write-wins, vector clocks, or application-level conflict resolution)

Not suitable for: financial transactions, inventory with hard limits, anything where correctness requires seeing the absolute latest state.

Suitable for: social media feeds, user preferences, shopping cart contents, analytics counters where approximate is fine.

## Distributed Transactions

When a transaction must span multiple nodes (shards or independent services), you need a distributed commit protocol.

### Two-Phase Commit (2PC)

```
Phase 1 (Prepare):
  Coordinator asks all participants: "Can you commit?"
  Each participant: acquires locks, writes to WAL, replies YES or NO

Phase 2 (Commit or Abort):
  If all said YES: coordinator sends COMMIT to all
  If any said NO: coordinator sends ABORT to all
```

Problem: if the coordinator crashes between Phase 1 and Phase 2, participants are stuck holding locks indefinitely (the "blocking" problem). 2PC is reliable but not fault-tolerant by itself.

Used by: PostgreSQL's `PREPARE TRANSACTION`, distributed SQL systems like CockroachDB, YugabyteDB.

### Saga Pattern

An alternative for microservices: break a distributed transaction into a sequence of local transactions, each with a corresponding **compensating transaction** that undoes it if a later step fails.

```
1. Reserve inventory   → compensating: release inventory
2. Charge payment      → compensating: refund payment
3. Create shipment     → compensating: cancel shipment
```

If step 3 fails, execute compensations for steps 2 and 1 in reverse order.

Sagas provide eventual consistency, not full ACID isolation. They are widely used in microservices architectures where cross-service 2PC is impractical.

## Read Your Writes: A Common Eventual Consistency Bug

User writes a comment. The write goes to the primary. The user immediately reads their profile — the read routes to a replica that has not yet received the write. The user sees their comment missing.

Fix strategies:
- Route reads for the same user to the primary for a short window after a write
- Use sticky sessions to pin a user to a replica that has their data
- Use synchronous replication for user-facing writes

## Interview Lens

Distributed database questions at senior DS/DE level:

- "What is the CAP theorem?" → describe C, A, P, and the real choice between C and A under partition
- "When would you use Cassandra vs PostgreSQL?" → AP vs CP, eventual vs strong consistency, write-heavy vs complex-query workloads
- "What is sharding? What are the downsides?" → horizontal partition, cross-shard joins, hotspot risk
- "How does consistent hashing work?" → ring, virtual nodes, minimal resharding on scale
- "What is a saga pattern?" → distributed transaction via local transactions + compensating transactions
- "How does your team ensure data consistency across microservices?" → 2PC, saga, outbox pattern
