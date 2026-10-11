-- ============================================================
-- DBMS PRACTICAL - EXPERIMENT 4
-- Joins, Subqueries, Set Operations, and EXPLAIN
-- Uses the Employee schema created in Experiment 3.
--
-- IMPORTANT: Run Experiment 3 first so employee, department,
-- project, and employee_project tables and data exist.
-- Do not use CREATE DATABASE or USE in ByteXL.
-- ============================================================

-- 1. INNER JOIN: employees and their department names
SELECT e.emp_id, e.emp_name, e.job_title, d.dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

-- 2. LEFT JOIN: all departments, including departments without employees
SELECT d.dept_id, d.dept_name, e.emp_id, e.emp_name
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id;

-- 3. SELF-JOIN: pairs of employees in the same department
SELECT e1.emp_name AS employee_1, e2.emp_name AS employee_2, e1.dept_id
FROM employee e1
INNER JOIN employee e2
  ON e1.dept_id = e2.dept_id
 AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id;

-- 4. THREE-WAY/MULTI-TABLE JOIN: employee, department, and project details
SELECT e.emp_name, d.dept_name, p.project_name, ep.hours_worked
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN employee_project ep ON e.emp_id = ep.emp_id
INNER JOIN project p ON ep.project_id = p.project_id
ORDER BY e.emp_name, p.project_name;

-- 5. CORRELATED SUBQUERY: employees earning more than their department average
SELECT e.emp_id, e.emp_name, e.salary, e.dept_id
FROM employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employee e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY e.dept_id, e.salary DESC;

-- 6. EXISTS: employees assigned to at least one project
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE EXISTS (
    SELECT 1 FROM employee_project ep WHERE ep.emp_id = e.emp_id
)
ORDER BY e.emp_id;

-- 7. SIMULATED INTERSECT: employees in Engineering who have project assignments
-- This represents the intersection of Engineering employees and assigned employees.
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE e.dept_id = 1
  AND EXISTS (
      SELECT 1 FROM employee_project ep WHERE ep.emp_id = e.emp_id
  )
ORDER BY e.emp_id;

-- 8. SIMULATED EXCEPT: employees who are not assigned to any project
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM employee_project ep WHERE ep.emp_id = e.emp_id
)
ORDER BY e.emp_id;

-- 9. EXPLAIN: JOIN query execution plan
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.salary > 70000;

-- 10. EXPLAIN: correlated subquery execution plan
EXPLAIN
SELECT e.emp_name, e.salary, e.dept_id
FROM employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employee e2
    WHERE e2.dept_id = e.dept_id
);

-- 11. EXPLAIN: EXISTS query execution plan
EXPLAIN
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE EXISTS (
    SELECT 1 FROM employee_project ep WHERE ep.emp_id = e.emp_id
);

-- 12A. EXPLAIN: JOIN approach to find Engineering employees
EXPLAIN
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Engineering';

-- 12B. EXPLAIN: subquery approach to find Engineering employees
EXPLAIN
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE e.dept_id = (
    SELECT d.dept_id
    FROM department d
    WHERE d.dept_name = 'Engineering'
);

-- 13. VERIFICATION COUNTS
SELECT COUNT(*) AS total_employees FROM employee;
SELECT COUNT(*) AS total_departments FROM department;
SELECT COUNT(*) AS total_projects FROM project;
SELECT COUNT(*) AS total_employee_project_assignments FROM employee_project;
