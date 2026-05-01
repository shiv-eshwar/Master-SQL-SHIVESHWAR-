-- Pattern: anti-join and dedup
-- Prompt: find customers who have never placed an order.

SELECT c.customer_id
FROM ecommerce.customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM ecommerce.orders AS o
    WHERE o.customer_id = c.customer_id
);

-- Dedup variant: keep latest ride per rider.
WITH ranked_rides AS (
    SELECT
        rider_id,
        ride_id,
        requested_ts,
        ROW_NUMBER() OVER (
            PARTITION BY rider_id
            ORDER BY requested_ts DESC
        ) AS rn
    FROM rideshare.rides
)
SELECT rider_id, ride_id, requested_ts
FROM ranked_rides
WHERE rn = 1;
