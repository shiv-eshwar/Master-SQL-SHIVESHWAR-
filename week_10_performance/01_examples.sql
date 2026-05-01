-- Week 10 examples: indexes and EXPLAIN.

CREATE INDEX IF NOT EXISTS idx_orders_customer_ts
ON ecommerce.orders (customer_id, order_ts DESC);

CREATE INDEX IF NOT EXISTS idx_rides_completed_only
ON rideshare.rides (requested_ts)
WHERE status = 'completed';

EXPLAIN ANALYZE
SELECT *
FROM ecommerce.orders
WHERE customer_id = 10
ORDER BY order_ts DESC
LIMIT 1;

EXPLAIN ANALYZE
SELECT *
FROM rideshare.rides
WHERE status = 'completed'
  AND requested_ts >= TIMESTAMPTZ '2023-03-01 00:00:00+05:30';
