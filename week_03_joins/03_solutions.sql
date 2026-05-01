-- Week 3 reference solutions

SELECT
    e.full_name,
    d.department_name,
    d.location
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

SELECT p.product_id, p.product_name
FROM ecommerce.products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM ecommerce.order_items AS oi
    WHERE oi.product_id = p.product_id
);

SELECT
    c.customer_id,
    lo.order_id,
    lo.order_ts
FROM ecommerce.customers AS c
LEFT JOIN LATERAL (
    SELECT o.order_id, o.order_ts
    FROM ecommerce.orders AS o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_ts DESC
    LIMIT 1
) AS lo
    ON true;
