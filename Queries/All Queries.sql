-- Northwind Full Query Script
-- Includes corrected Level 1–7 SQL queries
-- Assumes MySQL 8+ syntax (supports CTE + window functions)

/*************************************************
 LEVEL 1 — BASIC FILTERING & SORTING
*************************************************/

-- Q1
SELECT * FROM Customers WHERE Country = 'Germany';

-- Q2
SELECT * FROM Orders WHERE YEAR(OrderDate) = 2014;

-- Q3
SELECT * FROM Orders WHERE Freight > 100;

-- Q4
SELECT * FROM Orders WHERE ShippedDate =""; # also you use "is not null"

-- Q5
SELECT * FROM Products WHERE UnitPrice BETWEEN 50 AND 100;



-- Q7
SELECT * FROM Customers WHERE CompanyName LIKE 'A%';

-- Q8
SELECT * FROM Customers WHERE Country IN ('USA', 'UK');





-- Q11
SELECT * FROM Products ORDER BY UnitPrice DESC LIMIT 10;

-- Q12
SELECT * FROM Customers ORDER BY CompanyName ASC;

-- Q13
SELECT * FROM Orders ORDER BY OrderDate DESC;

-- Q14
SELECT * FROM Products WHERE ProductName LIKE '%Tea%';


/*************************************************
 LEVEL 2 — AGGREGATIONS
*************************************************/

-- Q16
SELECT CustomerID, COUNT(*) AS TotalOrders 
FROM Orders 
GROUP BY CustomerID;

-- Q17
SELECT ProductID, ROUND(SUM(UnitPrice * Quantity * (1-Discount)),2) AS Revenue 
FROM Order_Details 
GROUP BY ProductID;

-- Q18
SELECT ProductID, SUM(Quantity) AS TotalQuantity 
FROM Order_Details 
GROUP BY ProductID;

-- Q19
SELECT CustomerID, ROUND(AVG(OrderTotal),2) AS AvgOrderValue
FROM (
    SELECT o.OrderID, o.CustomerID,
           ROUND(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)),2) AS OrderTotal
    FROM Orders o
    JOIN Order_Details od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, o.CustomerID
) t
GROUP BY CustomerID;

-- Q20
SELECT YEAR(OrderDate) AS OrderYear, COUNT(*) 
FROM Orders 
GROUP BY YEAR(OrderDate);

-- Q21
SELECT YEAR(OrderDate) AS OrderYear,
       ROUND(SUM(UnitPrice*Quantity*(1-Discount)),2) AS Revenue
FROM Orders 
JOIN Order_Details USING(OrderID) 
GROUP BY YEAR(OrderDate);

-- Q22
SELECT C.CategoryName,
       ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS Revenue
FROM Order_Details OD
JOIN Products P USING(ProductID)
JOIN Categories C USING(CategoryID)
GROUP BY CategoryName;

-- Q23
SELECT CustomerID, COUNT(*) AS OrderCount 
FROM Orders 
GROUP BY CustomerID 
HAVING COUNT(*) > 10;

-- Q24
SELECT ProductID, ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS TotalSales
FROM Order_Details OD
GROUP BY ProductID
HAVING TotalSales > 10000;

-- Q25
SELECT EmployeeID, COUNT(*) AS OrdersHandled
FROM Orders
GROUP BY EmployeeID
HAVING COUNT(*) > 50;



-- Q27
SELECT CategoryID, MAX(UnitPrice) AS MaxPrice, MIN(UnitPrice) AS MinPrice
FROM Products
GROUP BY CategoryID;

-- Q28
SELECT Country, COUNT(DISTINCT CustomerID) AS DistinctCustomers
FROM Customers
GROUP BY Country;

-- Q29
SELECT ProductID, ROUND(SUM(UnitPrice*Quantity*Discount),2) AS TotalDiscount
FROM Order_Details
GROUP BY ProductID;

-- Q30
SELECT EmployeeID, COUNT(*) AS LateOrders
FROM Orders
WHERE ShippedDate > RequiredDate
GROUP BY EmployeeID;


/*************************************************
 LEVEL 3 — JOINS
*************************************************/

-- Q31
SELECT Orders.OrderID, Customers.CompanyName
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID;

-- Q32
SELECT OD.OrderID, P.ProductName, C.CategoryName
FROM Order_Details OD
JOIN Products P USING(ProductID)
JOIN Categories C USING(CategoryID);

-- Q33
SELECT Employees.EmployeeID, COUNT(Orders.OrderID) AS OrdersHandled
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID;

-- Q34
SELECT C.CompanyName,
       ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS Revenue
