
--------------------------------------------- Part A --------------------------------------------

------- Part A - Step 1 --------
CREATE DATABASE KHAMAR_VAIBHAVI_TEST;


------- Part A - Step 2 --------
USE KHAMAR_VAIBHAVI_TEST;

----drop tables if already exists
DROP TABLE IF EXISTS dbo.OrderItems;
DROP TABLE IF EXISTS dbo.Products 
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Customers;

-- (1). Create table Customer
CREATE TABLE dbo.Customers (
	CustomerID varchar(5) PRIMARY KEY, 
	FirstName varchar(40),
	LastName varchar(40));

-- (2). Add the NOT NULL constraint
ALTER TABLE dbo.Customers ALTER COLUMN CustomerID varchar(5) NOT NULL;

-- (3). Create table Orders
CREATE TABLE dbo.Orders (
	OrderID int IDENTITY NOT NULL PRIMARY KEY, 
	CustomerID varchar(5) NOT NULL, 
	OrderDate datetime DEFAULT Current_Timestamp);

-- (4). Add the Foreign Key constraint
ALTER TABLE dbo.Orders ADD CONSTRAINT fk1 FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID);

-- (5). Create table Products 
CREATE TABLE dbo.Products (
	ProductID int IDENTITY, 
	Name varchar(40) NOT NULL,
	UnitPrice MONEY NOT NULL);

-- (6). Add the Primary Key constraint 
ALTER TABLE dbo.Products ADD CONSTRAINT pk1 PRIMARY KEY (ProductID);

ALTER TABLE dbo.Products ALTER COLUMN ProductID int NOT NULL; 

-- (7). Create table OrderItems
CREATE TABLE dbo.OrderItems (
	OrderID int NOT NULL REFERENCES dbo.Orders(OrderID),
	ProductID int NOT NULL REFERENCES dbo.Products(ProductID),
	UnitPrice money NOT NULL, 
	Quantity int NOT NULL CONSTRAINT PKOrderItem PRIMARY KEY CLUSTERED (OrderID, ProductID));

-- (8). Insert records in Customer table
INSERT dbo.Customers VALUES ('ABC', 'John', 'Doe'),
                            ('LMN', 'Matt', 'Hogan'),
                            ('OPQ', 'Ryan', 'Fox'),
                            ('RST', 'Bob', 'Tile'),
                            ('XYZ', 'John', 'Quil');
----                        
select * from dbo.Customers;

-- (9). Insert records in Orders table 
INSERT INTO dbo.Orders (CustomerID,OrderDate) VALUES ('XYZ','2020-05-16 03:24:11'),
       												('OPQ','2020-05-27 08:11:11'),
       												('ABC','2020-06-06 12:07:16'),
       												('LMN','2020-07-01 08:30:39'),
     												('RST','2029-07-10 04:04:11'); 
----     											
select * from dbo.Orders;
--INSERT INTO dbo.Orders (CustomerID) VALUES ('OPQ'),('ABC'),('LMN'),('RST'),('ABC');

-- (10). Insert a record in Orders table
INSERT dbo.Orders (CustomerID) VALUES ('ABC');
----
select * from dbo.Orders;
                           
-- (11). Insert records into products table
INSERT INTO dbo.Products(Name,UnitPrice) VALUES ('Book',10.00),
	                                          	('Bottle',8.00),
	                                        	('Pens',5.00),
	   											('table',30.00),
	   											('Chair',25.00);
----	   										
select * from dbo.Products;

-- (12). Insert records into OrderItems table
INSERT INTO dbo.OrderItems VALUES (1,4,30.00,1),
	                              (2,2,8.00,2),
	                              (3,3,5.00,3),
	                              (4,4,30.00,1),
	                              (5,5,25.00,1),
	                              (6,1,10.00,3);
----	                             
select * from dbo.OrderItems;

-- (13). SQL View CREAT, SELECT, DELETE
USE KHAMAR_VAIBHAVI_TEST;
------
CREATE VIEW vwCustomerOrderInfo 
AS
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName
FROM dbo.Orders o
INNER JOIN dbo.Customers c
ON c.CustomerID = o.CustomerID;
------
SELECT * FROM vwCustomerOrderInfo;
------
DROP VIEW vwCustomerOrderInfo;

-- (14). Select statement
SELECT * FROM dbo.Products 
WHERE Name = 'Bottle';

-- (15). Case
SELECT ProductID, Name,
	CASE WHEN UnitPrice < 10 THEN 'Inexpensive'
		 WHEN UnitPrice > 20 THEN 'Expensive'
		 ELSE 'Neutral'
	END AS 'PriceRange'
FROM dbo.Products;

-- (16). Like
SELECT *
FROM dbo.Customers
WHERE FirstName LIKE '%J%';

-- (17). NOT IN
SELECT *
FROM dbo.Customers
WHERE FirstName NOT IN ('John');

