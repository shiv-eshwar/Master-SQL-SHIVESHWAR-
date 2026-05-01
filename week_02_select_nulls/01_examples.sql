-- Week 2 examples: filtering order and NULL handling.

SELECT
    employee_id,
    full_name,
    manager_id,
    COALESCE(manager_id, -1) AS manager_id_filled
FROM hr.employees;

SELECT
    order_id,
    status,
    CASE
        WHEN status IN ('cancelled', 'refunded') THEN 'not_kept'
        ELSE 'kept'
    END AS order_bucket
FROM ecommerce.orders;

SELECT DISTINCT ON (customer_id)
    customer_id,
    order_id,
    order_ts
FROM ecommerce.orders
ORDER BY customer_id, order_ts DESC;

SELECT
    employee_id,
    employment_status,
    employment_status IS DISTINCT FROM 'terminated' AS keep_row
FROM hr.employees;
