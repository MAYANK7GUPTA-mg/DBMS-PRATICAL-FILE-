-- EXPERIMENT 8: SESSION A
-- Open this file in one MySQL connection. Run one labeled step at a time,
-- switching to session_b.sql at each WAIT marker.
-- Run exp08.sql once before starting the sessions.

-- DIRTY READ: A1. Run this block, then switch to Session B / Dirty read B1.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
UPDATE Bank_Account
SET Balance = Balance - 100.00
WHERE AccountID = 2001;
-- WAIT: Session B can now observe this uncommitted balance.

-- DIRTY READ: A2. Run only after Session B has read the uncommitted value.
ROLLBACK;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2001;

-- NONREPEATABLE READ: A1. Run this block, then switch to Session B / B1.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2002;
-- WAIT: Session B updates account 2002 and commits.

-- NONREPEATABLE READ: A2. Run after Session B / B1 has committed.
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2002;
COMMIT;

-- PHANTOM READ AT READ COMMITTED: A1. Run this block, then switch to B1.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT AccountID, Balance
FROM Bank_Account
WHERE AccountID BETWEEN 2090 AND 2099 AND Balance >= 500.00
ORDER BY AccountID;
-- WAIT: Session B inserts account 2092 and commits.

-- PHANTOM READ AT READ COMMITTED: A2. Run after Session B / B1 has committed.
SELECT AccountID, Balance
FROM Bank_Account
WHERE AccountID BETWEEN 2090 AND 2099 AND Balance >= 500.00
ORDER BY AccountID;
COMMIT;

-- PHANTOM CONTRAST AT REPEATABLE READ:
-- Before this test, delete account 2092 outside any active transaction.
-- Run this block, then Session B / Repeatable-read phantom B1, then A2.
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT AccountID, Balance
FROM Bank_Account
WHERE AccountID BETWEEN 2090 AND 2099 AND Balance >= 500.00
ORDER BY AccountID;
-- WAIT: Session B inserts account 2092 and commits.

-- REPEATABLE READ: A2. Run after Session B / B1 has committed.
SELECT AccountID, Balance
FROM Bank_Account
WHERE AccountID BETWEEN 2090 AND 2099 AND Balance >= 500.00
ORDER BY AccountID;
COMMIT;

-- SERIALIZABLE RANGE READ: A1. Ensure accounts 2092 and 2098 are absent.
-- Run this block, then Session B / Serializable range read B1.
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT AccountID, Balance
FROM Bank_Account
WHERE AccountID BETWEEN 2090 AND 2099 AND Balance >= 500.00
ORDER BY AccountID;
-- WAIT: Session B's insert of account 2098 should block on this range.

-- SERIALIZABLE RANGE READ: A2. Run while Session B / B1 is waiting.
COMMIT;
-- Session B's insert can now continue and commit.

-- LOST UPDATE: A1. Run this block, then Session B / B1.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT AccountID, Balance FROM Bank_Account WHERE AccountID = 2003;
-- Application reads 250.00 and calculates 225.00 (withdraw 25.00).
-- WAIT: Session B also reads 250.00 and calculates 200.00.

-- LOST UPDATE: A2. Run after Session B / B1 has read the original balance.
UPDATE Bank_Account SET Balance = 225.00 WHERE AccountID = 2003;
COMMIT;
-- WAIT: Session B now runs Lost update B2 with its stale value of 200.00.
