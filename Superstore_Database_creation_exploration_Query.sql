--creating a database for the capstone project
CREATE DATABASE Capstone

--Write a Query that display the individual tables.
--Display of Customer table
SELECT *
FROM [dbo].[Superstore_CustomerN]

--Display of Order table
SELECT *
FROM [dbo].[Superstore_OrderN]

--Display of Product table
SELECT *
FROM [dbo].[Superstore_ProductN]

--Display of Region table
SELECT *
FROM [dbo].[Superstore_RegionN]

--Writing a statement that list all customers along with their ID, Name & Segment.
SELECT [Customer_ID], [Customer_Name], [Segment]
FROM [dbo].[Superstore_CustomerN]

--Writing a statement that lists the Name, Product ID, Category & Sub-Category of each product.
SELECT [Product_Name], [Product_ID], [Category], [Sub_Category]
FROM [dbo].[Superstore_ProductN]

--Writing a query that displays all the columns of all product who have the category “Furniture”.
SELECT *
FROM [dbo].[Superstore_ProductN]
WHERE [Category] = 'Furniture'

--Writing a query that displays the Product name, and ID of each product with the Name starting with “Boston”.
SELECT [Product_Name], [Product_ID]
FROM [dbo].[Superstore_ProductN]
WHERE [Product_Name] LIKE 'Boston%'

--Writing a query that displays the Product name, and ID of each product with the Name having “Collection”.
SELECT [Product_Name], [Product_ID]
FROM [dbo].[Superstore_ProductN]
WHERE [Product_Name] LIKE '%Collection%'

--Writing the query that displays all orders made during the month of March 2014.
SELECT *
FROM [dbo].[Superstore_OrderN]
WHERE [Order_Date] BETWEEN '2014/03/01' AND '2014/03/31'
ORDER BY [Order_Date]

--Writing the query that displays all orders the were not made during the month of March 2014 but shipped between 5th and 30th of March 2014.
SELECT *
FROM [dbo].[Superstore_OrderN]
WHERE ([Order_Date] NOT BETWEEN '2014/03/01' AND '2014/03/31') AND ([Ship_Date] BETWEEN '2014/03/05' AND '2014/03/30')

--Joining the Order table to the Customer table on the Customer ID column. Display all columns from both tables.
SELECT *
FROM [dbo].[Superstore_OrderN] AS O
JOIN [dbo].[Superstore_CustomerN] AS C
ON O.Customer_ID = C.Customer_ID

/*Joining the Order table to the Customer, Product, & Region tables on the basis that the CustomerID column in the Order table matches 
the CustomerID column in the Customer table, the ProductID column in the Product table matches the ProductID column in the 
Order table, the Postalcode column in the Region table matches the Postalcode column in the Order Table.*/
SELECT *
FROM [dbo].[Superstore_OrderN] AS O
JOIN [dbo].[Superstore_CustomerN] AS C ON O.Customer_ID = C.Customer_ID
JOIN [dbo].[Superstore_ProductN] AS P ON O.Product_ID = P.Product_ID
JOIN [dbo].[Superstore_RegionN] AS R ON O.Postal_Code =R.Postal_Code

--Avoiding repeated columns
SELECT O.[Order_ID], O.[Order_Date], O.[Ship_Date], O.[Ship_Mode], O.[Customer_ID], O.[Postal_Code], O.[Product_ID], O.[Sales], O.[Quantity],
       O.[Discount], O.[Profit], C.[Customer_Name], C.[Segment], P.[Category], P.[Sub_Category], P.[Product_Name], R.[Country], R.[City],
	   R.[State], R.[Region]
FROM [dbo].[Superstore_OrderN] AS O
JOIN [dbo].[Superstore_CustomerN] AS C ON O.Customer_ID = C.Customer_ID
JOIN [dbo].[Superstore_ProductN] AS P ON O.Product_ID = P.Product_ID
JOIN [dbo].[Superstore_RegionN] AS R ON O.Postal_Code =R.Postal_Code