-- Week 9 reference solutions

WITH ordered_events AS (
    SELECT
        rider_id,
        event_ts,
        CASE
            WHEN event_ts - LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) > INTERVAL '30 minutes'
              OR LAG(event_ts) OVER (PARTITION BY rider_id ORDER BY event_ts) IS NULL
            THEN 1 ELSE 0
        END AS is_new_session
    FROM rideshare.app_events
),
sessionized AS (
    SELECT
        rider_id,
        event_ts,
        SUM(is_new_session) OVER (
            PARTITION BY rider_id
            ORDER BY event_ts
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS session_number
    FROM ordered_events
)
SELECT rider_id, session_number, MIN(event_ts) AS session_start, MAX(event_ts) AS session_end
FROM sessionized
GROUP BY rider_id, session_number
ORDER BY rider_id, session_number;

WITH signup_cohort AS (
    SELECT customer_id, DATE_TRUNC('month', signup_date)::date AS cohort_month
    FROM ecommerce.customers
),
order_months AS (
    SELECT DISTINCT customer_id, DATE_TRUNC('month', order_ts)::date AS active_month
    FROM ecommerce.orders
)
SELECT
    s.cohort_month,
    ((EXTRACT(YEAR FROM age(o.active_month, s.cohort_month)) * 12)
      + EXTRACT(MONTH FROM age(o.active_month, s.cohort_month)))::integer AS month_number,
    COUNT(DISTINCT s.customer_id) AS retained_customers
FROM signup_cohort AS s
JOIN order_months AS o
    ON s.customer_id = o.customer_id
GROUP BY s.cohort_month, month_number
ORDER BY s.cohort_month, month_number;
