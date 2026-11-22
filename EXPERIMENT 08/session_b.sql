-- EXPERIMENT 8: SESSION B
-- Open this file in a second MySQL connection to the same schema.
-- Run one labeled step at a time, following the order in readme.md.

-- DIRTY READ: B1. Run while Session A has updated account 2001 but not rolled back.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2001;
COMMIT;
-- Expected during A's open transaction: 900.00 (uncommitted).
-- After A rolls back, a new SELECT should show 1000.00.

-- NONREPEATABLE READ: B1. Run while Session A's transaction is open.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
UPDATE Bank_Account SET Balance = Balance + 50.00 WHERE AccountID = 2002;
COMMIT;
-- Session A's first read was 500.00; its next read should be 550.00.

-- PHANTOM READ AT READ COMMITTED: B1.
-- Run while Session A is between Phantom read A1 and A2.
BEGIN;
INSERT INTO Bank_Account (AccountID, AccountName, Balance)
VALUES (2092, 'Phantom Row', 700.00);
COMMIT;

-- PHANTOM CONTRAST AT REPEATABLE READ: B1.
-- Run while Session A's REPEATABLE READ transaction is open.
BEGIN;
INSERT INTO Bank_Account (AccountID, AccountName, Balance)
VALUES (2092, 'Phantom Row', 700.00);
COMMIT;
-- Session A's second consistent read should retain its original snapshot.
-- Ensure account 2092 was deleted before starting this contrast.

-- SERIALIZABLE RANGE READ: B1.
-- Run while Session A's SERIALIZABLE range-read transaction is open.
-- This INSERT should wait until Session A commits.
BEGIN;
INSERT INTO Bank_Account (AccountID, AccountName, Balance)
VALUES (2098, 'Serializable Test', 700.00);
COMMIT;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2098;

-- LOST UPDATE: B1. Run while Session A is in Lost update A1, before A2.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2003;
-- Application reads 250.00 and calculates 200.00 (withdraw 50.00).
-- WAIT: Session A writes 225.00 and commits (Lost update A2).

-- LOST UPDATE: B2. Run after Session A commits.
UPDATE Bank_Account SET Balance = 200.00 WHERE AccountID = 2003;
COMMIT;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2003;
-- Final 200.00 overwrites A's 225.00; correct combined balance is 175.00.
