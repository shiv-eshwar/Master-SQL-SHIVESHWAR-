-- Week 1 examples: data types, constraints, and useful DML.

DROP TABLE IF EXISTS public.week1_accounts;

CREATE TABLE public.week1_accounts (
    account_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email text NOT NULL UNIQUE,
    signup_ts timestamptz NOT NULL DEFAULT now(),
    country text NOT NULL,
    credit_limit numeric(12, 2) NOT NULL CHECK (credit_limit >= 0),
    is_active boolean NOT NULL DEFAULT true,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);

INSERT INTO public.week1_accounts (email, country, credit_limit, metadata)
VALUES
    ('a@example.com', 'India', 10000.00, '{"plan":"free"}'),
    ('b@example.com', 'India', 25000.50, '{"plan":"pro"}')
RETURNING account_id, email, signup_ts;

SELECT
    email,
    credit_limit,
    credit_limit::integer AS rounded_down_limit,
    metadata ->> 'plan' AS plan_name
FROM public.week1_accounts;

UPDATE public.week1_accounts AS a
SET credit_limit = a.credit_limit + 5000
WHERE a.country = 'India'
RETURNING account_id, credit_limit;

INSERT INTO public.week1_accounts (email, country, credit_limit)
VALUES ('a@example.com', 'India', 20000)
ON CONFLICT (email)
DO UPDATE
SET credit_limit = EXCLUDED.credit_limit
RETURNING account_id, email, credit_limit;
