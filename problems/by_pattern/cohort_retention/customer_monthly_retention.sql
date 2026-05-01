-- Pattern: cohort retention
-- Prompt: build a monthly retention table by signup cohort.

WITH signup_cohort AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', signup_date)::date AS cohort_month
    FROM ecommerce.customers
),
activity_month AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_ts)::date AS active_month
    FROM ecommerce.orders
),
cohort_activity AS (
    SELECT
        s.customer_id,
        s.cohort_month,
        a.active_month,
        ((EXTRACT(YEAR FROM age(a.active_month, s.cohort_month)) * 12)
          + EXTRACT(MONTH FROM age(a.active_month, s.cohort_month)))::integer AS month_number
    FROM signup_cohort AS s
    JOIN activity_month AS a
        ON s.customer_id = a.customer_id
)
SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_id) AS retained_customers
FROM cohort_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;
