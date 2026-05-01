# E-commerce ERD

## Grain

- `ecommerce.customers`: one row per customer
- `ecommerce.products`: one row per product
- `ecommerce.orders`: one row per order
- `ecommerce.order_items`: one row per order line
- `ecommerce.events`: one row per customer event

## Relationships

- `orders.customer_id -> customers.customer_id`
- `order_items.order_id -> orders.order_id`
- `order_items.product_id -> products.product_id`
- `events.customer_id -> customers.customer_id`
- `events.order_id -> orders.order_id` for purchase events

## Interview Angles

- revenue, AOV, and retention
- funnel conversion
- repeat purchase logic
- top product per category
- cohort and channel performance
