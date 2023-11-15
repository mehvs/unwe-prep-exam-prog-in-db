--1
CREATE TABLE SeafoodSales(
ProductID int PRIMARY KEY,
ProductName nvarchar(40),
TotalQuantity int,
AvgPrice money
)

--2
INSERT INTO dbo.SeafoodSales(ProductID, ProductName, TotalQuantity, AvgPrice)
SELECT p.ProductID, p.ProductName, SUM(od.Quantity), AVG(od.UnitPrice) 
FROM 
Products p 
JOIN 
[Order Details] od
ON
p.ProductID = od.ProductID
JOIN
Categories c
ON
p.CategoryID = c.CategoryID
WHERE c.CategoryID = 8
GROUP BY p.ProductID, p.ProductName

--3
ALTER TABLE SeafoodSales
ADD Price money

--4
UPDATE SeafoodSales
SET Price=UnitPrice
FROM SeafoodSales ss JOIN Products p ON ss.ProductID = p.ProductID

--5
DELETE FROM SeafoodSales
WHERE Price < 10
GO

--6
CREATE VIEW ProductsView AS
SELECT p.ProductID, p.ProductName, c.CategoryName, s.CompanyName, s.Country FROM Products p 
INNER JOIN
Categories c ON p.CategoryID = c.CategoryID
INNER JOIN
Suppliers s ON s.SupplierID = p.ProductID
GO

--7
SELECT p.ProductName, p.CompanyName, p.Country, SUM(od.Quantity) as 'Sum of quantity' FROM ProductsView p 
JOIN 
[Order Details] od ON p.ProductID = od.ProductID
WHERE p.Country='Italy' OR p.Country='France' OR p.Country='Spain'
GROUP BY p.ProductName, p.CompanyName, p.Country
ORDER BY ProductName
GO

--8
CREATE FUNCTION Sum_Product_Sales(@ProductID int)
RETURNS money
AS
BEGIN
	DECLARE @sum_of_product_sales money
	
	SELECT @sum_of_product_sales = ISNULL(SUM((Quantity * UnitPrice)), 0) FROM [Order Details] WHERE ProductID = @ProductID 

	RETURN @sum_of_product_sales
END;
GO

--9(unsure if correct)
SELECT
  ProductID,
  ProductName,
  UnitPrice,
  Sum_Product_Sales(ProductID) AS TotalSales
FROM
  Products
WHERE
  (
    SELECT
      COUNT(*)
    FROM
      OrderDetails
    WHERE
      ProductID = Products.ProductID
  ) > 50;

--10
CREATE FUNCTION Avg_Product_Qty(@like nvarchar(255))
RETURNS TABLE
AS
RETURN
(
SELECT p.ProductID, p.ProductName, s.CompanyName, s.Country, AVG(CAST(od.Quantity AS real)) as Average_quantity FROM Products p
JOIN
Suppliers s ON p.SupplierID = s.SupplierID
JOIN
[Order Details] od ON p.ProductID = od.ProductID
WHERE s.Country LIKE @like
GROUP BY p.ProductID, p.ProductName, s.CompanyName, s.Country
);
GO

--11
SELECT ProductID, ProductName, CompanyName, Country, Average_quantity FROM Avg_Product_Qty('USA')
SELECT ProductID, ProductName, CompanyName, Country, Average_quantity FROM Avg_Product_Qty('%')

--12
DROP TABLE SeafoodSales

--13
DROP VIEW ProductsView

--14
DROP FUNCTION Sum_Product_Sales
DROP FUNCTION Avg_Product_Qty