-- (18). Update
UPDATE dbo.Products
SET UnitPrice = 35.00
WHERE ProductID = 4;
----
select * from dbo.Products;

-- (19). Max
SELECT OrderID, ProductID, UnitPrice FROM dbo.OrderItems
WHERE UnitPrice = (SELECT max(UnitPrice) FROM dbo.OrderItems);

-- (20). Top 1 with ties
SELECT TOP 1 WITH TIES *
FROM dbo.OrderItems
ORDER BY UnitPrice DESC;

-- (21). Concate
SELECT CONCAT(FirstName, ' ', LastName) AS 'FullName'
FROM dbo.Customers;

-- (22). Delete a record
delete top (1) from dbo.OrderItems;
----
select * from dbo.OrderItems;

-- (23). Drop tables
DROP TABLE dbo.OrderItems;
DROP TABLE dbo.Products 
DROP TABLE dbo.Orders;
DROP TABLE IF EXISTS dbo.Customers;



------- Part A - Step 3 --------

----drop tables if already exists
DROP TABLE IF EXISTS TargetMailingLists;
DROP TABLE IF EXISTS TargetCustomers;
DROP TABLE IF EXISTS MailingLists;

USE KHAMAR_VAIBHAVI_TEST;

CREATE TABLE dbo.TargetCustomers (
	TargetID INT IDENTITY NOT NULL PRIMARY KEY,
	FirstName varchar(40) NOT NULL,
	LastName varchar(40) NOT NULL,
	Address varchar(40) NOT NULL,
	City varchar(40) NOT NULL,
	State varchar(40) NOT NULL,
	ZipCode INT NOT NULL);

CREATE TABLE dbo.MailingLists (
	MailingListsID INT IDENTITY NOT NULL PRIMARY KEY,
	MailingList varchar(30) NOT NULL);

CREATE TABLE dbo.TargetMailingLists (
	TargetID INT NOT NULL FOREIGN KEY REFERENCES dbo.TargetCustomers(TargetID),
	MailingListID INT NOT NULL FOREIGN KEY REFERENCES dbo.MailingLists(MailingListsID),
    CONSTRAINT PKTargetMailingLists PRIMARY KEY CLUSTERED (TargetID, MailingListID));
    
---------------------------	
DROP TABLE IF EXISTS TargetMailingLists;
DROP TABLE IF EXISTS TargetCustomers;
DROP TABLE IF EXISTS MailingLists;


--------------------------------------------- Part B --------------------------------------------
/* Using the content of AdventureWorks, write a query to retrieve
all unique customers with all salespersons each customer has dealt with. 
Exclude the customers who have never worked with a salesperson.
Sort the returned data by CustomerID in the descending order.
The result should have the following format.
Hint: Use the SalesOrderHeadrer table. */

USE AdventureWorks2008R2;

SELECT DISTINCT sh.CustomerID,
STUFF((SELECT DISTINCT ', '+ RTRIM(CAST(SalesPersonID AS char))  
       FROM Sales.SalesOrderHeader
       WHERE CustomerID = sh.CustomerID
       FOR XML PATH('')) , 1, 2, '') AS SalesPersonID
FROM Sales.SalesOrderHeader sh
WHERE SalesPersonID IS NOT NULL
ORDER BY sh.CustomerID DESC;

--------------------------------------------- Part C --------------------------------------------
/* Bill of Materials - Recursive */
/* The following code retrieves the components required for manufacturing
the "Mountain-500 Black, 48" (Product 992). Modify the code to retrieve 
the most expensive component(s) that cannot be manufactured internally.
Use the list price of a component to determine the most expensive component.
If there is a tie, your solutions must retrieve it. */

--907(106.50), 935(40.49), 948(106.50), 952(20.24) is not in assemblyid..so not manufractured internally

USE AdventureWorks2008R2;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
 SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
 b.EndDate, 0 AS ComponentLevel
 FROM Production.BillOfMaterials AS b
 WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL
UNION ALL
 SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
 bom.EndDate, ComponentLevel + 1
 FROM Production.BillOfMaterials AS bom
 INNER JOIN Parts AS p
 ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
)

SELECT temp.ComponentID, temp.Name, temp.ListPrice, temp.PerAssemblyQty, temp.ComponentLevel
FROM (
    SELECT AssemblyID, ComponentID, Name, PerAssemblyQty, ListPrice, ComponentLevel,
    RANK() OVER (ORDER BY MAX(ListPrice) DESC) AS [Ranking]
    FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
    WHERE ComponentID NOT IN (SELECT AssemblyID FROM Parts AS p)
    GROUP BY ComponentID,AssemblyID, Name, PerAssemblyQty, ListPrice, ComponentLevel
    --ORDER BY ComponentLevel, AssemblyID, ComponentID
 ) AS temp
WHERE temp.Ranking = 1
ORDER BY ComponentID;




