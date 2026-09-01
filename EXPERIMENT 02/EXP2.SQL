-- ============================================================
-- DBMS EXPERIMENT 2
-- ER DIAGRAM TO RELATIONAL SCHEMA
-- Indian E-Commerce Platform
-- ============================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS Indian_Ecommerce;
USE Indian_Ecommerce;


-- ============================================================
-- 1. CUSTOMER TABLE
-- ============================================================

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    DateOfBirth DATE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) UNIQUE
);


-- ============================================================
-- 2. SELLER TABLE
-- ============================================================

CREATE TABLE Seller (
    SellerID INT PRIMARY KEY,
    SellerName VARCHAR(100) NOT NULL,
    GSTIN VARCHAR(20) NOT NULL UNIQUE,
    BankDetails VARCHAR(100)
);


-- ============================================================
-- 3. CATEGORY TABLE
-- ============================================================

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);


-- ============================================================
-- 4. ADDRESS TABLE
-- Customer can have multiple addresses
-- ON DELETE CASCADE:
-- If customer is deleted, their addresses are deleted.
-- ============================================================

CREATE TABLE Address (
    AddressID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    HouseNo VARCHAR(50) NOT NULL,
    Street VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Pincode VARCHAR(10) NOT NULL,
    AddressType VARCHAR(20),

    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);


-- ============================================================
-- 5. PRODUCT TABLE
-- Seller and Category are referenced using Foreign Keys
-- ON DELETE SET NULL:
-- Product remains if Seller/Category is deleted.
-- ============================================================

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    Description VARCHAR(255),

    SellerID INT,
    CategoryID INT,

    FOREIGN KEY (SellerID)
        REFERENCES Seller(SellerID)
        ON DELETE SET NULL,

    FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON DELETE SET NULL,

    CHECK (Price >= 0),
    CHECK (Stock >= 0)
);


-- ============================================================
-- 6. ORDER TABLE
-- CustomerID is a Foreign Key
-- ON DELETE SET NULL:
-- Order remains even if customer is deleted.
-- ============================================================

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE SET NULL,

    CHECK (TotalAmount >= 0)
);


-- ============================================================
-- 7. ORDER ITEM TABLE
-- Weak Entity
-- Composite Primary Key = OrderID + ProductID
-- ON DELETE CASCADE:
-- If an order is deleted, its order items are deleted.
-- ============================================================

CREATE TABLE OrderItem (
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (OrderID, ProductID),

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE,

    CHECK (Quantity > 0),
    CHECK (UnitPrice >= 0)
);


-- ============================================================
-- 8. PAYMENT TABLE
-- One Payment is associated with one Order
-- ============================================================

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentStatus VARCHAR(30) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,

    CHECK (Amount >= 0)
);


-- ============================================================
-- 9. DELIVERY TABLE
-- One Delivery is associated with one Order
-- ============================================================

CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    DeliveryDate DATE,
    DeliveryStatus VARCHAR(30) NOT NULL,
    TrackingNumber VARCHAR(50) UNIQUE,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);


-- ============================================================
-- 10. PHYSICAL PRODUCT
-- Product Specialization
-- ============================================================

CREATE TABLE PhysicalProduct (
    ProductID INT PRIMARY KEY,
    Weight DECIMAL(8,2),
    Dimensions VARCHAR(50),
    WarrantyPeriod VARCHAR(50),

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE
);


-- ============================================================
-- 11. DIGITAL PRODUCT
-- Product Specialization
-- ============================================================

CREATE TABLE DigitalProduct (
    ProductID INT PRIMARY KEY,
    FileFormat VARCHAR(30),
    FileSize DECIMAL(10,2),
    DownloadURL VARCHAR(255) UNIQUE,

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE
);


-- ============================================================
-- INSERT SAMPLE DATA
-- ============================================================


-- CUSTOMER DATA

INSERT INTO Customer
(CustomerID, CustomerName, Gender, DateOfBirth, Email, Phone)
VALUES
(1, 'Rahul Sharma', 'Male', '2002-05-15',
 'rahul@gmail.com', '9876543210'),

(2, 'Priya Singh', 'Female', '2001-08-20',
 'priya@gmail.com', '9876543211'),

(3, 'Aman Gupta', 'Male', '2003-02-10',
 'aman@gmail.com', '9876543212');


-- SELLER DATA

INSERT INTO Seller
(SellerID, SellerName, GSTIN, BankDetails)
VALUES
(101, 'Tech World India', 'GSTIN101XYZ', 'HDFC Bank'),
(102, 'Fashion Hub', 'GSTIN102XYZ', 'SBI'),
(103, 'Digital Store', 'GSTIN103XYZ', 'ICICI Bank');


-- CATEGORY DATA

INSERT INTO Category
(CategoryID, CategoryName, Description)
VALUES
(201, 'Electronics', 'Electronic products'),
(202, 'Fashion', 'Clothing and accessories'),
(203, 'Digital Products', 'Digital goods');


-- ADDRESS DATA

INSERT INTO Address
(AddressID, CustomerID, HouseNo, Street, City, State, Pincode, AddressType)
VALUES
(301, 1, '12A', 'MG Road', 'Delhi', 'Delhi', '110001', 'Home'),

(302, 1, '45B', 'Park Street', 'Kolkata', 'West Bengal',
 '700016', 'Office'),

(303, 2, '22', 'FC Road', 'Pune', 'Maharashtra',
 '411004', 'Home'),

(304, 3, '18', 'MG Road', 'Bengaluru', 'Karnataka',
 '560001', 'Home');


-- PRODUCT DATA

INSERT INTO Product
(ProductID, ProductName, Price, Stock, Description, SellerID, CategoryID)
VALUES
(401, 'Laptop', 55000.00, 10,
 'Business Laptop', 101, 201),

