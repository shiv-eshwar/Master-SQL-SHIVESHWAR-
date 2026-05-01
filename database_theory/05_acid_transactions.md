# Chapter 5: ACID, Transactions, and Concurrency

## What Is a Transaction?

A **transaction** is a sequence of operations that the database treats as a single indivisible unit of work.

The classic example: transferring money between two bank accounts. You debit account A and credit account B. Both operations must succeed together, or neither should take effect. A world where the debit succeeds but the credit fails — money vanishes — is worse than if neither happened.

Transactions give you the power to say: "These operations are logically one thing."

## ACID: The Four Guarantees

ACID is an acronym for the four properties a transaction must satisfy to guarantee correctness, even in the presence of hardware failures and concurrent users.

### A — Atomicity

**"All or nothing."**

If any operation in a transaction fails, the entire transaction is rolled back. The database returns to the state it was in before the transaction began. No partial results persist.

Implementation: the database writes changes to a **write-ahead log (WAL)** before applying them to data pages. On crash, the recovery manager replays committed transactions and rolls back incomplete ones.

### C — Consistency

**"The database moves from one valid state to another valid state."**

Every transaction must leave the database satisfying all declared constraints: primary keys, foreign keys, check constraints, unique constraints, and any application-level business rules enforced at the database level.

Important note: consistency is largely the application's responsibility. The database enforces the constraints you define, but it cannot enforce business rules you forgot to declare.

### I — Isolation

**"Concurrent transactions see each other as if they ran serially."**

This is the hardest property to achieve without sacrificing performance. The database must ensure that one transaction's in-progress changes are not visible to other transactions in ways that could produce incorrect results.

Full isolation (serializability) is expensive. Most databases allow configurable weaker isolation levels for better performance.

### D — Durability

**"Committed transactions survive crashes."**

Once the database returns "commit successful," the data is permanently written to storage. Even a system crash immediately after the commit cannot undo it.

Implementation: the WAL ensures committed data is on disk before acknowledging the commit to the client. On restart after a crash, the recovery manager replays the WAL.

## Concurrency Anomalies

When isolation is weakened, anomalies become possible. Understanding these is essential for choosing the right isolation level.

### Dirty Read

Transaction A reads data that Transaction B has modified but not yet committed. If B rolls back, A has read data that never officially existed.

```
T1: UPDATE salary SET amount = 999999 WHERE employee_id = 7;
T2: SELECT amount FROM salary WHERE employee_id = 7;  -- reads 999999
T1: ROLLBACK;
-- T2 used a value that was never committed
```

### Non-Repeatable Read

Transaction A reads a row. Transaction B updates and commits that row. Transaction A reads the same row again within the same transaction and gets a different value.

```
T1: SELECT salary FROM employees WHERE employee_id = 7;  -- returns 190000
T2: UPDATE employees SET salary = 200000 WHERE employee_id = 7; COMMIT;
T1: SELECT salary FROM employees WHERE employee_id = 7;  -- returns 200000
-- T1 got two different values for the same row in the same transaction
```

### Phantom Read

Transaction A executes a query that returns a set of rows. Transaction B inserts new rows matching A's query condition and commits. Transaction A re-executes the same query and gets different (more) rows.

```
T1: SELECT * FROM orders WHERE customer_id = 5;  -- 2 rows
T2: INSERT INTO orders (...) VALUES (5, ...); COMMIT;
T1: SELECT * FROM orders WHERE customer_id = 5;  -- 3 rows
-- New "phantom" row appeared
```

### Lost Update

Two transactions read a value, both modify it, and both write back. One transaction's update overwrites the other's.

```
T1: reads balance = 1000
T2: reads balance = 1000
T1: writes balance = 900  (deducted 100)
T2: writes balance = 800  (deducted 200 from original 1000)
-- Result: 800, not 700. T1's update was lost.
```

## Isolation Levels

SQL defines four standard isolation levels. Each prevents a specific set of anomalies.

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read |
|----------------|-----------|---------------------|--------------|
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | Prevented | Possible | Possible |
| REPEATABLE READ | Prevented | Prevented | Possible (in theory) |
| SERIALIZABLE | Prevented | Prevented | Prevented |

