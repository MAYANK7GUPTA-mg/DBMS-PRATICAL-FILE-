-- ============================================================
-- DBMS PRACTICAL - EXPERIMENT 3
-- Employee–Department–Project Database
-- ============================================================

-- DO NOT USE CREATE DATABASE OR USE IN BYTEXL


-- 1. CREATE DEPARTMENT TABLE
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);


-- 2. CREATE EMPLOYEE TABLE
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);


-- 3. CREATE PROJECT TABLE
CREATE TABLE project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2),
    start_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);


-- 4. CREATE EMPLOYEE_PROJECT TABLE
CREATE TABLE employee_project (
    emp_id INT,
    project_id INT,
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (project_id) REFERENCES project(project_id)
);


-- 5. INSERT 5 DEPARTMENTS
INSERT INTO department VALUES
(1, 'Engineering', 'Bangalore'),
(2, 'Human Resources', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Hyderabad'),
(5, 'Operations', 'Pune');


-- 6. INSERT 30 EMPLOYEES
INSERT INTO employee VALUES
(101, 'Rahul Sharma', 'Software Engineer', 65000, '2022-01-15', 1),
(102, 'Aman Verma', 'Senior Engineer', 85000, '2021-03-10', 1),
(103, 'Priya Singh', 'Data Analyst', 60000, '2023-06-20', 1),
(104, 'Neha Gupta', 'Software Engineer', 70000, '2022-08-12', 1),
(105, 'Arjun Kumar', 'Team Lead', 95000, '2020-11-05', 1),
(106, 'Riya Mehta', 'DevOps Engineer', 78000, '2021-09-18', 1),

(107, 'Vikas Yadav', 'HR Executive', 50000, '2022-02-14', 2),
(108, 'Anjali Singh', 'HR Manager', 80000, '2019-07-22', 2),
(109, 'Rohit Gupta', 'Recruiter', 55000, '2023-01-11', 2),
(110, 'Sneha Patel', 'HR Executive', 52000, '2022-10-03', 2),
(111, 'Karan Malhotra', 'Training Manager', 75000, '2020-05-19', 2),
(112, 'Pooja Sharma', 'Recruiter', 57000, '2023-04-16', 2),

(113, 'Aditya Jain', 'Accountant', 58000, '2021-01-20', 3),
(114, 'Kavita Rao', 'Finance Manager', 90000, '2019-09-12', 3),
(115, 'Manish Kumar', 'Financial Analyst', 68000, '2022-04-25', 3),
(116, 'Simran Kaur', 'Accountant', 60000, '2022-12-08', 3),
(117, 'Deepak Shah', 'Auditor', 72000, '2020-06-15', 3),
(118, 'Nisha Verma', 'Financial Analyst', 65000, '2023-02-28', 3),

(119, 'Sahil Kapoor', 'Marketing Executive', 55000, '2022-03-17', 4),
(120, 'Isha Agarwal', 'Marketing Manager', 88000, '2019-11-21', 4),
(121, 'Varun Singh', 'SEO Specialist', 62000, '2021-08-14', 4),
(122, 'Meera Joshi', 'Content Manager', 70000, '2022-07-05', 4),
(123, 'Akash Mishra', 'Marketing Executive', 56000, '2023-05-10', 4),
(124, 'Tanya Roy', 'Social Media Manager', 68000, '2021-12-01', 4),

(125, 'Nitin Sharma', 'Operations Manager', 85000, '2020-02-18', 5),
(126, 'Komal Gupta', 'Operations Executive', 52000, '2022-06-22', 5),
(127, 'Mohit Verma', 'Logistics Manager', 76000, '2021-04-09', 5),
(128, 'Aarti Singh', 'Operations Executive', 54000, '2023-03-13', 5),
(129, 'Rakesh Kumar', 'Supply Chain Analyst', 67000, '2022-09-27', 5),
(130, 'Divya Patel', 'Operations Executive', 55000, '2023-07-19', 5);


-- 7. INSERT 8 PROJECTS
INSERT INTO project VALUES
(201, 'E-Commerce Platform', 5000000, '2024-01-10', 1),
(202, 'AI Analytics System', 3500000, '2024-03-15', 1),
(203, 'Employee Management System', 2000000, '2024-02-01', 2),
(204, 'Financial Automation', 4500000, '2024-04-10', 3),
(205, 'Digital Marketing Campaign', 1800000, '2024-05-05', 4),
(206, 'Supply Chain Optimization', 3000000, '2024-06-12', 5),
(207, 'Customer Data Platform', 4000000, '2024-07-01', 1),
(208, 'Business Expansion Project', 2500000, '2024-08-20', 4);


-- 8. ASSIGN EMPLOYEES TO PROJECTS
INSERT INTO employee_project VALUES
(101, 201, 120),
(102, 201, 150),
(103, 202, 130),
(104, 202, 110),
(105, 201, 100),
(106, 202, 140),

(107, 203, 100),
(108, 203, 120),
(109, 203, 90),
(110, 203, 80),
(111, 203, 110),
(112, 203, 95),

(113, 204, 120),
(114, 204, 150),
(115, 204, 130),
(116, 204, 100),
(117, 204, 90),
(118, 204, 110),

(119, 205, 100),
(120, 205, 140),
(121, 205, 110),
(122, 205, 120),

(123, 208, 100),
(124, 208, 130),

(125, 206, 150),
(126, 206, 100),
(127, 206, 130),
(128, 206, 90),
(129, 206, 120),
(130, 206, 100),

(101, 207, 80),
(103, 207, 90),
(104, 207, 100),
(120, 208, 110);


-- ============================================================
-- QUERIES REQUIRED IN EXPERIMENT 3
-- ============================================================

-- 9. SELECTION
SELECT *
FROM employee
WHERE salary > 70000;


-- 10. PROJECTION
SELECT emp_name, job_title
FROM employee;


-- 11. SELECTION + PROJECTION
SELECT emp_name, salary
FROM employee
WHERE salary > 75000;


-- 12. COUNT
SELECT COUNT(*) AS total_employees
FROM employee;


-- 13. AVG
SELECT ROUND(AVG(salary), 2) AS average_salary
FROM employee;


-- 14. MAX
SELECT MAX(salary) AS highest_salary
FROM employee;


-- 15. MIN
SELECT MIN(salary) AS lowest_salary
FROM employee;


-- 16. SUM
SELECT SUM(salary) AS total_salary
FROM employee;


-- 17. GROUP BY
SELECT dept_id, COUNT(*) AS employee_count
FROM employee
GROUP BY dept_id;


-- 18. GROUP BY WITH DEPARTMENT NAME
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;


-- 19. AVERAGE SALARY BY DEPARTMENT
SELECT
    d.dept_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;


-- 20. HAVING
SELECT
    dept_id,
    COUNT(*) AS employee_count
FROM employee
GROUP BY dept_id
HAVING COUNT(*) > 5;


-- 21. HAVING WITH AVG
SELECT
    d.dept_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 65000;


-- 22. CASE EXPRESSION - SALARY CATEGORY
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 80000 THEN 'High Salary'
        WHEN salary >= 60000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM employee;


-- 23. CASE EXPRESSION - DEPARTMENT
SELECT
    emp_name,
    CASE
        WHEN dept_id = 1 THEN 'Engineering'
        WHEN dept_id = 2 THEN 'Human Resources'
        WHEN dept_id = 3 THEN 'Finance'
        WHEN dept_id = 4 THEN 'Marketing'
        WHEN dept_id = 5 THEN 'Operations'
        ELSE 'Unknown'
    END AS department
FROM employee;


-- 24. ORDER BY ASCENDING
SELECT emp_name, salary
FROM employee
ORDER BY salary ASC;


-- 25. ORDER BY DESCENDING
SELECT emp_name, salary
FROM employee
ORDER BY salary DESC;


-- 26. GROUP BY + HAVING + ORDER BY
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM department d
JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 5
ORDER BY employee_count DESC;


-- 27. PROJECT-WISE EMPLOYEE COUNT
SELECT
    p.project_name,
    COUNT(ep.emp_id) AS employee_count
FROM project p
JOIN employee_project ep
ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name
ORDER BY employee_count DESC;


-- 28. COMPLETE EMPLOYEE-DEPARTMENT-PROJECT DETAILS
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    ep.hours_worked
FROM employee e
JOIN department d
ON e.dept_id = d.dept_id
JOIN employee_project ep
ON e.emp_id = ep.emp_id
JOIN project p
ON ep.project_id = p.project_id
ORDER BY e.emp_name ASC;


-- 29. VERIFICATION
SELECT COUNT(*) AS total_departments
FROM department;

SELECT COUNT(*) AS total_employees
FROM employee;

SELECT COUNT(*) AS total_projects
FROM project;