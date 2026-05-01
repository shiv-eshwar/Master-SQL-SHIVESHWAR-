-- Week 12 reference solution patterns

-- Pattern checklist:
-- 1. ranking problem -> ROW_NUMBER / RANK / DISTINCT ON / LATERAL
-- 2. event sequence problem -> LAG / LEAD / running SUM
-- 3. retention problem -> cohort CTE + month offset
-- 4. streak problem -> ROW_NUMBER grouping trick
-- 5. funnel problem -> staged event CTEs
-- 6. dedup problem -> ROW_NUMBER + WHERE rn = 1

-- The point of this file is not one giant query.
-- The point is to rehearse how you choose the right pattern quickly.
