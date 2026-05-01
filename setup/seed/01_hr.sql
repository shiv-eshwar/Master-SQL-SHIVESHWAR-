DROP SCHEMA IF EXISTS hr CASCADE;
CREATE SCHEMA hr;

CREATE TABLE hr.departments (
    department_id integer PRIMARY KEY,
    department_name text NOT NULL UNIQUE,
    cost_center text NOT NULL,
    location text NOT NULL
);

CREATE TABLE hr.employees (
    employee_id integer PRIMARY KEY,
    full_name text NOT NULL,
    email text NOT NULL UNIQUE,
    hire_date date NOT NULL,
    birth_date date NOT NULL,
    department_id integer NOT NULL REFERENCES hr.departments(department_id),
    manager_id integer REFERENCES hr.employees(employee_id),
    job_title text NOT NULL,
    employment_status text NOT NULL CHECK (employment_status IN ('active', 'leave', 'terminated')),
    base_salary numeric(12, 2) NOT NULL CHECK (base_salary > 0),
    bonus_pct numeric(5, 2) NOT NULL DEFAULT 0 CHECK (bonus_pct >= 0),
    is_remote boolean NOT NULL DEFAULT false
);

CREATE TABLE hr.salary_history (
    employee_id integer NOT NULL REFERENCES hr.employees(employee_id),
    effective_date date NOT NULL,
    salary_amount numeric(12, 2) NOT NULL CHECK (salary_amount > 0),
    PRIMARY KEY (employee_id, effective_date)
);

CREATE TABLE hr.performance_reviews (
    review_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id integer NOT NULL REFERENCES hr.employees(employee_id),
    review_date date NOT NULL,
    rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
    reviewer_id integer REFERENCES hr.employees(employee_id),
    comments text
);

INSERT INTO hr.departments (department_id, department_name, cost_center, location) VALUES
(10, 'Executive', 'CC100', 'Bengaluru'),
(20, 'Data Science', 'CC210', 'Bengaluru'),
(30, 'Analytics', 'CC220', 'Hyderabad'),
(40, 'Engineering', 'CC310', 'Pune'),
(50, 'Finance', 'CC410', 'Mumbai'),
(60, 'People Ops', 'CC510', 'Remote');

INSERT INTO hr.employees (
    employee_id,
    full_name,
    email,
    hire_date,
    birth_date,
    department_id,
    manager_id,
    job_title,
    employment_status,
    base_salary,
    bonus_pct,
    is_remote
) VALUES
(1, 'Asha Menon', 'asha.menon@company.com', DATE '2015-01-05', DATE '1985-03-21', 10, NULL, 'Chief Executive Officer', 'active', 350000, 35.00, false),
(2, 'Vikram Shah', 'vikram.shah@company.com', DATE '2016-04-11', DATE '1984-07-18', 20, 1, 'Director of Data Science', 'active', 260000, 25.00, true),
(3, 'Neha Iyer', 'neha.iyer@company.com', DATE '2017-06-19', DATE '1988-09-03', 30, 1, 'Director of Analytics', 'active', 245000, 22.00, false),
(4, 'Rahul Kapoor', 'rahul.kapoor@company.com', DATE '2016-08-08', DATE '1986-12-12', 40, 1, 'VP Engineering', 'active', 275000, 25.00, false),
(5, 'Pooja Rao', 'pooja.rao@company.com', DATE '2018-02-14', DATE '1990-05-01', 50, 1, 'Finance Lead', 'active', 210000, 18.00, false),
(6, 'Sara Thomas', 'sara.thomas@company.com', DATE '2018-09-03', DATE '1991-10-30', 60, 1, 'HR Business Partner', 'active', 180000, 15.00, true),
(7, 'Arjun Patel', 'arjun.patel@company.com', DATE '2019-03-21', DATE '1992-11-09', 20, 2, 'Senior Data Scientist', 'active', 190000, 15.00, true),
(8, 'Isha Gupta', 'isha.gupta@company.com', DATE '2020-01-13', DATE '1994-01-14', 20, 2, 'Machine Learning Scientist', 'active', 185000, 12.00, false),
(9, 'Karan Singh', 'karan.singh@company.com', DATE '2021-07-26', DATE '1995-04-16', 20, 2, 'Data Scientist', 'active', 145000, 10.00, true),
(10, 'Meera Joshi', 'meera.joshi@company.com', DATE '2019-10-07', DATE '1992-08-27', 30, 3, 'Analytics Manager', 'active', 175000, 12.00, false),
(11, 'Rohan Das', 'rohan.das@company.com', DATE '2020-05-11', DATE '1993-06-13', 30, 10, 'Senior Analyst', 'active', 120000, 8.00, true),
(12, 'Priya Nair', 'priya.nair@company.com', DATE '2022-03-28', DATE '1997-02-20', 30, 10, 'Business Analyst', 'leave', 98000, 5.00, false),
(13, 'Ankit Jain', 'ankit.jain@company.com', DATE '2019-11-18', DATE '1991-04-08', 40, 4, 'Engineering Manager', 'active', 205000, 15.00, false),
(14, 'Lavanya Krishnan', 'lavanya.krishnan@company.com', DATE '2021-02-01', DATE '1996-12-29', 40, 13, 'Data Engineer', 'active', 150000, 10.00, true),
(15, 'Dev Malhotra', 'dev.malhotra@company.com', DATE '2023-01-09', DATE '1998-09-09', 20, 7, 'Associate Data Scientist', 'active', 92000, 4.00, true),
(16, 'Nikita Verma', 'nikita.verma@company.com', DATE '2022-08-15', DATE '1996-07-07', 50, 5, 'Finance Analyst', 'active', 99000, 6.00, false),
(17, 'Siddharth Bose', 'siddharth.bose@company.com', DATE '2021-11-29', DATE '1994-10-21', 60, 6, 'Recruiter', 'active', 88000, 5.00, true),
(18, 'Tanvi Kulkarni', 'tanvi.kulkarni@company.com', DATE '2020-09-14', DATE '1993-03-11', 20, 7, 'Applied Scientist', 'terminated', 160000, 8.00, false);

