
-- ==========================================
-- EXPERIMENT 9: INDEXING AND QUERY OPTIMIZATION
-- RAILWAY BOOKING SYSTEM
-- ==========================================


-- PART 1: CREATE TABLE
-- ==========================================

DROP TABLE IF EXISTS railway_bookings;

CREATE TABLE railway_bookings (
    booking_id INT PRIMARY KEY,
    passenger_name VARCHAR(50),
    train_no INT,
    source_station VARCHAR(50),
    destination_station VARCHAR(50),
    journey_date DATE,
    coach_type VARCHAR(20),
    booking_status VARCHAR(20),
    fare DECIMAL(8,2)
);


-- PART 2: INSERT 5000 RECORDS
-- ==========================================

INSERT INTO railway_bookings
(
    booking_id,
    passenger_name,
    train_no,
    source_station,
    destination_station,
    journey_date,
    coach_type,
    booking_status,
    fare
)

SELECT
    n,
    CONCAT('Passenger_', n),
    12000 + MOD(n, 20),

    CASE MOD(n, 5)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Kolkata'
        WHEN 3 THEN 'Chennai'
        ELSE 'Bangalore'
    END,

    CASE MOD(n, 5)
        WHEN 0 THEN 'Jaipur'
        WHEN 1 THEN 'Pune'
        WHEN 2 THEN 'Patna'
        WHEN 3 THEN 'Hyderabad'
        ELSE 'Lucknow'
    END,

    DATE_ADD('2026-01-01', INTERVAL MOD(n, 180) DAY),

    CASE MOD(n, 3)
        WHEN 0 THEN 'Sleeper'
        WHEN 1 THEN 'AC_3_Tier'
        ELSE 'AC_2_Tier'
    END,

    CASE MOD(n, 3)
        WHEN 0 THEN 'CONFIRMED'
        WHEN 1 THEN 'WAITING'
        ELSE 'CANCELLED'
    END,

    300 + MOD(n, 1700)

FROM
(
    SELECT
        1 + (a.d * 1000) + (b.d * 100) +
            (c.d * 10) + d.d AS n

    FROM
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a

    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b

    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c

    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d

) numbers

WHERE n <= 5000;


-- PART 3: VERIFY RECORDS
-- ==========================================

SELECT COUNT(*) AS total_records
FROM railway_bookings;

SELECT *
FROM railway_bookings
LIMIT 10;


-- PART 4: QUERY PERFORMANCE BEFORE INDEXING
-- ==========================================

-- Query 1: Search by train number

EXPLAIN
SELECT *
FROM railway_bookings
WHERE train_no = 12005;


-- Query 2: Search using multiple conditions

EXPLAIN
SELECT *
FROM railway_bookings
WHERE train_no = 12005
AND booking_status = 'CONFIRMED'
AND journey_date BETWEEN '2026-02-01' AND '2026-03-31';


-- PART 5: CREATE SINGLE-COLUMN INDEX
-- ==========================================

CREATE INDEX idx_train_no
ON railway_bookings(train_no);


-- Analyze table statistics

ANALYZE TABLE railway_bookings;


-- Query 1: Performance after single index

EXPLAIN
SELECT *
FROM railway_bookings
WHERE train_no = 12005;


-- Query 2: Performance after single index

EXPLAIN
SELECT *
FROM railway_bookings
WHERE train_no = 12005
AND booking_status = 'CONFIRMED'
AND journey_date BETWEEN '2026-02-01' AND '2026-03-31';


-- PART 6: CREATE COMPOSITE INDEX
-- ==========================================

CREATE INDEX idx_train_status_date
ON railway_bookings
(train_no, booking_status, journey_date);


-- Analyze table again

ANALYZE TABLE railway_bookings;


-- Query 2: Performance after composite index

EXPLAIN
SELECT *
FROM railway_bookings
WHERE train_no = 12005
AND booking_status = 'CONFIRMED'
AND journey_date BETWEEN '2026-02-01' AND '2026-03-31';


-- PART 7: CHECK ALL INDEXES
-- ==========================================

SHOW INDEX FROM railway_bookings;


-- PART 8: FINAL VERIFICATION
-- ==========================================

SELECT COUNT(*) AS total_bookings
FROM railway_bookings;

SELECT *
FROM railway_bookings
ORDER BY booking_id
LIMIT 10;
