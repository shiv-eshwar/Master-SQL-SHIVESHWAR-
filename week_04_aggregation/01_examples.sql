-- Week 4 examples: basic aggregation and FILTER.

SELECT
    department_id,
    COUNT(*) AS employee_count,
    AVG(base_salary) AS avg_salary
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

SELECT
    status,
    COUNT(*) AS order_count,
    SUM(discount_amount) AS total_discount
FROM ecommerce.orders
GROUP BY status;

SELECT
    customer_id,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_orders,
    COUNT(*) FILTER (WHERE status IN ('cancelled', 'refunded')) AS unsuccessful_orders
FROM ecommerce.orders
GROUP BY customer_id
ORDER BY customer_id;
