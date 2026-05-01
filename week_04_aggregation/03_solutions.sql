-- Week 4 reference solutions

SELECT
    department_id,
    COUNT(*) AS employee_count,
    SUM(base_salary) AS total_salary,
    AVG(base_salary) AS avg_salary
FROM hr.employees
GROUP BY department_id;

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) >= 2;

SELECT
    payment_method,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_orders,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders,
    COUNT(*) FILTER (WHERE status = 'refunded') AS refunded_orders
FROM ecommerce.orders
GROUP BY payment_method;

SELECT
    p.post_id,
    COUNT(DISTINCT l.user_id) AS like_count,
    COUNT(DISTINCT c.comment_id) AS comment_count
FROM social.posts AS p
LEFT JOIN social.likes AS l
    ON p.post_id = l.post_id
LEFT JOIN social.comments AS c
    ON p.post_id = c.post_id
GROUP BY p.post_id
ORDER BY p.post_id;
