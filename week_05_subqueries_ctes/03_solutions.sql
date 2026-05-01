-- Week 5 reference solutions

SELECT employee_id, full_name, base_salary
FROM hr.employees
WHERE base_salary > (
    SELECT AVG(base_salary)
    FROM hr.employees
);

WITH dept_avg AS (
    SELECT department_id, AVG(base_salary) AS avg_salary
    FROM hr.employees
    GROUP BY department_id
)
SELECT e.employee_id, e.full_name, e.base_salary, d.avg_salary
FROM hr.employees AS e
JOIN dept_avg AS d
    ON e.department_id = d.department_id
WHERE e.base_salary > d.avg_salary;

WITH RECURSIVE manager_chain AS (
    SELECT employee_id, full_name, manager_id, 0 AS depth
    FROM hr.employees
    WHERE employee_id = 15

    UNION ALL

    SELECT e.employee_id, e.full_name, e.manager_id, mc.depth + 1
    FROM hr.employees AS e
    JOIN manager_chain AS mc
        ON e.employee_id = mc.manager_id
)
SELECT *
FROM manager_chain
ORDER BY depth;
