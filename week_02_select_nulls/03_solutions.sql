-- Week 2 reference solutions

SELECT employee_id, full_name
FROM hr.employees
WHERE manager_id IS NULL;

SELECT
    order_id,
    status,
    CASE
        WHEN status IN ('delivered', 'shipped', 'placed') THEN 'successful_or_open'
        ELSE 'unsuccessful'
    END AS order_bucket
FROM ecommerce.orders;

SELECT DISTINCT ON (customer_id)
    customer_id,
    order_id,
    order_ts
FROM ecommerce.orders
ORDER BY customer_id, order_ts DESC;

WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_ts,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_ts DESC) AS rn
    FROM ecommerce.orders
)
SELECT customer_id, order_id, order_ts
FROM ranked_orders
WHERE rn = 1;

SELECT 10 / NULLIF(denominator, 0) AS safe_division
FROM (VALUES (2), (0)) AS v(denominator);

SELECT employee_id, full_name
FROM hr.employees
WHERE employment_status IS DISTINCT FROM 'terminated';
