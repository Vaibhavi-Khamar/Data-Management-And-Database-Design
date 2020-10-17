
-------------------------------------------- QUESTION 1 --------------------------------------------
--Lab 3-1
/* Modify the following query to add a column that identifies the
frequency of repeat customers and contains the following values
based on the number of orders during 2007:
'No Order' for count = 0 'One Time' for count = 1
'Regular' for count range of 2-5
'Often' for count range of 6-10
'Loyal' for count greater than 10
Give the new column an alias to make the report more readable.
*/

SELECT c.CustomerID, c.TerritoryID, 
COUNT(o.SalesOrderid) [Total Orders],
CASE
   WHEN COUNT(o.SalesOrderid) = 0 THEN 'No Order'
   WHEN COUNT(o.SalesOrderid) = 1 THEN 'One Time'
   WHEN COUNT(o.SalesOrderid) BETWEEN 2 AND 5 THEN 'Regular'
   WHEN COUNT(o.SalesOrderid) BETWEEN 6 AND 10 THEN 'Often'
   ELSE 'Loyal'
END AS 'Order Frequency'
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

-------------------------------------------- QUESTION 2 --------------------------------------------
-- Lab 3-2
 /* Modify the following query to add a rank without gaps in the
 ranking based on total orders in the descending order. Also
 partition by territory.*/

SELECT c.CustomerID, c.TerritoryID,
COUNT(o.SalesOrderid) [Total Orders],
DENSE_RANK() OVER (PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) AS Ranking
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

-------------------------------------------- QUESTION 3 --------------------------------------------
 --Lab 3-3
 /* Write a query that returns the female salesperson who received
 the highest bonus amount in North America. Include the salesperson's
 id and bonus amount in the returned data. Your solution must
 retrieve the tie if there is a tie. */

--USING TOP 1 WITH TIES
SELECT TOP 1 WITH TIES p.Bonus AS BonusAmount, p.BusinessEntityID AS SalesPersonnID
FROM Sales.SalesPerson p
LEFT JOIN sales.SalesTerritory t 
ON p.TerritoryID = t.TerritoryID
LEFT JOIN HumanResources.Employee e 
ON p.BusinessEntityID = e.BusinessEntityID
WHERE t.[Group] = 'North America' AND e.Gender = 'F'
ORDER BY p.bonus DESC;

--OR

--USING RANK()
SELECT temp.SalesPersonnID, temp.Bonus
FROM (
 SELECT p.Bonus, p.BusinessEntityID AS SalesPersonnID, [Group] , e.Gender,
   RANK() OVER (PARTITION BY Gender ORDER BY p.Bonus DESC) AS Ranking
 FROM Sales.SalesPerson p
 LEFT JOIN sales.SalesTerritory t 
 ON p.TerritoryID = t.TerritoryID
 LEFT JOIN HumanResources.Employee e 
 ON p.BusinessEntityID = e.BusinessEntityID
 WHERE t.[Group] = 'North America' AND e.Gender = 'F'
) AS temp
WHERE temp.Ranking = 1;



-------------------------------------------- QUESTION 4 --------------------------------------------
--Lab 3-4
/* Write a query to retrieve the most valuable salesperson of each month
in 2007. The most valuable salesperson is the salesperson who has
made most sales for AdventureWorks in the month. Use the monthly sum
of the TotalDue column of SalesOrderHeader as the monthly total sales
for each salesperson. If there is a tie for the most valuable salesperson,
your solution should retrieve it. Exclude the orders which didn't have
a salesperson specified.
 Include the salesperson id, the bonus the salesperson earned,
 and the most valuable salesperson's total sales for the month
 columns in the report. Sort the returned data by the month. */

WITH temp AS (
  SELECT MONTH(h.OrderDate) [MonthOfYear],
	 h.SalesPersonID [SalesPersonID],
	 p.Bonus [BonusEarned],
	 SUM(h.TotalDue) [TotalSales],
	 RANK() OVER (PARTITION BY MONTH(h.OrderDate) ORDER BY SUM(h.TotalDue) DESC) AS Ranking
  FROM sales.SalesOrderHeader h
  JOIN Sales.SalesPerson p 
  ON h.SalesPersonID = p.BusinessEntityID 
WHERE DATEPART(year, OrderDate) = 2007 AND h.SalesPersonID IS NOT NULL 
GROUP BY MONTH(h.OrderDate), h.SalesPersonID, p.Bonus) 
SELECT SalesPersonID, BonusEarned, TotalSales, MonthOfYear
FROM temp
WHERE Ranking = 1
ORDER BY MonthOfYear;

--OR

SELECT temp.SalesPersonID, temp.BonusEarned, temp.TotalSales, temp.MonthOfYear
FROM(
 SELECT h.SalesPersonID,
	DATEPART(month, OrderDate) AS [MonthOfYear],
	SUM(h.TotalDue) AS [TotalSales],
	p.Bonus AS [BonusEarned],	
	DENSE_RANK() OVER (PARTITION BY DATEPART(month, OrderDate) ORDER BY SUM(h.TotalDue) DESC) AS Ranking
 FROM sales.SalesOrderHeader h
 LEFT JOIN Sales.SalesPerson p 
 ON h.SalesPersonID = p.BusinessEntityID 
 WHERE DATEPART(year, OrderDate) = 2007 AND h.SalesPersonID IS NOT NULL 
 GROUP BY h.SalesPersonID, DATEPART(month, OrderDate), p.Bonus
) AS temp 
WHERE temp.Ranking = 1
ORDER BY temp.MonthOfYear;

-------------------------------------------- QUESTION 5 --------------------------------------------
 --Lab 3-5
 /* Provide a unique list of customer id’s and account numbers which
 have ordered both the red and yellow products after May 1, 2008.
 Sort the list by customer id. */

SELECT DISTINCT(temp.CustomerID), temp.AccountNumber
FROM(
  SELECT soh.CustomerID, soh.AccountNumber, Color,
    DENSE_RANK() OVER (PARTITION BY soh.CustomerID ORDER BY Color) AS Ranking
  FROM Sales.SalesOrderHeader soh
  LEFT JOIN Sales.SalesOrderDetail sod 
  ON soh.SalesOrderID = sod.SalesOrderID 
  LEFT JOIN Production.Product p 
  ON sod.ProductID = p.ProductID
  WHERE Color = 'Red' OR Color = 'Yellow' AND OrderDate>'2008-05-01'
 ) AS temp
WHERE temp.Ranking = 2
ORDER BY temp.CustomerID;

--intersect
SELECT soh.CustomerID,soh.AccountNumber
FROM Sales.SalesOrderHeader soh
  LEFT JOIN Sales.SalesOrderDetail sod 
  ON soh.SalesOrderID = sod.SalesOrderID 
  LEFT JOIN Production.Product p 
  ON sod.ProductID = p.ProductID
where color='red' AND OrderDate>'2008-05-01'
INTERSECT 
SELECT soh.CustomerID,soh.AccountNumber
FROM Sales.SalesOrderHeader soh
  LEFT JOIN Sales.SalesOrderDetail sod 
  ON soh.SalesOrderID = sod.SalesOrderID 
  LEFT JOIN Production.Product p 
  ON sod.ProductID = p.ProductID
where color='yellow' AND OrderDate>'2008-05-01'
order by soh.CustomerID;
