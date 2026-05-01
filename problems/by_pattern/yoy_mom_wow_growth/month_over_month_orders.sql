-- Pattern: period-over-period growth
-- Prompt: compute month-over-month order growth.

WITH monthly_orders AS (
    SELECT
        DATE_TRUNC('month', order_ts)::date AS month_start,
        COUNT(*) AS monthly_orders
    FROM ecommerce.orders
    GROUP BY month_start
)
SELECT
    month_start,
    monthly_orders,
    LAG(monthly_orders) OVER (ORDER BY month_start) AS previous_month_orders,
    ROUND(
        100.0 * (monthly_orders - LAG(monthly_orders) OVER (ORDER BY month_start))
        / NULLIF(LAG(monthly_orders) OVER (ORDER BY month_start), 0),
        2
    ) AS mom_growth_pct
FROM monthly_orders
ORDER BY month_start;
