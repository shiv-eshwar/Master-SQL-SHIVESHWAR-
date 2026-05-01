-- Week 11 reference solutions

CREATE MATERIALIZED VIEW IF NOT EXISTS rideshare.monthly_completed_ride_revenue AS
SELECT
    DATE_TRUNC('month', requested_ts)::date AS month_start,
    SUM(actual_fare) AS gross_revenue
FROM rideshare.rides
WHERE status = 'completed'
GROUP BY 1;

REFRESH MATERIALIZED VIEW rideshare.monthly_completed_ride_revenue;

-- READ COMMITTED:
-- Each statement sees rows committed before that statement begins.
--
-- REPEATABLE READ:
-- A transaction keeps a stable snapshot for its lifetime.
--
-- SKIP LOCKED:
-- Useful for worker queues where you want the next unlocked job without waiting.