FROM Orders O
JOIN Customers C  USING(CustomerID)
JOIN Order_Details OD USING(OrderID)
GROUP BY C.CompanyName;

-- Q35
SELECT C.CompanyName,
       ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS Revenue
FROM Customers C
JOIN Orders O USING(CustomerID)
JOIN Order_Details OD USING(OrderID)
GROUP BY C.CompanyName
ORDER BY Revenue DESC
LIMIT 10;



-- Q37
SELECT OrderID, CompanyName AS Shipper
FROM Orders
JOIN Shippers USING(ShipperID);

-- Q38
SELECT *
FROM Orders O
LEFT JOIN Customers  C ON O.CustomerID = C.CustomerID
WHERE C.CustomerID ="";

-- Q39
SELECT c.*
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- Q40
SELECT E.EmployeeID,
       ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS Revenue
FROM Employees E
JOIN Orders O USING(EmployeeID)
JOIN Order_Details OD USING(OrderID)
GROUP BY E.EmployeeID;

-- Q41
SELECT CategoryName, ProductName, SUM(Quantity) AS TotalSold
FROM Order_Details
JOIN Products USING(ProductID)
JOIN Categories USING(CategoryID)
GROUP BY CategoryName, ProductName
ORDER BY CategoryName, TotalSold DESC;

-- Q42
SELECT o.OrderID,
       ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) + o.Freight,2) AS TotalWithShipping
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.Freight;

-- Q43
SELECT CategoryName, SUM(Quantity) AS TotalQty
FROM Order_Details
JOIN Products USING(ProductID)
JOIN Categories USING(CategoryID)
GROUP BY CategoryName;

-- Q44
SELECT DISTINCT ProductName
FROM Orders
JOIN Customers USING(CustomerID)
JOIN Order_Details USING(OrderID)
JOIN Products USING(ProductID)
WHERE Customers.ContactName LIKE 'John%';


/*************************************************
 LEVEL 4 — SUBQUERIES
*************************************************/

-- Q46
SELECT CustomerID
FROM (
    SELECT CustomerID, AVG(OrderTotal) AS AvgOrder
    FROM (
        SELECT o.OrderID, o.CustomerID,
               SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS OrderTotal
        FROM Orders o
        JOIN Order_Details od ON o.OrderID = od.OrderID
        GROUP BY o.OrderID, o.CustomerID
    ) t
    GROUP BY CustomerID
) x
WHERE AvgOrder > (
    SELECT AVG(OrderTotal)
    FROM (
        SELECT OrderID, SUM(UnitPrice*Quantity*(1-Discount)) AS OrderTotal
        FROM Order_Details
        GROUP BY OrderID
    ) y
);

-- Q47
SELECT ProductID
FROM Order_Details
GROUP BY ProductID
HAVING SUM(Quantity) > (
    SELECT AVG(q)
    FROM (
        SELECT SUM(Quantity) AS q
        FROM Order_Details
        GROUP BY ProductID
    ) t
);

-- Q48
SELECT o.CustomerID
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING COUNT(DISTINCT od.ProductID) > 1;


/*************************************************
 LEVEL 5 — CTEs
*************************************************/

-- Q56
WITH OrderRevenue AS (
    SELECT 
        OrderID, 
        CustomerID, -- Selected here
        ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS Revenue
    FROM Order_Details OD
    JOIN Orders USING(OrderID)
    GROUP BY OrderID, CustomerID -- Added CustomerID here to fix Error 1055
),
CustomerSpend AS (
    SELECT 
        CustomerID, 
        SUM(Revenue) AS TotalSpend
    FROM OrderRevenue
    GROUP BY CustomerID
)
SELECT 
    CustomerID, 
    TotalSpend,
    RANK() OVER (ORDER BY TotalSpend DESC) AS SpendRank
FROM CustomerSpend;


/*************************************************
 LEVEL 6 — WINDOW FUNCTIONS
*************************************************/

-- Q61
SELECT CustomerID, OrderID,
       SUM(UnitPrice*Quantity*(1-Discount)) AS OrderRevenue,
       SUM(SUM(UnitPrice*Quantity*(1-Discount))) 
            OVER (PARTITION BY CustomerID ORDER BY OrderID) AS RunningTotal
FROM Order_Details
JOIN Orders USING(OrderID)
GROUP BY CustomerID, OrderID;


/*************************************************
 LEVEL 7 — BUSINESS QUESTIONS
*************************************************/

-- Q71
SELECT CustomerID, ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)),2) AS Revenue
FROM Orders O
JOIN Order_Details OD USING(OrderID)
GROUP BY CustomerID
ORDER BY Revenue DESC
LIMIT 5;