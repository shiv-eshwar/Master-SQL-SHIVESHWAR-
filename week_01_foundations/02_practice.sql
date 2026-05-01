-- Week 1 practice
-- Solve these without opening the solutions first.

-- 1. Create a table named analysis_runs with:
--    - run_id as an identity primary key
--    - model_name as required text
--    - started_at as timestamptz with a default
--    - finished_at as nullable timestamptz
--    - accuracy as numeric(5, 4) constrained between 0 and 1
--    - config as jsonb with a default empty object

-- 2. Insert 3 rows and use RETURNING to show the inserted IDs.

-- 3. Write an upsert that updates accuracy when the same run_id already exists.

-- 4. Query hr.employees and cast base_salary to integer and to text.

-- 5. Show the difference between timestamp math and date math using literals.

-- 6. Add a CHECK constraint that prevents negative credit limits on week1_accounts.

-- 7. Query ecommerce.orders and return order_ts both as raw timestamptz and as date.

-- 8. Write a query that extracts the plan field from week1_accounts.metadata.
