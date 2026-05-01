-- Week 6 examples: ranking, lag, and running totals.

SELECT
    employee_id,
    department_id,
    base_salary,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY base_salary DESC
    ) AS salary_rank_in_department
FROM hr.employees;

SELECT
    order_id,
    customer_id,
    order_ts,
    LAG(order_ts) OVER (
        PARTITION BY customer_id
        ORDER BY order_ts
    ) AS previous_order_ts
FROM ecommerce.orders;

SELECT
    order_id,
    customer_id,
    order_ts::date AS order_date,
    COUNT(*) OVER (
        PARTITION BY customer_id
        ORDER BY order_ts
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_orders
FROM ecommerce.orders;
