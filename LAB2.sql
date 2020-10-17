
--------------------------------------- QUESTION 1 ------------------------------------

SELECT CustomerID, SalesOrderID, ROUND(CAST(TotalDue AS DECIMAL (10,2)), 2) AS "Total Due", CAST(OrderDate AS date) AS "Order Date" 
FROM Sales.SalesOrderHeader
WHERE OrderDate > '2008-05-01' AND TotalDue > 50000
ORDER BY CustomerID, OrderDate ;

---------- OR ----------

-- USING ROUND ONLY FOR TOTALDUE (WITHOUT USING CAST)

SELECT CustomerID, SalesOrderID, ROUND(TotalDue, 2) AS "Total Due", CAST(OrderDate AS date) AS "Order Date" 
FROM Sales.SalesOrderHeader
WHERE OrderDate > '2008-05-01' AND TotalDue > 50000
ORDER BY CustomerID, OrderDate ;

--------------------------------------- QUESTION 2 ------------------------------------

SELECT CustomerID, AccountNumber, MAX(CAST(OrderDate AS date)) AS "Latest Order Date", COUNT(SalesOrderId) AS "Total Orders" 
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, AccountNumber
ORDER BY CustomerID ;

--------------------------------------- QUESTION 3 ------------------------------------

SELECT ProductID, Name AS "Product Name", ROUND(CAST(ListPrice AS DECIMAL (10,2)), 2) AS "Product List Price"
FROM Production.Product
WHERE ListPrice > (SELECT ListPrice FROM Production.Product WHERE ProductID = 912)
ORDER BY ListPrice DESC ;

---------- OR ----------

-- USING ROUND ONLY FOR LISTPRICE (WITHOUT USING CAST)

SELECT ProductID, Name AS "Product Name", ROUND(ListPrice, 2) AS "Product List Price"
FROM Production.Product
WHERE ListPrice > (SELECT ListPrice FROM Production.Product WHERE ProductID = 912)
ORDER BY ListPrice DESC ;


--------------------------------------- QUESTION 4 ------------------------------------

SELECT p.ProductID, Name AS "Product Name", COUNT(p.ProductID) AS "Total Product Sold"
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail s 
ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(p.ProductID) > 5
ORDER BY "Total Product Sold" DESC, p.ProductID ASC ;

---------- OR ----------

SELECT s.ProductID, p.Name AS "Product Name", COUNT(s.ProductID) AS "Total Product Sold"
FROM Sales.SalesOrderDetail s
LEFT JOIN Production.Product p 
ON s.ProductID = p.ProductID
GROUP BY s.ProductID, p.Name
HAVING COUNT(s.ProductID) > 5
ORDER BY "Total Product Sold" DESC, s.ProductID ASC ;

--------------------------------------- QUESTION 5 ------------------------------------

SELECT CustomerID, AccountNumber
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, AccountNumber
HAVING MAX(OrderDate) <= '2008-01-01'
ORDER BY CustomerID ASC ;

--------------------------------------- QUESTION 6 ------------------------------------

-- USING INNER JOIN. DOES NOT CONTAIN NULL VALUES (CUSTOMER THAT HAVE PERSON ID/DETAIL)

SELECT c.CustomerID, p.FirstName, p.Lastname, e.EmailAddress
FROM Sales.Customer c
JOIN Person.Person p 
ON c.PersonID = p.BusinessEntityID
JOIN Person.EmailAddress e 
ON c.PersonID = e.BusinessEntityID
ORDER BY CustomerID ASC ;

---------- OR ----------

-- USING LEFT JOIN. CONTAIN NULL VALUES (CUSTOMER THAT DOES NOT HAVE PERSON ID/DETAIL)

SELECT c.CustomerID, p.FirstName, p.Lastname, e.EmailAddress
FROM Sales.Customer c
LEFT JOIN Person.Person p 
ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress e 
ON c.PersonID = e.BusinessEntityID
ORDER BY CustomerID ASC ;
