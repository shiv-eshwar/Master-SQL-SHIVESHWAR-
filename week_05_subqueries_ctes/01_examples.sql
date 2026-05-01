-- Week 5 examples: scalar subqueries, CTEs, and recursive CTEs.

SELECT
    employee_id,
    full_name,
    base_salary,
    (
        SELECT AVG(base_salary)
        FROM hr.employees
    ) AS company_avg_salary
FROM hr.employees;

WITH department_salary AS (
    SELECT
        department_id,
        AVG(base_salary) AS avg_salary
    FROM hr.employees
    GROUP BY department_id
)
SELECT e.full_name, d.avg_salary
FROM hr.employees AS e
JOIN department_salary AS d
    ON e.department_id = d.department_id;

WITH RECURSIVE org_chain AS (
    SELECT employee_id, full_name, manager_id, 0 AS depth
    FROM hr.employees
    WHERE employee_id = 15

    UNION ALL

    SELECT e.employee_id, e.full_name, e.manager_id, oc.depth + 1
    FROM hr.employees AS e
    JOIN org_chain AS oc
        ON e.employee_id = oc.manager_id
)
SELECT *
FROM org_chain
ORDER BY depth;