(402, 'Smartphone', 25000.00, 20,
 'Android Smartphone', 101, 201),

(403, 'T-Shirt', 799.00, 50,
 'Cotton T-Shirt', 102, 202),

(404, 'E-Book', 499.00, 100,
 'Programming E-Book', 103, 203);


-- PHYSICAL PRODUCT DATA

INSERT INTO PhysicalProduct
(ProductID, Weight, Dimensions, WarrantyPeriod)
VALUES
(401, 1.50, '35x25x2 cm', '2 Years'),

(402, 0.20, '16x8x1 cm', '1 Year'),

(403, 0.30, '30x25x2 cm', 'No Warranty');


-- DIGITAL PRODUCT DATA

INSERT INTO DigitalProduct
(ProductID, FileFormat, FileSize, DownloadURL)
VALUES
(404, 'PDF', 25.50,
 'https://example.com/ebook/programming');


-- ORDER DATA

INSERT INTO Orders
(OrderID, CustomerID, OrderDate, OrderStatus, TotalAmount)
VALUES
(501, 1, '2026-09-01', 'Confirmed', 55000.00),

(502, 2, '2026-09-01', 'Shipped', 25799.00),

(503, 3, '2026-09-01', 'Processing', 499.00);


-- ORDER ITEM DATA

INSERT INTO OrderItem
(OrderID, ProductID, Quantity, UnitPrice)
VALUES
(501, 401, 1, 55000.00),

(502, 402, 1, 25000.00),

(502, 403, 1, 799.00),

(503, 404, 1, 499.00);


-- PAYMENT DATA

INSERT INTO Payment
(PaymentID, OrderID, Amount, PaymentDate, PaymentStatus)
VALUES
(601, 501, 55000.00, '2026-09-01', 'Paid'),

(602, 502, 25799.00, '2026-09-01', 'Paid'),

(603, 503, 499.00, '2026-09-01', 'Pending');


-- DELIVERY DATA

INSERT INTO Delivery
(DeliveryID, OrderID, DeliveryDate, DeliveryStatus, TrackingNumber)
VALUES
(701, 501, '2026-09-04', 'Delivered', 'TRK001'),

(702, 502, '2026-09-05', 'In Transit', 'TRK002'),

(703, 503, NULL, 'Processing', 'TRK003');


-- ============================================================
-- DISPLAY DATA
-- ============================================================

SELECT * FROM Customer;

SELECT * FROM Seller;

SELECT * FROM Category;

SELECT * FROM Address;

SELECT * FROM Product;

SELECT * FROM Orders;

SELECT * FROM OrderItem;

SELECT * FROM Payment;

SELECT * FROM Delivery;

SELECT * FROM PhysicalProduct;

SELECT * FROM DigitalProduct;


-- ============================================================
-- REFERENTIAL INTEGRITY VIOLATIONS
-- ============================================================

-- 1. FOREIGN KEY VIOLATION
-- CustomerID 999 does not exist.

INSERT INTO Orders
(OrderID, CustomerID, OrderDate, OrderStatus, TotalAmount)
VALUES
(504, 999, '2026-09-01', 'Confirmed', 1000.00);


-- 2. FOREIGN KEY VIOLATION
-- ProductID 999 does not exist.

INSERT INTO OrderItem
(OrderID, ProductID, Quantity, UnitPrice)
VALUES
(501, 999, 1, 1000.00);


-- 3. NOT NULL VIOLATION
-- ProductName cannot be NULL.

INSERT INTO Product
(ProductID, ProductName, Price, Stock, SellerID, CategoryID)
VALUES
(405, NULL, 1000.00, 10, 101, 201);


-- 4. UNIQUE CONSTRAINT VIOLATION
-- Email already exists.

INSERT INTO Customer
(CustomerID, CustomerName, Gender, Email, Phone)
VALUES
(4, 'Rohit Kumar', 'Male',
 'rahul@gmail.com', '9999999999');


-- 5. PRIMARY KEY VIOLATION
-- CustomerID 1 already exists.

INSERT INTO Customer
(CustomerID, CustomerName, Gender, Email, Phone)
VALUES
(1, 'Duplicate User', 'Male',
 'duplicate@gmail.com', '9999999999');


-- 6. COMPOSITE KEY VIOLATION
-- OrderID 501 + ProductID 401 already exists.

INSERT INTO OrderItem
(OrderID, ProductID, Quantity, UnitPrice)
VALUES
(501, 401, 2, 50000.00);


-- ============================================================
-- DEMONSTRATING ON DELETE CASCADE
-- ============================================================

-- Delete Order 501.
-- Its OrderItem, Payment and Delivery records
-- will also be deleted automatically.

DELETE FROM Orders
WHERE OrderID = 501;


-- Check related records

SELECT * FROM OrderItem
WHERE OrderID = 501;

SELECT * FROM Payment
WHERE OrderID = 501;

SELECT * FROM Delivery
WHERE OrderID = 501;


-- ============================================================
-- DEMONSTRATING ON DELETE SET NULL
-- ============================================================

-- Delete Seller 101.
-- Products belonging to Seller 101 will remain,
-- but SellerID will become NULL.

DELETE FROM Seller
WHERE SellerID = 101;


-- Check products

SELECT ProductID, ProductName, SellerID
FROM Product;


-- Delete Category 201.
-- Products belonging to Category 201 will remain,
-- but CategoryID will become NULL.

DELETE FROM Category
WHERE CategoryID = 201;


-- Check products

SELECT ProductID, ProductName, CategoryID
FROM Product;


-- ============================================================
-- END OF EXPERIMENT
-- ============================================================