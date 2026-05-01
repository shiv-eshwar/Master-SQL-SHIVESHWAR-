-- Week 8 examples: top-N, running totals, growth, percentiles.

WITH ranked_products AS (
    SELECT
        p.category,
        p.product_name,
        p.unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY p.unit_price DESC
        ) AS rn
    FROM ecommerce.products AS p
)
SELECT *
FROM ranked_products
WHERE rn <= 2;

SELECT
    DATE_TRUNC('month', order_ts)::date AS month_start,
    COUNT(*) AS monthly_orders,
    LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', order_ts)) AS prior_month_orders
FROM ecommerce.orders
GROUP BY 1
ORDER BY 1;
