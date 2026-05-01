-- Week 6 reference solutions

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

WITH ordered_rides AS (
    SELECT
        rider_id,
        ride_id,
        actual_fare,
        LAG(actual_fare) OVER (
            PARTITION BY rider_id
            ORDER BY requested_ts
        ) AS previous_fare
    FROM rideshare.rides
)
SELECT *
FROM ordered_rides;

SELECT
    DATE_TRUNC('month', order_ts)::date AS month_start,
    SUM(
        SUM(
            (SELECT COALESCE(SUM(quantity * unit_price), 0)
             FROM ecommerce.order_items AS oi
             WHERE oi.order_id = o.order_id)
            - discount_amount + shipping_fee
        )
    ) OVER (
        ORDER BY DATE_TRUNC('month', order_ts)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM ecommerce.orders AS o
GROUP BY DATE_TRUNC('month', order_ts)
ORDER BY month_start;
