-- Week 11 examples: transaction and production-style concepts.

BEGIN;

SELECT *
FROM ecommerce.orders
WHERE order_id = 10002
FOR UPDATE;

COMMIT;

CREATE MATERIALIZED VIEW IF NOT EXISTS ecommerce.monthly_order_counts AS
SELECT
    DATE_TRUNC('month', order_ts)::date AS month_start,
    COUNT(*) AS order_count
FROM ecommerce.orders
GROUP BY 1;

REFRESH MATERIALIZED VIEW ecommerce.monthly_order_counts;
