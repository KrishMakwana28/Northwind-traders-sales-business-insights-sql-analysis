CREATE DATABASE northwind;
USE northwind;
select * from customers;
select * from categories;
select * from employees;
select * from order_details;
select * from orders;
select * from products;
select * from shippers;

show tables;
-- Total revenue
select round(sum(unitPrice*quantity*(1 - discount)),2) as TotalRevenue from order_details od;

--  revenue by year
select year(o.orderDate) as SalesYear,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue 
from order_details od join orders o on o.orderID=od.orderID 
group by SalesYear order by SalesYear ;


-- Monthly Sales Trend
with MonthlySales as (
  select 
    DATE_FORMAT(o.OrderDate, '%M') as Month,
    round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)),2)as Revenue
  from orders o
  join order_details od on o.OrderID = od.OrderID
  group by  Month
)
select * from MonthlySales group by Month order by Revenue desc;

-- Average Order Value (AOV)
select ROUND(AVG(order_total),2) AS avg_order_value
from(select o.OrderID,SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS order_total
    from orders o
    join order_details od on o.OrderID = od.OrderID
    group by  o.OrderID) t;


-- Total Discount Value : Revenue lost due to discounts
select round(sum(od.unitPrice*od.quantity*od.discount),2) as DiscountLoss
from order_details od;



-- Top 10 Customers by Revenue
select c.companyName ,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue 
from order_details od join orders o on od.orderID=o.orderID inner join customers c on o.customerID=c.customerID 
group by c.companyName order by Revenue desc limit 10;

-- Revenue by Country
select c.country,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue 
from order_details od join orders o on od.orderID=o.orderID  join customers c on c.customerID=o.customerID
group by  c.country order by Revenue asc limit 10;


-- Repeat Customers 
select c.companyName,count(*) as orderCount 
from customers c join orders o on c.customerID=o.customerID
group by c.companyName having count(*)>10 order by orderCount desc;



-- Top 10 Products /Best-selling products (by revenue)
select p.productName,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue 
from order_details od join products p on od.productID=p.productID 
group by p.productName order by Revenue desc limit 10;

-- Product Ranking
select p.ProductName,ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS Revenue,
  rank() over (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS RevenueRank
from products p
join order_details od on p.ProductID = od.ProductID
group by p.ProductName;

-- Best-selling categories
select cat.categoryName,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue 
from order_details od join products p on od.productID=p.productID join categories cat on p.categoryID=cat.categoryID
group by  cat.categoryName order by Revenue desc;

 
-- Top sales reps
select e.employeeName as SalesRep,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue
from employees e join orders o on e.employeeID=o.employeeID join order_details od on od.orderID=o.orderID
where e.title="Sales Representative" 
group by SalesRep order by Revenue desc;

-- Rank Employees by Sales
select e.employeeName as SalesRep,round(sum(od.unitPrice*od.quantity*(1 - od.discount)),2) as Revenue,
dense_rank() over(order by SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) desc) as RankNum
from employees e join orders o on e.employeeID=o.employeeID join order_details od on od.orderID=o.orderID
group by SalesRep;





-- Average Shipping Time / Average Delivery Duration
select ceil(avg(Datediff(shippedDate,orderDate))) as AvgShipDays from orders 
where shippedDate is not null;

-- Late Deliveries/ Late Shipments 
select COUNT(*) AS late_orders from orders
where ShippedDate > RequiredDate;
-- By shippers
select s.companyName,COUNT(*) as late_orders 
from orders o join shippers s on o.shipperID=s.shipperID 
where o.ShippedDate > o.RequiredDate
group by s.companyName;

-- Performance by Shipper
select s.CompanyName,ceil(avg(datediff(o.ShippedDate,o.OrderDate))) AS AvgShipTime_Days
from shippers s
join orders o on s.ShipperID = o.ShipperID
group by s.CompanyName order by AvgShipTime_Days desc;




-- Revenue Concentration
select c.CompanyName,ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS Revenue,
ROUND(100 * SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))/SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) 
      OVER (),2) as RevenueSharePercent
from customers c
join orders o on c.CustomerID = o.CustomerID
join order_details od on o.OrderID = od.OrderID
group by c.CompanyName
order by Revenue desc limit 10;

-- Top Customers by Country
select c.Country,c.CompanyName,round(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS revenue,
rank() over(partition by c.Country order by
   SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) desc) as rank_in_country
FROM customers c
join orders o on c.CustomerID = o.CustomerID
join order_details od on o.OrderID = od.OrderID
group by c.Country, c.CompanyName
order by rank_in_country ;

-- % Revenue from Top 10 Customers
WITH cust_rev AS (
    SELECT 
        c.CompanyName,
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS revenue
    FROM customers c
    JOIN orders o ON c.CustomerID = o.CustomerID
    JOIN order_details od ON o.OrderID = od.OrderID
    GROUP BY c.CompanyName
),
ranked AS (
    SELECT 
        CompanyName,
        revenue,
        RANK() OVER (ORDER BY revenue DESC) AS rnk,
        ROUND(SUM(revenue) OVER (),2) AS total_revenue,
        ROUND(SUM(revenue) OVER (ORDER BY revenue DESC) / 
            SUM(revenue) OVER () * 100 ,2) AS running_percent
    FROM cust_rev
)
SELECT * FROM ranked WHERE rnk <= 10;


