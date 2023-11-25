--*************************************************************************--
-- Title: Assignment06
-- Author: JRWilson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-21-11,JRWilson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JRWilson')
	 Begin 
	  Alter Database [Assignment06DB_JRWilson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JRWilson;
	 End
	Create Database Assignment06DB_JRWilson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JRWilson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- List the tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

-- Create the Selects
Select 
	CategoryID
	, CategoryName
	From Categories;
go
Select 
	ProductID
	, ProductName
	, CategoryID
	, UnitPrice 
	From Products;
go
Select 
	EmployeeID
	, EmployeeFirstName
	, EmployeeLastName
	, ManagerID 
	From Employees;
go
Select 
	InventoryID
	, InventoryDate
	, EmployeeID
	, ProductID
	, Count
	From Inventories;
go

-- Create the views and bind them
CREATE VIEW vCategories
	WITH SCHEMABINDING
	AS
	Select 
		CategoryID
		, CategoryName
		From dbo.Categories;
go

Create VIEW vProducts
	WITH SCHEMABINDING
	AS
	Select 
		ProductID
		, ProductName
		, CategoryID
		, UnitPrice 
		From dbo.Products;
go

CREATE VIEW vEmployees
	WITH SCHEMABINDING
	AS
	Select 
		EmployeeID
		, EmployeeFirstName
		, EmployeeLastName
		, ManagerID 
		From dbo.Employees;
go

Create View vInventories
	WITH SCHEMABINDING
	AS
	Select 
		InventoryID
		, InventoryDate
		, EmployeeID
		, ProductID
		, Count
		From dbo.Inventories;
go

-- Confirm the views exist
SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO
SELECT * FROM vEmployees;
GO
SELECT * FROM vInventories;
GO

-- Test the binding by seeing if I can delete a protected column
ALTER TABLE dbo.Inventories DROP COLUMN ProductID

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--List up the tables and view

DENY SELECT ON Categories to public;
DENY SELECT ON Products to public;
DENY SELECT ON Employees to public;
DENY SELECT ON Inventories to public;
GRANT SELECT ON vCategories to public;
GRANT SELECT ON vProducts to public;
GRANT SELECT ON vEmployees to public;
GRANT SELECT ON vInventories to public;
GO

--Test 

Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO
SELECT * FROM vEmployees;
GO
SELECT * FROM vInventories;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- List up that tables
SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO

-- Structure the select statement to list up Categories, products names, and prices. Then order by the category and product
SELECT
    vC.CategoryName as Categories
    , vP.ProductName AS 'Product name'
    , vP.UnitPrice AS Price
    FROM
    vProducts AS vP Join vCategories AS vC
    ON vP.CategoryId = vC.CategoryID;
GO

-- Order the Table by the category and product
SELECT
    vC.CategoryName as Categories
    , vP.ProductName AS 'Product name'
    , vP.UnitPrice AS Price
    FROM
    vProducts AS vP Join vCategories AS vC
    ON vP.CategoryId = vC.CategoryID
    ORDER BY vC.CategoryName, vP.ProductName;
GO

-- Create the view
Create VIEW vCategoriesProductsAndPrices
    AS
    SELECT
        vC.CategoryName as Categories
        , vP.ProductName AS 'Product name'
        , vP.UnitPrice AS Price
        FROM
        vProducts AS vP Join vCategories AS vC
        ON vP.CategoryId = vC.CategoryID;
        -- ORDER BY vC.CategoryName, vP.ProductName;
    GO

-- View ordered List.
Select * From vCategoriesProductsAndPrices ORDER BY Categories, 'Product name';
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Pull the views for Products, and inventory
SELECT * FROM vProducts;
GO
SELECT * FROM vInventories;
GO

-- Build the select statement for viewing Product name, Inventory count, and date.

SELECT
    vP.ProductName AS 'Product name'
    , vI.COUNT
    , vI.InventoryDate
    FROM
        vProducts AS vP 
        Join vInventories AS vI
        ON vP.ProductID = vI.ProductID;
GO

-- Order the results by the Product, Date, and Count!
SELECT
    vP.ProductName AS 'Product name'
    , vI.COUNT
    , vI.InventoryDate AS 'Date'
    FROM
        vProducts as vP 
        Join vInventories AS vI
        ON vP.ProductID = vI.ProductID
    ORDER BY vP.ProductName, vI.InventoryDate, vI.COUNT;
GO

-- Create the view
CREATE View vProductInventoryAndDates
    AS
    SELECT
        vP.ProductName AS 'Product name'
        , vI.COUNT
        , vI.InventoryDate AS 'Date'
        FROM
            vProducts as vP 
            Join vInventories AS vI
            ON vP.ProductID = vI.ProductID;
        -- ORDER BY vP.ProductName, vI.InventoryDate, vI.COUNT;
GO

-- View ordered
Select * From dbo.vProductInventoryAndDates Order by 'Product name', Date, Count;

-- Question 5 (10% pts): How can you CREATE a view to show a list of Inventory Dates 
SELECT * From vInventories;
GO
-- and the Employee that took the count?
SELECT * FROM vEmployees

-- Join and structure the columns to show Inventory Dates and the Employee
SELECT
    vI.InventoryDate as 'Inventory Date'
    , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
    From 
        vInventories AS vI
        Join vEmployees AS vE
        ON vI.EmployeeID = vE.EmployeeID
GO

-- Order the results by the Date and return only one row per date!
SELECT
    vI.InventoryDate as 'Inventory Date'
    , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
    From 
        vInventories AS vI
        Join vEmployees AS vE
        ON vI.EmployeeID = vE.EmployeeID
    GROUP BY vI.InventoryDate, vE.EmployeeFirstName + ' ' + vE.EmployeeLastName
    Order by vI.InventoryDate;
GO
-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- CREATE a view
CREATE VIEW vInventoryDatesByEmployee
    AS
    SELECT
        vI.InventoryDate as 'Inventory Date'
        , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
        From 
            vInventories AS vI
            Join vEmployees AS vE
            ON vI.EmployeeID = vE.EmployeeID
        GROUP BY vI.InventoryDate, vE.EmployeeFirstName + ' ' + vE.EmployeeLastName;
        -- Order by vI.InventoryDate;
GO

-- CHECK
SELECT * FROM vInventoryDatesByEmployee
    ORDER by 'Inventory Date';
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
SELECT * FROM vCategories;
SELECT * FROM vProducts;

SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID;
GO
-- and the Inventory Date and Count of each product?
Select * FROM vInventories;

SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    , vI.InventoryDate AS 'Inventory date'
    , vI.Count
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID
        Join vInventories AS vI 
        ON vP.ProductID = vI.ProductID;
GO
--Create the 
CREATE VIEW 
    -- Drop View
        vCategorizedProductInventories
    AS
    SELECT
        vC.CategoryName AS Categories
        , vP.ProductName AS Products
        , vI.InventoryDate AS 'Inventory date'
        , vI.Count
        FROM vProducts AS vP 
            JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID
            Join vInventories AS vI 
            ON vP.ProductID = vI.ProductID;
GO
-- Order the results by the Category, Product, Date, and Count!
SELECT * From vCategorizedProductInventories
    ORDER BY Categories, Products, 'Inventory date', count;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
SELECT * FROM vCategories;
SELECT * FROM vProducts;

SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID;
GO

-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
SELECT * From vEmployees;

SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    , vI.InventoryDate AS 'Inventory date'
    , vI.Count
    , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID
        Join vInventories AS vI 
        ON vP.ProductID = vI.ProductID
        JOIN vEmployees AS vE
        ON vI.EmployeeID = vE.EmployeeID; 
GO

-- Create the view
CREATE VIEW 
    -- Drop View
    vCategorizedProductsInventoriedByEmployee
    AS
    SELECT
        vC.CategoryName AS Categories
        , vP.ProductName AS Products
        , vI.InventoryDate AS 'Inventory date'
        , vI.Count
        , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
        FROM vProducts AS vP 
            JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID
            Join vInventories AS vI 
            ON vP.ProductID = vI.ProductID
            JOIN vEmployees AS vE
            ON vI.EmployeeID = vE.EmployeeID; 
GO

-- Order the results by the Inventory Date, Category, Product and Employee!
SELECT * FROM vCategorizedProductsInventoriedByEmployee ORDER BY 'Inventory date', Categories, Products, Employee;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    , vI.InventoryDate AS 'Inventory date'
    , vI.Count
    , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID
        Join vInventories AS vI 
        ON vP.ProductID = vI.ProductID
        JOIN vEmployees AS vE
        ON vI.EmployeeID = vE.EmployeeID; 
GO
-- for the Products 'Chai' and 'Chang'? 
SELECT
    vC.CategoryName AS Categories
    , vP.ProductName AS Products
    , vI.InventoryDate AS 'Inventory date'
    , vI.Count
    , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
    FROM vProducts AS vP 
        JOIN vCategories AS vC 
        ON vP.CategoryID = vC.CategoryID
        Join vInventories AS vI 
        ON vP.ProductID = vI.ProductID
        JOIN vEmployees AS vE
        ON vI.EmployeeID = vE.EmployeeID
        WHERE vP.ProductName LIKE 'Cha[i,n]%';
GO

-- Create View
CREATE VIEW vInventoriesForChaiAndChangByEmployees
    AS
    SELECT
        vC.CategoryName AS Categories
        , vP.ProductName AS Products
        , vI.InventoryDate AS 'Inventory date'
        , vI.Count
        , vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS Employee
        FROM vProducts AS vP 
            JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID
            Join vInventories AS vI 
            ON vP.ProductID = vI.ProductID
            JOIN vEmployees AS vE
            ON vI.EmployeeID = vE.EmployeeID
            WHERE vP.ProductName LIKE 'Cha[i,n]%';
GO

-- Check
SELECT * FROM vInventoriesForChaiAndChangByEmployees;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
SELECT * FROM vEmployees;
GO

--Self Join the table
SELECT *
	FROM vEmployees as vEmp Inner JOIN vEmployees vMgr
		On vEmp.ManagerID = vMgr.EmployeeID

-- Build and clean up the columns
SELECT
	vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName As 'Employee'
    , vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName AS 'Manager'
	FROM Employees as vEmp JOIN Employees as vMgr
		On vEmp.ManagerID = vMgr.EmployeeID
		ORDER BY vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName, vEmp.EmployeeFirstName;
GO
-- Create view
CREATE VIEW 
    -- Drop View
        vEmployeesManager
    AS
    SELECT
        vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName As 'Employee'
        , vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName AS 'Manager'
        FROM vEmployees as vEmp JOIN vEmployees as vMgr
            On vEmp.ManagerID = vMgr.EmployeeID;
            -- ORDER BY vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName, vEmp.EmployeeFirstName;
GO

-- Order the results by the Manager's name!
SELECT * FROM vEmployeesManager ORDER BY Manager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- Show all Data BASIC Views? Also show the Employee's Manager Name
SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO
SELECT * FROM vEmployees;
GO
SELECT * FROM vInventories;
GO
-- Join them all
SELECT *
    From vEmployees as vEmp 
        JOIN vEmployees as vMgr
            On vEmp.ManagerID = vMgr.EmployeeID
        LEFT JOIN vInventories AS vI 
            ON vEmp.EmployeeID = vI.EmployeeID
        Left JOIN vProducts AS vP 
            ON vI.ProductID = vP.ProductID
        Left JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID;
GO
-- Clean up
Select vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName AS Employee
    , vEMP.EmployeeID AS 'Employee ID'
    , vEmp.ManagerID AS 'eManager ID'
    , vMgr.EmployeeID AS 'Manger ID'
    , vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName As 'Manager'
    , vI.InventoryDate AS 'Date'
    , vC.CategoryName AS Category
    , vC.CategoryID As 'Category ID'
    , vP.ProductName AS Product
    , vP.UnitPrice AS Price
    , vP.ProductID AS 'Product ID'
    , vI.InventoryID AS 'Inventory ID'
    , vI.Count AS Count 
    From vEmployees as vEmp 
        JOIN vEmployees as vMgr
            On vEmp.ManagerID = vMgr.EmployeeID
        LEFT JOIN vInventories AS vI 
            ON vEmp.EmployeeID = vI.EmployeeID
        Left JOIN vProducts AS vP 
            ON vI.ProductID = vP.ProductID
        Left JOIN vCategories AS vC 
            ON vP.CategoryID = vC.CategoryID;
GO

--CREATE View 
Create View vInventoriesByProductsByCategoriesByEmployees
    AS
    Select vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName AS Employee
        , vEMP.EmployeeID AS 'Employee ID'
        , vEmp.ManagerID AS 'eManager ID'
        , vMgr.EmployeeID AS 'Manger ID'
        , vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName As 'Manager'
        , vI.InventoryDate AS 'Date'
        , vC.CategoryName AS Category
        , vC.CategoryID As 'Category ID'
        , vP.ProductName AS Product
        , vP.UnitPrice AS Price
        , vP.ProductID AS 'Product ID'
        , vI.InventoryID AS 'Inventory ID'
        , vI.Count AS Count 
        From vEmployees as vEmp 
            JOIN vEmployees as vMgr
                On vEmp.ManagerID = vMgr.EmployeeID
            LEFT JOIN vInventories AS vI 
                ON vEmp.EmployeeID = vI.EmployeeID
            Left JOIN vProducts AS vP 
                ON vI.ProductID = vP.ProductID
            Left JOIN vCategories AS vC 
                ON vP.CategoryID = vC.CategoryID;
GO

-- and order the data by Category, Product, InventoryID, and Employee.
SELECT * From vInventoriesByProductsByCategoriesByEmployees ORDER BY Category, Product, 'Inventory ID', Employee;
GO


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
USE Assignment06DB_JRWilson
SELECT * FROM dbo.vCategories; -- Select * From [dbo].[vCategories]
SELECT * FROM dbo.vProducts; -- Select * From [dbo].[vCategories]
SELECT * FROM dbo.vEmployees; -- Select * From [dbo].[vEmployees] 
SELECT * FROM dbo.vInventories;-- Select * From [dbo].[vInventories]
Select * From dbo.vCategoriesProductsAndPrices ORDER BY Categories, 'Product name'; -- Select * From [dbo].[vProductsByCategories]
Select * From dbo.vProductInventoryAndDates Order by 'Product name', Date, Count; -- Select * From [dbo].[vInventoriesByProductsByDates]
Select * FROM dbo.vInventoryDatesByEmployee Order by 'Inventory Date'; -- Select * From [dbo].[vInventoriesByEmployeesByDates]
SELECT * From dbo.vCategorizedProductInventories ORDER BY Categories, Products, 'Inventory date', count; -- Select * From [dbo].[vInventoriesByProductsByCategories]
SELECT * FROM dbo.vCategorizedProductsInventoriedByEmployee ORDER BY 'Inventory date', Categories, Products, Employee; -- Select * From [dbo].[vInventoriesByProductsByEmployees]
SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees
SELECT * FROM dbo.vEmployeesManager ORDER BY Manager -- Select * From [dbo].[vEmployeesByManager]
SELECT * From dbo.vInventoriesByProductsByCategoriesByEmployees ORDER BY Category, Product, 'Inventory ID', Employee;

/***************************************************************************************/
