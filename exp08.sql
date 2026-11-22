-- EXPERIMENT 8: BANKING TRANSACTIONS AND ISOLATION
-- MySQL 8.0. Run this setup/demo script in the schema used for the practical.
-- It recreates only the Bank_Account and Bank_Transaction tables.

DROP TABLE IF EXISTS Bank_Transaction;
DROP TABLE IF EXISTS Bank_Account;

CREATE TABLE Bank_Account (
    AccountID INT PRIMARY KEY,
    AccountName VARCHAR(40) NOT NULL,
    Balance DECIMAL(12, 2) NOT NULL,
    CONSTRAINT chk_bank_account_balance CHECK (Balance >= 0)
) ENGINE = InnoDB;

CREATE TABLE Bank_Transaction (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    FromAccount INT NOT NULL,
    ToAccount INT NOT NULL,
    Amount DECIMAL(12, 2) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_bank_transaction_amount CHECK (Amount > 0),
    CONSTRAINT fk_bank_transaction_from
        FOREIGN KEY (FromAccount) REFERENCES Bank_Account(AccountID),
    CONSTRAINT fk_bank_transaction_to
        FOREIGN KEY (ToAccount) REFERENCES Bank_Account(AccountID)
) ENGINE = InnoDB;

INSERT INTO Bank_Account (AccountID, AccountName, Balance) VALUES
(1001, 'Asha', 1000.00),
(1002, 'Ravi', 500.00),
(1003, 'Neha', 250.00),
(2001, 'Dirty Read Test', 1000.00),
(2002, 'Nonrepeatable Read Test', 500.00),
(2003, 'Lost Update Test', 250.00),
(2091, 'Phantom Read Test', 800.00);

-- 1. Successful transfer: BEGIN and COMMIT make both balance changes atomic.
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 100.00
WHERE AccountID = 1001 AND Balance >= 100.00;

UPDATE Bank_Account
SET Balance = Balance + 100.00
WHERE AccountID = 1002;

INSERT INTO Bank_Transaction (FromAccount, ToAccount, Amount)
VALUES (1001, 1002, 100.00);

COMMIT;

SELECT AccountID, AccountName, Balance
FROM Bank_Account
WHERE AccountID IN (1001, 1002)
ORDER BY AccountID;

SELECT TransactionID, FromAccount, ToAccount, Amount, CreatedAt
FROM Bank_Transaction
ORDER BY TransactionID;

-- 2. Partial batch failure: keep the first transfer, undo only the second.
-- The missing destination (9999) affects zero rows. Check ROW_COUNT() before
-- deciding whether to keep the current transfer; here it is a failed item.
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 50.00
WHERE AccountID = 1001 AND Balance >= 50.00;

UPDATE Bank_Account
SET Balance = Balance + 50.00
WHERE AccountID = 1002;

INSERT INTO Bank_Transaction (FromAccount, ToAccount, Amount)
VALUES (1001, 1002, 50.00);

SAVEPOINT before_optional_transfer;

UPDATE Bank_Account
SET Balance = Balance - 25.00
WHERE AccountID = 1001 AND Balance >= 25.00;

UPDATE Bank_Account
SET Balance = Balance + 25.00
WHERE AccountID = 9999;

SELECT ROW_COUNT() AS RowsUpdatedForMissingDestination;

ROLLBACK TO SAVEPOINT before_optional_transfer;
COMMIT;

SELECT AccountID, AccountName, Balance
FROM Bank_Account
WHERE AccountID IN (1001, 1002)
ORDER BY AccountID;

SELECT TransactionID, FromAccount, ToAccount, Amount
FROM Bank_Transaction
ORDER BY TransactionID;

-- 3. Full rollback: an insufficient-funds debit changes zero rows, so cancel
-- the whole transaction. The account remains unchanged.
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 100000.00
WHERE AccountID = 1001 AND Balance >= 100000.00;

SELECT ROW_COUNT() AS RowsDebitedForInsufficientFunds;

ROLLBACK;

SELECT AccountID, AccountName, Balance
FROM Bank_Account
WHERE AccountID = 1001;

-- Two-session isolation/concurrency demonstrations are in:
-- EXPERIMENT 08/session_a.sql
-- EXPERIMENT 08/session_b.sql
-- Run their marked steps manually in separate MySQL connections.