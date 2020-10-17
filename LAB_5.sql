
USE KHAMAR_VAIBHAVI_TEST;

------------------------------------------------------- Lab 5-1 -------------------------------------------------------
/* Create a function in your own database that takes two parameters:
1) A year parameter
2) A month parameter
The function then calculates and returns the total sale for the requested year and month. 
If there was no sale for the requested period, returns 0.
Hints: 
a) Use the TotalDue column of the Sales.SalesOrderHeader table in an AdventureWorks database
   for calculating the total sale.
b) The year and month parameters should use the INT data type.
c) Make sure the function returns 0 if there was no sale in the database for the requested period. */


CREATE FUNCTION salesByMonthYear
(@month int, @year int)
RETURNS MONEY
AS
BEGIN 
	DECLARE @sale MONEY;
	SELECT @sale = isnull( sum(TotalDue) , 0)
	   FROM AdventureWorks2008R2.sales.salesOrderHeader
	   WHERE MONTH(orderDate) = @month AND YEAR(OrderDate) = @year
	RETURN @sale;
END
	
-- Test run --
SELECT dbo.salesByMonthYear(1, 2007);
SELECT dbo.salesByMonthYear(3, 2015);
SELECT dbo.salesByMonthYear(1, 2008);

-- Drop Function --
DROP FUNCTION dbo.salesByMonthYear;


----------- OR -------------

CREATE FUNCTION dbo.totalSalesByMonthYear
(@month INT ,@year INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @totalSale FLOAT;
	IF EXISTS (SELECT TotalDue
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @year AND MONTH(OrderDate) = @month)
	  SELECT @totalSale = sum(TotalDue)
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = @year AND MONTH(OrderDate) = @month;
	ELSE
		BEGIN
			SET @totalSale = 0.0;
		END
	RETURN @totalSale;
END;

-- Test Function
SELECT dbo.totalSalesByMonthYear(1,2007);
SELECT dbo.totalSalesByMonthYear(3,2015);

-- Drop Function
DROP FUNCTION dbo.totalSalesByMonthYear;


/*
SELECT TotalDue, OrderDate
		FROM AdventureWorks2008R2.sales.salesOrderHeader
		WHERE YEAR(OrderDate) = 2015 AND MONTH(OrderDate) = 3;
		*/


------------------------------------------------------- Lab 5-2 -------------------------------------------------------
/*Create a table in your own database using the following statement.
CREATE TABLE DateRange (DateID INT IDENTITY, DateValue DATE, Year INT, Quarter INT, Month INT, DayOfWeek INT);
Write a stored procedure in your own database that accepts two parameters:
1) A starting date
2) The number of the consecutive dates beginning with the starting date
The stored procedure then populates all columns of the DateRange table according to the two provided parameters.*/

CREATE TABLE DateRange 
(DateID INT IDENTITY,
 DateValue DATE, 
 Year INT, 
 Quarter INT, 
 Month INT, 
 DayOfWeek INT);


CREATE PROCEDURE dbo.populateDate
@startdate DATE, @numofdays INT
AS
BEGIN
  WHILE @numofdays <>0
    BEGIN
      INSERT INTO dbo.DateRange (DateValue, Year, Quarter, Month, DayOfWeek)
      SELECT @startdate, YEAR(@startdate), DATEPART(q, @startdate), MONTH(@startdate), DATEPART(dw, @startdate)	       
      SET @startdate = DATEADD(d, 1, @startdate); --increasing 1 day starting from startdate 
      SET @numofdays = @numofdays -1;
    END
END

-- Test Procedure --
DECLARE @startdate DATE;
DECLARE @numofdays INT;
SET @startdate = GETDATE();
--SET @startdate = '1-1-2020';
SET @numofdays = 7;
EXEC dbo.populateDate @startdate,@numofdays;
SELECT * FROM dbo.DateRange;


-- Drop Procedure & Table --
DROP PROCEDURE dbo.populateDate;
DROP TABLE dbo.DateRange;



----------- OR -------------

CREATE PROCEDURE dbo.fillDateRange
@startdate date, @numofdays int
AS 
BEGIN
	DECLARE @counter int = 0;
	DECLARE @tempdate date;
	WHILE (@counter < @numofdays)
	BEGIN 
	    SET @tempdate = DATEADD(dd, @counter, @startDate);
		INSERT INTO dbo.DateRange (DateValue, Year, Quarter, Month, DayOfWeek)
			VALUES( @tempdate, year(@tempdate), DATEPART(q, @tempdate), month(@tempdate), DATEPART(dw, @tempdate));
			SET @counter += 1;
	END
	RETURN;
END

--Test Procedure --
EXEC dbo.fillDateRange '1-1-2020' , 7 ;
SELECT * FROM dbo.DateRange;


-- Drop Procedure & Table --
DROP PROC dbo.fillDateRange;
DROP TABLE dbo.DateRange;

------------------------------------------------------- Lab 5-3 -------------------------------------------------------
/* With three tables as defined below: */
/* Write a trigger to put the change date and time in the LastModified column of the 
   Order table whenever an order item in SaleOrderDetail is changed. */

CREATE TABLE Customer 
(CustomerID INT PRIMARY KEY,
CustomerLName VARCHAR(30), 
CustomerFName VARCHAR(30));

CREATE TABLE SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID INT REFERENCES Customer(CustomerID), 
OrderDate DATE,
LastModified datetime);

CREATE TABLE SaleOrderDetail
(OrderID INT REFERENCES SaleOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));

CREATE TRIGGER UpdateDateTime
ON dbo.SaleOrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT on;
    UPDATE SaleOrder
    SET LastModified = GETDATE()
    FROM SaleOrder so
    WHERE OrderID = (SELECT OrderID FROM Inserted) OR OrderID = (SELECT OrderID FROM Deleted)
END


----------- OR -------------

CREATE TRIGGER UpdateDateTime
ON dbo.SaleOrderDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT on;
    UPDATE SaleOrder
    SET LastModified = GETDATE()
    FROM Inserted i
    FULL JOIN Deleted d
    ON i.OrderID = d.OrderID
    WHERE SaleOrder.OrderID = (SELECT OrderID FROM Inserted) OR SaleOrder.OrderID = (SELECT OrderID FROM Deleted);
END

-- Test --
insert Customer values (1,'Doe','John'), (2,'Hogan','Matt'), (3,'Fox','Ryan');
insert SaleOrder(CustomerID,OrderDate,LastModified) values (1,'2020-05-06','2020-05-16 10:05:07'), 
														   (2,'2020-06-10','2020-06-20 03:24:11'),
														   (3,'2019-01-11','2019-04-04 04:11:14');
insert SaleOrderDetail values (1,22,3,50), (2,33,1,250);

select * from Customer;
select * from SaleOrder;
select * from SaleOrderDetail;

update SaleOrderDetail 
set UnitPrice = 100
where Quantity = 3; --OrderID = 1
select * from SaleOrderDetail;
select * from SaleOrder;

insert SaleOrderDetail values (3,44,2,15);
select * from SaleOrderDetail;
select * from SaleOrder;

DELETE from SaleOrderDetail where OrderID = 2 AND ProductID = 33;
select * from SaleOrderDetail;
select * from SaleOrder;

-- Drop Tables --
drop trigger UpdateDateTime;
drop table saleorderdetail;
drop table saleorder;
drop table customer;
