-- Week 3 examples: core joins, anti-joins, and LATERAL.

SELECT
    e.employee_id,
    e.full_name,
    d.department_name
FROM hr.employees AS e
JOIN hr.departments AS d
    ON e.department_id = d.department_id;

SELECT
    e.full_name AS employee_name,
    m.full_name AS manager_name
FROM hr.employees AS e
LEFT JOIN hr.employees AS m
    ON e.manager_id = m.employee_id;

SELECT c.customer_id
FROM ecommerce.customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM ecommerce.orders AS o
    WHERE o.customer_id = c.customer_id
);

SELECT
    c.customer_id,
    latest_order.order_id,
    latest_order.order_ts
FROM ecommerce.customers AS c
LEFT JOIN LATERAL (
    SELECT o.order_id, o.order_ts
    FROM ecommerce.orders AS o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_ts DESC
    LIMIT 1
) AS latest_order
    ON true;
