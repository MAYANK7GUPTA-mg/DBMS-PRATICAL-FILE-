-- ============================================================
-- DBMS PRACTICAL - EXPERIMENT 5
-- SQL Views, View Updatability, and Recursive CTE
-- Standalone ByteXL-compatible script for a fresh sandbox database.
-- Does not use CREATE DATABASE or USE.
-- ============================================================

-- 1. CREATE REQUIRED TABLES
-- manager_id is included here so no ALTER TABLE is needed on a fresh setup.

CREATE TABLE IF NOT EXISTS department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    manager_id INT NULL,
    CONSTRAINT fk_exp5_department
        FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    CONSTRAINT fk_exp5_manager
        FOREIGN KEY (manager_id) REFERENCES employee(emp_id)
        ON DELETE SET NULL
);

-- 2. INSERT DEPARTMENTS
-- INSERT IGNORE avoids duplicate-key errors if you run the script again.
INSERT IGNORE INTO department (dept_id, dept_name, location) VALUES
(1, 'Engineering', 'Bangalore'),
(2, 'Human Resources', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Hyderabad'),
(5, 'Operations', 'Pune');

-- 3. INSERT 30 EMPLOYEES
-- manager_id starts as NULL; reporting relationships are assigned later.
INSERT IGNORE INTO employee
(emp_id, emp_name, job_title, salary, hire_date, dept_id, manager_id)
VALUES
(101, 'Rahul Sharma', 'Software Engineer', 65000, '2022-01-15', 1, NULL),
(102, 'Aman Verma', 'Senior Engineer', 85000, '2021-03-10', 1, NULL),
(103, 'Priya Singh', 'Data Analyst', 60000, '2023-06-20', 1, NULL),
(104, 'Neha Gupta', 'Software Engineer', 70000, '2022-08-12', 1, NULL),
(105, 'Arjun Kumar', 'Team Lead', 95000, '2020-11-05', 1, NULL),
(106, 'Riya Mehta', 'DevOps Engineer', 78000, '2021-09-18', 1, NULL),
(107, 'Vikas Yadav', 'HR Executive', 50000, '2022-02-14', 2, NULL),
(108, 'Anjali Singh', 'HR Manager', 80000, '2019-07-22', 2, NULL),
(109, 'Rohit Gupta', 'Recruiter', 55000, '2023-01-11', 2, NULL),
(110, 'Sneha Patel', 'HR Executive', 52000, '2022-10-03', 2, NULL),
(111, 'Karan Malhotra', 'Training Manager', 75000, '2020-05-19', 2, NULL),
(112, 'Pooja Sharma', 'Recruiter', 57000, '2023-04-16', 2, NULL),
(113, 'Aditya Jain', 'Accountant', 58000, '2021-01-20', 3, NULL),
(114, 'Kavita Rao', 'Finance Manager', 90000, '2019-09-12', 3, NULL),
(115, 'Manish Kumar', 'Financial Analyst', 68000, '2022-04-25', 3, NULL),
(116, 'Simran Kaur', 'Accountant', 60000, '2022-12-08', 3, NULL),
(117, 'Deepak Shah', 'Auditor', 72000, '2020-06-15', 3, NULL),
(118, 'Nisha Verma', 'Financial Analyst', 65000, '2023-02-28', 3, NULL),
(119, 'Sahil Kapoor', 'Marketing Executive', 55000, '2022-03-17', 4, NULL),
(120, 'Isha Agarwal', 'Marketing Manager', 88000, '2019-11-21', 4, NULL),
(121, 'Varun Singh', 'SEO Specialist', 62000, '2021-08-14', 4, NULL),
(122, 'Meera Joshi', 'Content Manager', 70000, '2022-07-05', 4, NULL),
(123, 'Akash Mishra', 'Marketing Executive', 56000, '2023-05-10', 4, NULL),
(124, 'Tanya Roy', 'Social Media Manager', 68000, '2021-12-01', 4, NULL),
(125, 'Nitin Sharma', 'Operations Manager', 85000, '2020-02-18', 5, NULL),
(126, 'Komal Gupta', 'Operations Executive', 52000, '2022-06-22', 5, NULL),
(127, 'Mohit Verma', 'Logistics Manager', 76000, '2021-04-09', 5, NULL),
(128, 'Aarti Singh', 'Operations Executive', 54000, '2023-03-13', 5, NULL),
(129, 'Rakesh Kumar', 'Supply Chain Analyst', 67000, '2022-09-27', 5, NULL),
(130, 'Divya Patel', 'Operations Executive', 55000, '2023-07-19', 5, NULL);

-- 4. ASSIGN SAMPLE MANAGER RELATIONSHIPS
-- These UPDATE statements are safe to repeat.
UPDATE employee SET manager_id = NULL;

UPDATE employee SET manager_id = 105
WHERE emp_id IN (101, 102, 103, 104, 106);

UPDATE employee SET manager_id = 108
WHERE emp_id IN (107, 109, 110, 111, 112);

UPDATE employee SET manager_id = 114
WHERE emp_id IN (113, 115, 116, 117, 118);

UPDATE employee SET manager_id = 120
WHERE emp_id IN (119, 121, 122, 123, 124);

UPDATE employee SET manager_id = 125
WHERE emp_id IN (126, 127, 128, 129, 130);

UPDATE employee SET manager_id = 105
WHERE emp_id IN (108, 114, 120, 125);

-- 5. DEPARTMENT SALARY SUMMARY VIEW
DROP VIEW IF EXISTS department_salary_summary;

CREATE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    COALESCE(SUM(e.salary), 0) AS total_salary,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM department_salary_summary
ORDER BY dept_id;

-- 6. SIMPLE EMPLOYEE VIEW (GENERALLY UPDATABLE)
DROP VIEW IF EXISTS employee_basic_view;

CREATE VIEW employee_basic_view AS
SELECT emp_id, emp_name, job_title, salary, dept_id
FROM employee;

SELECT *
FROM employee_basic_view
ORDER BY emp_id;

-- 7. TEST UPDATE THROUGH SIMPLE VIEW
-- ROLLBACK restores the original salary. Run as a separate block if needed.
START TRANSACTION;

UPDATE employee_basic_view
SET salary = salary + 1
WHERE emp_id = 101;

SELECT emp_id, emp_name, salary
FROM employee
WHERE emp_id = 101;

ROLLBACK;

-- 8. TEST INSERT THROUGH SIMPLE VIEW
-- ROLLBACK removes the temporary test record.
START TRANSACTION;

INSERT INTO employee_basic_view
    (emp_id, emp_name, job_title, salary, dept_id)
VALUES
    (999, 'View Test Employee', 'Test Role', 40000, 1);

SELECT *
FROM employee_basic_view
WHERE emp_id = 999;

ROLLBACK;

-- 9. AGGREGATE VIEW UPDATABILITY CHECK
-- Grouped/aggregate views are generally not updatable.
SELECT *
FROM department_salary_summary;

-- Optional error demonstration: run separately only if asked by instructor.
-- UPDATE department_salary_summary
-- SET average_salary = 70000
-- WHERE dept_id = 1;

-- 10. EMPLOYEE HIERARCHY VIEW
DROP VIEW IF EXISTS employee_hierarchy;

CREATE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.job_title,
    e.dept_id,
    d.dept_name,
    e.manager_id
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id;

SELECT *
FROM employee_hierarchy
ORDER BY dept_id, emp_id;

-- 11. RECURSIVE CTE: REPORTING CHAINS
-- Requires MySQL 8.0 or later.
WITH RECURSIVE reporting_chain AS (
    SELECT
        e.emp_id,
        e.emp_name,
        e.job_title,
        e.manager_id,
        0 AS hierarchy_level,
        CAST(e.emp_name AS CHAR(1000)) AS reporting_path
    FROM employee e
    WHERE e.manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.job_title,
        e.manager_id,
        rc.hierarchy_level + 1,
        CAST(CONCAT(rc.reporting_path, ' -> ', e.emp_name) AS CHAR(1000))
            AS reporting_path
    FROM employee e
    INNER JOIN reporting_chain rc ON e.manager_id = rc.emp_id
)
SELECT
    emp_id,
    emp_name,
    job_title,
    manager_id,
    hierarchy_level,
    reporting_path
FROM reporting_chain
ORDER BY reporting_path;

-- 12. INSPECT VIEW DEFINITIONS
SHOW CREATE VIEW department_salary_summary;
SHOW CREATE VIEW employee_basic_view;
SHOW CREATE VIEW employee_hierarchy;

-- 13. VERIFICATION
-- Run these together and capture ONE combined screenshot.
SELECT COUNT(*) AS total_employees FROM employee;
SELECT COUNT(*) AS total_departments FROM department;
SELECT COUNT(*) AS employees_with_manager
FROM employee
WHERE manager_id IS NOT NULL;