**READ UNCOMMITTED**: almost never used in practice. Reads dirty data.

**READ COMMITTED**: the PostgreSQL default. Each statement sees only rows committed before that statement began. Common in web applications where strict consistency between statements in one request is not required.

**REPEATABLE READ**: a transaction sees a stable snapshot of data as it existed when the transaction began. In PostgreSQL, the MVCC implementation means phantom reads are also prevented at this level (better than the SQL standard requires).

**SERIALIZABLE**: the strongest level. Transactions execute as if they were running one at a time. PostgreSQL uses Serializable Snapshot Isolation (SSI) — a MVCC-based technique that is more concurrent than traditional locking-based serializability.

Setting in PostgreSQL:

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- your queries here
COMMIT;
```

## How PostgreSQL Implements Isolation: MVCC

PostgreSQL uses **Multi-Version Concurrency Control (MVCC)** rather than read-write locking.

The idea:

- Every row has hidden `xmin` (the transaction ID that created it) and `xmax` (the transaction ID that deleted or updated it).
- When you update a row, PostgreSQL does not modify the existing row. It marks the old row as deleted (`xmax` set) and creates a new row version.
- Each transaction sees rows based on a **snapshot** of which transactions were committed at the time the snapshot was taken.
- Readers never block writers. Writers never block readers.

This is why PostgreSQL performs well under read-heavy mixed workloads.

**Dead tuples and VACUUM**: old row versions accumulate. The `VACUUM` process cleans up row versions that no active transaction can see anymore. `autovacuum` runs this automatically, but understanding it matters for high-write tables.

## Locking

Even with MVCC, some operations require explicit locking.

**Row-level locks**:

- `SELECT ... FOR UPDATE`: locks selected rows against concurrent updates or deletes. Use when you read a value with intent to update it (prevents lost update anomaly).
- `SELECT ... FOR SHARE`: allows other readers to also lock for share, but blocks updates.
- `SELECT ... SKIP LOCKED`: skip rows already locked by other transactions. Excellent for job queues where multiple workers race to claim next task.

**Table-level locks**: DDL operations like `ALTER TABLE` acquire table-level locks. In production, use `ALTER TABLE ... CONCURRENTLY` variants where possible.

**Deadlocks**: two transactions each wait for a lock held by the other. PostgreSQL detects these and kills one transaction. Design transaction order consistently to avoid them.

## The Two-Phase Locking (2PL) Protocol

An alternative to MVCC used by some databases. Two rules:

1. **Growing phase**: a transaction may acquire locks but not release any.
2. **Shrinking phase**: a transaction may release locks but not acquire any.

This guarantees serializability but means that readers block writers and vice versa. High contention under mixed workloads.

PostgreSQL uses 2PL only for DDL and explicit `LOCK TABLE` commands. For DML, it uses MVCC.

## Savepoints

Within a transaction, you can set checkpoints:

```sql
BEGIN;
INSERT INTO orders VALUES (...);
SAVEPOINT before_items;
INSERT INTO order_items VALUES (...);
-- if this fails:
ROLLBACK TO SAVEPOINT before_items;
-- then try again or handle the error
COMMIT;
```

Savepoints allow partial rollback without aborting the whole transaction.

## Interview Lens

ACID questions appear constantly:

- "What is the difference between atomicity and consistency?"
- "Why would you use REPEATABLE READ instead of READ COMMITTED?"
- "How does MVCC work? What is a dead tuple?"
- "What is a dirty read? Give a business example."
- "When would you use SELECT FOR UPDATE?"
- "How do you prevent a lost update in a high-concurrency account system?"

The answer to "what isolation level should I use?" is almost always:

1. Use READ COMMITTED by default for OLTP.
2. Use REPEATABLE READ when a transaction needs a stable snapshot (e.g., a report that reads multiple tables and must see consistent data).
3. Use SERIALIZABLE for financial or inventory systems where correctness is non-negotiable and conflicts are acceptable.
