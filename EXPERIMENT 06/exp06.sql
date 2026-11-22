-- EXPERIMENT 6: STORED PROCEDURE AND TRIGGERS
-- Small, self-contained MySQL example
-- Run in a MySQL client that supports DELIMITER, triggers, and procedures.

DROP PROCEDURE IF EXISTS transfer_employee;
DROP TRIGGER IF EXISTS validate_salary_insert;
DROP TRIGGER IF EXISTS validate_salary_update;
DROP TRIGGER IF EXISTS employee_audit_update;
DROP TABLE IF EXISTS employee_audit;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30) NOT NULL
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(30) NOT NULL,
    dept_id INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_dept INT NOT NULL,
    new_dept INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Sales');

INSERT INTO employee (emp_id, emp_name, dept_id, salary) VALUES
(101, 'Aman', 1, 25000.00),
(102, 'Riya', 1, 30000.00),
(103, 'Rahul', 2, 28000.00),
(104, 'Neha', 3, 22000.00);

DELIMITER $$

CREATE TRIGGER validate_salary_insert
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END$$

CREATE TRIGGER validate_salary_update
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END$$

CREATE TRIGGER employee_audit_update
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
    IF OLD.dept_id <> NEW.dept_id THEN
        INSERT INTO employee_audit (emp_id, old_dept, new_dept)
        VALUES (OLD.emp_id, OLD.dept_id, NEW.dept_id);
    END IF;
END$$

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_old_dept INT;
    DECLARE v_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_emp_id IS NULL OR p_new_dept_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'IDs cannot be NULL';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM employee
    WHERE emp_id = p_emp_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee not found';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM department
    WHERE dept_id = p_new_dept_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department not found';
    END IF;

    SELECT dept_id INTO v_old_dept
    FROM employee
    WHERE emp_id = p_emp_id;

    IF v_old_dept = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee already in this department';
    END IF;

    START TRANSACTION;

    UPDATE employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
END$$

DELIMITER ;

-- TEST 1: Successful transfer (Aman moves from IT to HR)
CALL transfer_employee(101, 2);

-- OUTPUT 1: Employee records
SELECT emp_id, emp_name, dept_id, salary
FROM employee
ORDER BY emp_id;

-- OUTPUT 2: Audit record created by the trigger
SELECT audit_id, emp_id, old_dept, new_dept, changed_at
FROM employee_audit
ORDER BY audit_id;

-- TEST 2: Salary validation (uncomment to test; expected error)
-- INSERT INTO employee VALUES (105, 'Test', 1, -500);

-- TEST 3: Unknown employee (uncomment to test; expected error)
-- CALL transfer_employee(999, 2);

-- TEST 4: Unknown department (uncomment to test; expected error)
-- CALL transfer_employee(101, 999);

-- TEST 5: Employee already in department (uncomment to test; expected error)
-- CALL transfer_employee(101, 2);

-- Optional: view trigger/procedure names only if supported by your SQL runner
-- SHOW TRIGGERS;
-- SHOW PROCEDURE STATUS WHERE Db = DATABASE() AND Name = 'transfer_employee';
