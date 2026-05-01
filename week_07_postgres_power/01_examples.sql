-- Week 7 examples: time functions, strings, arrays, and jsonb.

SELECT
    order_id,
    order_ts,
    DATE_TRUNC('month', order_ts) AS order_month,
    EXTRACT(DOW FROM order_ts) AS day_of_week
FROM ecommerce.orders;

SELECT
    username,
    UPPER(username) AS username_upper,
    username ~ '^[a-z]+$' AS is_simple_alpha
FROM social.users;

SELECT *
FROM generate_series(DATE '2025-01-01', DATE '2025-01-07', INTERVAL '1 day') AS g(day_value);

SELECT
    account_id,
    metadata,
    metadata ->> 'plan' AS plan_name
FROM public.week1_accounts;
