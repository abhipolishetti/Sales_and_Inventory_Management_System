Sales and Inventory Management Reporting System

A robust SQL-based system designed to track sales, inventory, and customer behavior. 
The system utilizes advanced SQL techniques such as triggers, stored procedures, and indexes for optimal performance and data integrity.

Project Overview

This project includes several key features aimed at managing and reporting on sales and inventory data. 
By utilizing MySQL, stored procedures, triggers, and indexing, it provides an efficient solution for business operations, helping users view detailed sales data, 
track inventory status, and generate reports.

Key Features:
Triggers: 
  - An `AFTER INSERT` trigger ensures that there is enough stock available before an order is placed, preventing out-of-stock issues.
  
Stored Procedures: 
  - A stored procedure is used to retrieve detailed customer order history, improving modularity and query efficiency.
  
Indexes: 
  - Indexes on frequently queried columns (e.g., `CustomerID` and `ProductName`) enhance query performance and reduce response times for reports.

Technologies Used:
- MySQL: Relational database management system used for data storage and management.
- SQL: Query language used to interact with the database.
- Triggers: Automated actions for maintaining stock integrity and data consistency.
- Stored Procedures: Reusable blocks of SQL code for improving query performance and code reusability.
- Indexing: Used to speed up SELECT queries and improve overall performance.

