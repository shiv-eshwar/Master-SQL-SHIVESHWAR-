-- Pattern: funnel
-- Prompt: count customers at each ecommerce funnel stage.

WITH page_view AS (
    SELECT DISTINCT customer_id
    FROM ecommerce.events
    WHERE event_name = 'page_view'
),
add_to_cart AS (
    SELECT DISTINCT customer_id
    FROM ecommerce.events
    WHERE event_name = 'add_to_cart'
),
purchase AS (
    SELECT DISTINCT customer_id
    FROM ecommerce.events
    WHERE event_name = 'purchase'
)
SELECT 'page_view' AS stage, COUNT(*) AS users_at_stage FROM page_view
UNION ALL
SELECT 'add_to_cart' AS stage, COUNT(*) AS users_at_stage FROM add_to_cart
UNION ALL
SELECT 'purchase' AS stage, COUNT(*) AS users_at_stage FROM purchase;
