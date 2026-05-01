-- Pattern: running totals
-- Prompt: compute cumulative monthly order revenue.

WITH order_revenue AS (
    SELECT
        o.order_id,
        DATE_TRUNC('month', o.order_ts)::date AS month_start,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) - o.discount_amount + o.shipping_fee AS order_revenue
    FROM ecommerce.orders AS o
    LEFT JOIN ecommerce.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, month_start, o.discount_amount, o.shipping_fee
),
monthly AS (
    SELECT month_start, SUM(order_revenue) AS monthly_revenue
    FROM order_revenue
    GROUP BY month_start
)
SELECT
    month_start,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM monthly
ORDER BY month_start;
