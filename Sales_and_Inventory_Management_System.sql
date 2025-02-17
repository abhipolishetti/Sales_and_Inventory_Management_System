create database Sales_and_Inventory_Management_System;
use Sales_and_Inventory_Management_System;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY auto_increment,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    Address varchar(100)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY auto_increment,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2) CHECK (Price > 0),
    StockQuantity INT CHECK (StockQuantity >= 0)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT CHECK (Quantity > 0),
    Subtotal DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Trigger to Calculate the Subtotal
DELIMITER $$

CREATE TRIGGER before_orderdetails_insert
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE product_price DECIMAL(10,2);

    -- Get the price of the product from the Products table
    SELECT Price INTO product_price
    FROM Products
    WHERE ProductID = NEW.ProductID;

    -- Calculate the Subtotal by multiplying Quantity by the product's price
    SET NEW.Subtotal = NEW.Quantity * product_price;
END$$

DELIMITER ;

INSERT INTO Customers (Name, Email, Phone, Address)
VALUES 
('Alice Johnson', 'alice.johnson@example.com', '111-222-3333', '789 Maple Drive'),
('Bob Brown', 'bob.brown@example.com', '444-555-6666', '321 Pine Road'),
('Charlie White', 'charlie.white@example.com', '555-666-7777', '654 Birch Blvd'),
('David Green', 'david.green@example.com', '888-999-0000', '987 Cedar Lane');

INSERT INTO Products (ProductName, Category, Price, StockQuantity)
VALUES 
('Tablet', 'Electronics', 300.00, 120),
('Smartwatch', 'Electronics', 150.00, 80),
('Chair', 'Furniture', 100.00, 50),
('Desk', 'Furniture', 200.00, 30),
('Headphones', 'Electronics', 50.00, 200),
('Microwave', 'Appliances', 120.00, 60),
('Refrigerator', 'Appliances', 600.00, 40);

INSERT INTO Orders (CustomerID, TotalAmount)
VALUES 
(1, 450.00),  -- Alice's order
(2, 550.00),  -- Bob's order
(3, 800.00),  -- Charlie's order
(4, 400.00);  -- David's order

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES 
(1, 1, 1),  -- Alice ordered 1 Tablet
(1, 3, 2),  -- Alice ordered 2 Chairs
(2, 4, 1),  -- Bob ordered 1 Desk
(2, 2, 2),  -- Bob ordered 2 Smartwatches
(3, 5, 1),  -- Charlie ordered 1 Headphone
(3, 6, 2),  -- Charlie ordered 2 Microwaves
(4, 7, 1);  -- David ordered 1 Refrigerator

-- show columns from Orders; 

SELECT o.OrderID, o.OrderDate 
FROM Orders o
ORDER BY o.OrderDate DESC;

-- Stored Procedure: Get Customer Order History
DELIMITER $$

CREATE PROCEDURE GetCustomerOrderHistory(IN CustomerID INT)
BEGIN
    SELECT 
        o.OrderID, 
        o.OrderDate, 
        p.ProductName, 
        od.Quantity, 
        od.Subtotal
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE o.CustomerID = CustomerID
    ORDER BY o.OrderDate DESC;
END$$

DELIMITER ;

-- Trigger: Prevent Orders When Product is Out of Stock
DELIMITER $$

CREATE TRIGGER PreventOutOfStock
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    -- Check if the stock quantity is sufficient
    IF EXISTS (
        SELECT 1
        FROM Products p
        WHERE p.ProductID = NEW.ProductID
        AND p.StockQuantity < NEW.Quantity
    ) THEN
        -- Raise an error if not enough stock is available
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available!';
    END IF;
END$$

DELIMITER ;

-- Creating Index on CustomerID Column in Orders Table:
CREATE INDEX idx_customer_orders ON Orders(CustomerID);

-- Creating Index on ProductName Column in Products Table:
CREATE INDEX idx_product_search ON Products(ProductName);

-- Top 3 Best-Selling Products:
SELECT p.ProductName, SUM(od.Quantity) AS TotalSold
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSold DESC
LIMIT 3;

-- total amount spent by each customer.
SELECT c.Name AS CustomerName, SUM(o.TotalAmount) AS TotalSpent
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY TotalSpent DESC;

-- Low Stock Products:
SELECT p.ProductName, p.StockQuantity
FROM Products p
WHERE p.StockQuantity < 20
ORDER BY p.StockQuantity ASC;

-- Inventory Status:
SELECT p.ProductName, p.StockQuantity, COALESCE(SUM(od.Quantity), 0) AS TotalSold
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName, p.StockQuantity
ORDER BY p.ProductName;

-- number of orders and total revenue for each day.
SELECT o.OrderDate, COUNT(o.OrderID) AS OrdersCount, SUM(o.TotalAmount) AS TotalRevenue
FROM Orders o
GROUP BY o.OrderDate
ORDER BY o.OrderDate;