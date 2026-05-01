-- Week 1 reference solutions

CREATE TABLE IF NOT EXISTS public.analysis_runs (
    run_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model_name text NOT NULL,
    started_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz,
    accuracy numeric(5, 4) CHECK (accuracy BETWEEN 0 AND 1),
    config jsonb NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO public.analysis_runs (model_name, accuracy, config)
VALUES
    ('baseline', 0.8123, '{"features":12}'),
    ('tree_v2', 0.8450, '{"depth":8}'),
    ('xgb_v1', 0.8712, '{"rounds":200}')
RETURNING run_id, model_name;

SELECT
    employee_id,
    full_name,
    base_salary,
    base_salary::integer AS salary_int,
    base_salary::text AS salary_text
FROM hr.employees;

SELECT
    TIMESTAMP '2025-01-01 10:00:00' + INTERVAL '2 hours' AS timestamp_math,
    DATE '2025-01-01' + 7 AS date_math;

ALTER TABLE public.week1_accounts
ADD CONSTRAINT week1_accounts_credit_limit_nonnegative
CHECK (credit_limit >= 0);

SELECT
    order_id,
    order_ts,
    order_ts::date AS order_date
FROM ecommerce.orders;

SELECT
    account_id,
    metadata ->> 'plan' AS plan_name
FROM public.week1_accounts;
