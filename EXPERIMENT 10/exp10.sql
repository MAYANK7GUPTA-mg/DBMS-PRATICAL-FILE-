
-- EXPERIMENT 10: QUERY OPTIMIZATION

DROP TABLE IF EXISTS student_records;

CREATE TABLE student_records (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(60),
    department VARCHAR(30),
    city VARCHAR(30),
    age INT,
    marks DECIMAL(5,2),
    admission_year INT,
    student_status VARCHAR(20),
    email VARCHAR(80)
);

-- ==========================================
-- PART 2: GENERATE 10,000 STUDENT RECORDS
-- ==========================================

INSERT INTO student_records
(
    student_id,
    student_name,
    department,
    city,
    age,
    marks,
    admission_year,
    student_status,
    email
)

SELECT
    n,
    CONCAT('Student_', n),

    CASE MOD(n, 5)
        WHEN 0 THEN 'CSE'
        WHEN 1 THEN 'AIML'
        WHEN 2 THEN 'IT'
        WHEN 3 THEN 'ECE'
        ELSE 'ME'
    END,

    CASE MOD(n, 5)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Kolkata'
        WHEN 3 THEN 'Chennai'
        ELSE 'Lucknow'
    END,

    18 + MOD(n, 13),
    40 + MOD(n, 61),
    2020 + MOD(n, 7),

    CASE MOD(n, 3)
        WHEN 0 THEN 'ACTIVE'
        WHEN 1 THEN 'INACTIVE'
        ELSE 'GRADUATED'
    END,

    CONCAT(
        'student_',
        LPAD(n, 5, '0'),
        '@example.com'
    )

FROM
(
    SELECT
        1 + (a.d * 1000) + (b.d * 100)
          + (c.d * 10) + d.d AS n
    FROM
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
) numbers;


-- ==========================================
-- PART 3: VERIFY DATASET
-- ==========================================

SELECT COUNT(*) AS total_records
FROM student_records;

SELECT *
FROM student_records
LIMIT 10;


-- ==========================================
-- PART 4: FIVE SLOW QUERIES
-- ANALYZE BEFORE OPTIMIZATION
-- ==========================================

-- SLOW QUERY 1:
-- Search using department, city and marks

EXPLAIN
SELECT *
FROM student_records
WHERE department = 'CSE'
AND city = 'Delhi'
AND marks >= 85;


-- SLOW QUERY 2:
-- Using LOWER() on email column

EXPLAIN
SELECT *
FROM student_records
WHERE LOWER(email) = 'student_05000@example.com';


-- SLOW QUERY 3:
-- Performing calculation on primary key

EXPLAIN
SELECT *
FROM student_records
WHERE student_id + 0 = 5000;


-- SLOW QUERY 4:
-- Using UPPER() on status column

EXPLAIN
SELECT *
FROM student_records
WHERE UPPER(student_status) = 'ACTIVE';


-- SLOW QUERY 5:
-- Using OR condition on two columns

EXPLAIN
SELECT *
FROM student_records
WHERE age BETWEEN 20 AND 22
OR marks >= 95;


-- ==========================================
-- PART 5: CREATE INDEXES
-- ==========================================

-- Index for department, city and marks

CREATE INDEX idx_department_city_marks
ON student_records(department, city, marks);


-- Index for email

CREATE INDEX idx_email
ON student_records(email);


-- Index for student status

CREATE INDEX idx_student_status
ON student_records(student_status);


-- Index for age

CREATE INDEX idx_age
ON student_records(age);


-- Index for marks

CREATE INDEX idx_marks
ON student_records(marks);


-- Update table statistics

ANALYZE TABLE student_records;


-- ==========================================
-- PART 6: OPTIMIZED QUERIES
-- ==========================================

-- OPTIMIZED QUERY 1:
-- Uses composite index

EXPLAIN
SELECT *
FROM student_records
WHERE department = 'CSE'
AND city = 'Delhi'
AND marks >= 85;


-- OPTIMIZED QUERY 2:
-- Remove LOWER() and use direct comparison

EXPLAIN
SELECT *
FROM student_records
WHERE email = 'student_05000@example.com';


-- OPTIMIZED QUERY 3:
-- Remove calculation and use primary key directly

EXPLAIN
SELECT *
FROM student_records
WHERE student_id = 5000;


-- OPTIMIZED QUERY 4:
-- Remove UPPER() and use direct comparison

EXPLAIN
SELECT *
FROM student_records
WHERE student_status = 'ACTIVE';


-- OPTIMIZED QUERY 5:
-- Rewrite OR using UNION ALL

EXPLAIN
SELECT *
FROM student_records
WHERE age BETWEEN 20 AND 22

UNION ALL

SELECT *
FROM student_records
WHERE marks >= 95
AND age NOT BETWEEN 20 AND 22;


-- ==========================================
-- PART 7: VERIFY ALL INDEXES
-- ==========================================

SHOW INDEX FROM student_records;


-- ==========================================
-- PART 8: FINAL VERIFICATION
-- ==========================================

SELECT COUNT(*) AS total_students
FROM student_records;

SELECT
    department,
    COUNT(*) AS total_students,
    AVG(marks) AS average_marks
FROM student_records
GROUP BY department;

SELECT *
FROM student_records
ORDER BY student_id
LIMIT 10;
