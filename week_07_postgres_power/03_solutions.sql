-- Week 7 reference solutions

SELECT
    DATE_TRUNC('month', order_ts)::date AS month_start,
    COUNT(*) AS order_count
FROM ecommerce.orders
GROUP BY 1
ORDER BY 1;

SELECT
    ride_id,
    ROUND(EXTRACT(EPOCH FROM (completed_ts - pickup_ts)) / 60.0, 2) AS ride_minutes
FROM rideshare.rides
WHERE completed_ts IS NOT NULL
  AND pickup_ts IS NOT NULL;

SELECT *
FROM generate_series(DATE '2025-01-01', DATE '2025-01-31', INTERVAL '1 day') AS g(day_value);

SELECT
    employee_id,
    jsonb_build_object(
        'employee_id', employee_id,
        'full_name', full_name,
        'department_id', department_id
    ) AS employee_json
FROM hr.employees;

SELECT
    order_id,
    ARRAY_AGG(product_id ORDER BY line_number) AS ordered_product_ids
FROM ecommerce.order_items
GROUP BY order_id;
