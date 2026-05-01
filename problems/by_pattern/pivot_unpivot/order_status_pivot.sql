-- Pattern: pivot
-- Prompt: pivot order statuses into columns by payment method.

SELECT
    payment_method,
    COUNT(*) FILTER (WHERE status = 'placed') AS placed_orders,
    COUNT(*) FILTER (WHERE status = 'shipped') AS shipped_orders,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_orders,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders,
    COUNT(*) FILTER (WHERE status = 'refunded') AS refunded_orders
FROM ecommerce.orders
GROUP BY payment_method
ORDER BY payment_method;
