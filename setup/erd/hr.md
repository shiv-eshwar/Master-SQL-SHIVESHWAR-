# HR ERD

## Grain

- `hr.departments`: one row per department
- `hr.employees`: one row per employee
- `hr.salary_history`: one row per employee salary change event
- `hr.performance_reviews`: one row per review event

## Relationships

- `employees.department_id -> departments.department_id`
- `employees.manager_id -> employees.employee_id`
- `salary_history.employee_id -> employees.employee_id`
- `performance_reviews.employee_id -> employees.employee_id`
- `performance_reviews.reviewer_id -> employees.employee_id`

## Interview Angles

- org hierarchy via self-join or recursive CTE
- latest salary per employee
- pay growth over time
- top performers by department
- headcount snapshots
