-- Week 12 examples: one problem, multiple solution styles.

-- Problem: latest order per customer

WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_ts,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_ts DESC
        ) AS rn
    FROM ecommerce.orders
)
SELECT customer_id, order_id, order_ts
FROM ranked_orders
WHERE rn = 1;

SELECT DISTINCT ON (customer_id)
    customer_id,
    order_id,
    order_ts
FROM ecommerce.orders
ORDER BY customer_id, order_ts DESC;
