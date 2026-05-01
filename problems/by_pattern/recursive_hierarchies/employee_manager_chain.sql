-- Pattern: recursive hierarchy
-- Prompt: show the manager chain for employee 15 up to the CEO.

WITH RECURSIVE manager_chain AS (
    SELECT
        employee_id,
        full_name,
        manager_id,
        0 AS depth
    FROM hr.employees
    WHERE employee_id = 15

    UNION ALL

    SELECT
        e.employee_id,
        e.full_name,
        e.manager_id,
        mc.depth + 1
    FROM hr.employees AS e
    JOIN manager_chain AS mc
        ON e.employee_id = mc.manager_id
)
SELECT *
FROM manager_chain
ORDER BY depth;
