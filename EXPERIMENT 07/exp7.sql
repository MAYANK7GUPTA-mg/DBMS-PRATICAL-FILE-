
-- EXPERIMENT 7: SALES TABLE NORMALIZATION
-- UNF TO 1NF, 2NF, 3NF AND BCNF

-- STEP 1: Remove old tables
DROP TABLE IF EXISTS Sales_BCNF_OrderItem;
DROP TABLE IF EXISTS Sales_BCNF_Order;
DROP TABLE IF EXISTS Sales_BCNF_Product;
DROP TABLE IF EXISTS Sales_BCNF_Customer;
DROP TABLE IF EXISTS Sales_3NF_OrderItem;
DROP TABLE IF EXISTS Sales_3NF_Order;
DROP TABLE IF EXISTS Sales_3NF_Product;
DROP TABLE IF EXISTS Sales_3NF_Customer;
DROP TABLE IF EXISTS Sales_2NF_OrderItem;
DROP TABLE IF EXISTS Sales_2NF_Order;
DROP TABLE IF EXISTS Sales_2NF_Product;
DROP TABLE IF EXISTS Sales_1NF;
DROP TABLE IF EXISTS Sales_UNF;

-- STEP 2: UNF TABLE
CREATE TABLE Sales_UNF (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    CustomerName VARCHAR(30),
    Product1ID INT,
    Product1Name VARCHAR(30),
    Product1Qty INT,
    Product2ID INT,
    Product2Name VARCHAR(30),
    Product2Qty INT
);

INSERT INTO Sales_UNF VALUES
(1001, 1, 'Asha', 501, 'Pen', 2, 502, 'Notebook', 1),
(1002, 2, 'Ravi', 502, 'Notebook', 3, NULL, NULL, NULL),
(1003, 3, 'Neha', 503, 'Pencil', 5, NULL, NULL, NULL);

-- FUNCTIONAL DEPENDENCIES:
-- OrderID -> CustomerID
-- CustomerID -> CustomerName
-- ProductID -> ProductName
-- (OrderID, ProductID) -> Quantity

-- STEP 3: FIRST NORMAL FORM (1NF)
CREATE TABLE Sales_1NF (
    OrderID INT,
    CustomerID INT,
    CustomerName VARCHAR(30),
    ProductID INT,
    ProductName VARCHAR(30),
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF VALUES
(1001, 1, 'Asha', 501, 'Pen', 2),
(1001, 1, 'Asha', 502, 'Notebook', 1),
(1002, 2, 'Ravi', 502, 'Notebook', 3),
(1003, 3, 'Neha', 503, 'Pencil', 5);

-- STEP 4: SECOND NORMAL FORM (2NF)
-- Separate partial dependencies.

CREATE TABLE Sales_2NF_Order (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    CustomerName VARCHAR(30)
);

CREATE TABLE Sales_2NF_Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(30)
);

CREATE TABLE Sales_2NF_OrderItem (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Sales_2NF_Order(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Sales_2NF_Product(ProductID)
);

INSERT INTO Sales_2NF_Order VALUES
(1001, 1, 'Asha'),
(1002, 2, 'Ravi'),
(1003, 3, 'Neha');

INSERT INTO Sales_2NF_Product VALUES
(501, 'Pen'),
(502, 'Notebook'),
(503, 'Pencil');

INSERT INTO Sales_2NF_OrderItem VALUES
(1001, 501, 2),
(1001, 502, 1),
(1002, 502, 3),
(1003, 503, 5);

-- STEP 5: THIRD NORMAL FORM (3NF)
-- Remove transitive dependency:
-- OrderID -> CustomerID -> CustomerName

CREATE TABLE Sales_3NF_Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(30)
);

CREATE TABLE Sales_3NF_Order (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID)
        REFERENCES Sales_3NF_Customer(CustomerID)
);

CREATE TABLE Sales_3NF_Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(30)
);