INSERT INTO hr.salary_history (employee_id, effective_date, salary_amount) VALUES
(7, DATE '2019-03-21', 155000), (7, DATE '2021-01-01', 175000), (7, DATE '2023-01-01', 190000),
(8, DATE '2020-01-13', 150000), (8, DATE '2022-01-01', 170000), (8, DATE '2024-01-01', 185000),
(9, DATE '2021-07-26', 120000), (9, DATE '2023-01-01', 135000), (9, DATE '2024-07-01', 145000),
(10, DATE '2019-10-07', 150000), (10, DATE '2022-01-01', 165000), (10, DATE '2024-01-01', 175000),
(11, DATE '2020-05-11', 95000), (11, DATE '2022-01-01', 108000), (11, DATE '2024-01-01', 120000),
(12, DATE '2022-03-28', 90000), (12, DATE '2024-01-01', 98000),
(14, DATE '2021-02-01', 125000), (14, DATE '2023-01-01', 140000), (14, DATE '2024-01-01', 150000),
(15, DATE '2023-01-09', 82000), (15, DATE '2024-01-01', 92000),
(16, DATE '2022-08-15', 90000), (16, DATE '2024-01-01', 99000),
(17, DATE '2021-11-29', 76000), (17, DATE '2024-01-01', 88000),
(18, DATE '2020-09-14', 130000), (18, DATE '2022-01-01', 150000), (18, DATE '2024-01-01', 160000);

INSERT INTO hr.performance_reviews (employee_id, review_date, rating, reviewer_id, comments) VALUES
(7, DATE '2023-12-15', 5, 2, 'Strong technical leadership'),
(7, DATE '2024-12-15', 4, 2, 'Delivered critical experimentation platform work'),
(8, DATE '2023-12-15', 4, 2, 'Reliable execution on ML pipelines'),
(9, DATE '2024-12-15', 3, 7, 'Needs sharper communication of trade-offs'),
(10, DATE '2023-12-10', 4, 3, 'Good stakeholder management'),
(11, DATE '2024-12-10', 5, 10, 'Excellent analytical rigor'),
(12, DATE '2024-12-10', 4, 10, 'Consistent despite leave period'),
(14, DATE '2024-11-20', 4, 13, 'Strong platform ownership'),
(15, DATE '2024-11-20', 3, 7, 'Promising, still developing SQL depth'),
(16, DATE '2024-10-15', 4, 5, 'Improved monthly close reporting'),
(17, DATE '2024-10-15', 3, 6, 'Good pipeline generation'),
(18, DATE '2023-12-15', 2, 2, 'Performance concerns prior to exit');
