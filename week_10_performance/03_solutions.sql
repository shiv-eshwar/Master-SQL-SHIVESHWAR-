-- Week 10 reference solutions

CREATE INDEX IF NOT EXISTS idx_orders_customer_latest
ON ecommerce.orders (customer_id, order_ts DESC);

CREATE INDEX IF NOT EXISTS idx_completed_rides_requested_ts
ON rideshare.rides (requested_ts)
WHERE status = 'completed';

EXPLAIN ANALYZE
SELECT *
FROM ecommerce.orders
WHERE customer_id = 2
ORDER BY order_ts DESC
LIMIT 1;

EXPLAIN ANALYZE
SELECT *
FROM ecommerce.orders
WHERE order_ts >= TIMESTAMPTZ '2023-03-01 00:00:00+05:30'
  AND order_ts < TIMESTAMPTZ '2023-04-01 00:00:00+05:30';
