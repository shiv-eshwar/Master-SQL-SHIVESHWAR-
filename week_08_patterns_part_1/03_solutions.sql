-- Week 8 reference solutions

WITH ranked_employees AS (
    SELECT
        employee_id,
        full_name,
        department_id,
        base_salary,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY base_salary DESC
        ) AS rn
    FROM hr.employees
)
SELECT *
FROM ranked_employees
WHERE rn <= 2;

WITH monthly_orders AS (
    SELECT
        DATE_TRUNC('month', order_ts)::date AS month_start,
        COUNT(*) AS monthly_orders
    FROM ecommerce.orders
    GROUP BY 1
)
SELECT
    month_start,
    monthly_orders,
    LAG(monthly_orders) OVER (ORDER BY month_start) AS prior_month_orders,
    ROUND(
        100.0 * (monthly_orders - LAG(monthly_orders) OVER (ORDER BY month_start))
        / NULLIF(LAG(monthly_orders) OVER (ORDER BY month_start), 0),
        2
    ) AS mom_growth_pct
FROM monthly_orders;

SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY actual_fare) AS median_completed_fare
FROM rideshare.rides
WHERE status = 'completed';