CREATE TABLE Sales_3NF_OrderItem (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Sales_3NF_Order(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Sales_3NF_Product(ProductID)
);

INSERT INTO Sales_3NF_Customer VALUES
(1, 'Asha'),
(2, 'Ravi'),
(3, 'Neha');

INSERT INTO Sales_3NF_Order VALUES
(1001, 1),
(1002, 2),
(1003, 3);

INSERT INTO Sales_3NF_Product VALUES
(501, 'Pen'),
(502, 'Notebook'),
(503, 'Pencil');

INSERT INTO Sales_3NF_OrderItem VALUES
(1001, 501, 2),
(1001, 502, 1),
(1002, 502, 3),
(1003, 503, 5);

-- STEP 6: BCNF
-- Under the given dependencies, the 3NF decomposition
-- is already in BCNF. Create BCNF copies for verification.

CREATE TABLE Sales_BCNF_Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(30)
);

CREATE TABLE Sales_BCNF_Order (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID)
        REFERENCES Sales_BCNF_Customer(CustomerID)
);

CREATE TABLE Sales_BCNF_Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(30)
);

CREATE TABLE Sales_BCNF_OrderItem (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Sales_BCNF_Order(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Sales_BCNF_Product(ProductID)
);

INSERT INTO Sales_BCNF_Customer
SELECT * FROM Sales_3NF_Customer;

INSERT INTO Sales_BCNF_Order
SELECT * FROM Sales_3NF_Order;

INSERT INTO Sales_BCNF_Product
SELECT * FROM Sales_3NF_Product;

INSERT INTO Sales_BCNF_OrderItem
SELECT * FROM Sales_3NF_OrderItem;

-- STEP 7: DISPLAY NORMALIZED TABLES
SELECT * FROM Sales_3NF_Customer;
SELECT * FROM Sales_3NF_Order;
SELECT * FROM Sales_3NF_Product;
SELECT * FROM Sales_3NF_OrderItem;

-- STEP 8: LOSSLESS JOIN VERIFICATION
SELECT
    o.OrderID,
    c.CustomerID,
    c.CustomerName,
    p.ProductID,
    p.ProductName,
    i.Quantity
FROM Sales_3NF_Order o
JOIN Sales_3NF_Customer c
    ON o.CustomerID = c.CustomerID
JOIN Sales_3NF_OrderItem i
    ON o.OrderID = i.OrderID
JOIN Sales_3NF_Product p
    ON i.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID;

-- STEP 9: COMPARE ORIGINAL AND RECONSTRUCTED ROW COUNTS
SELECT COUNT(*) AS Original_Rows
FROM Sales_1NF;

SELECT COUNT(*) AS Reconstructed_Rows
FROM Sales_3NF_Order o
JOIN Sales_3NF_Customer c
    ON o.CustomerID = c.CustomerID
JOIN Sales_3NF_OrderItem i
    ON o.OrderID = i.OrderID
JOIN Sales_3NF_Product p
    ON i.ProductID = p.ProductID;

-- STEP 10: DEPENDENCY PRESERVATION CHECKS

-- CustomerID -> CustomerName
SELECT CustomerID,
       COUNT(DISTINCT CustomerName) AS Name_Count
FROM Sales_3NF_Customer
GROUP BY CustomerID;

-- OrderID -> CustomerID
SELECT OrderID,
       COUNT(DISTINCT CustomerID) AS Customer_Count
FROM Sales_3NF_Order
GROUP BY OrderID;

-- ProductID -> ProductName
SELECT ProductID,
       COUNT(DISTINCT ProductName) AS Product_Count
FROM Sales_3NF_Product
GROUP BY ProductID;

-- (OrderID, ProductID) -> Quantity
SELECT OrderID, ProductID,
       COUNT(DISTINCT Quantity) AS Quantity_Count
FROM Sales_3NF_OrderItem
GROUP BY OrderID, ProductID;
