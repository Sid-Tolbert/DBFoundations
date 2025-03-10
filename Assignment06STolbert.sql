--*************************************************************************--
-- Title: Assignment06
-- Author: SidTolbert
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,SidTolbert,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SidTolbert')
	 Begin 
	  Alter Database [Assignment06DB_SidTolbert] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SidTolbert;
	 End
	Create Database Assignment06DB_SidTolbert;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SidTolbert;

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
create
view vCategories
as
select
[CategoryID],
[CategoryName]
from Assignment06DB_SidTolbert.dbo.Categories

create
view vEmployees
as
select
[EmployeeID],
[EmployeeFirstName],
[EmployeeLastName],
[ManagerID]
from Assignment06DB_SidTolbert.dbo.Employees

create
view vInventories
as
select
[InventoryID],
[InventoryDate],
[EmployeeID],
[ProductID],
[Count]
from Assignment06DB_SidTolbert.dbo.Inventories

create
view vProducts
as
select
[ProductID],
[ProductName],
[CategoryID],
[UnitPrice]
from Assignment06DB_SidTolbert.dbo.Products

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

use Assignment06DB_SidTolbert;

deny select on Categories to public;
grant select on vCategories to public;

deny select on Employees to public;
grant select on vEmployees to public;

deny select on Inventories to public;
grant select on vInventories to public;

deny select on Products to public;
grant select on vProducts to public;
go
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

create
view vProductsByCategories
as 
select
cat.[CategoryName],
prod.[ProductName],
prod.[UnitPrice]
from Assignment06DB_SidTolbert.dbo.Categories as cat
join Assignment06DB_SidTolbert.dbo.Products as prod
on cat.CategoryID = prod.CategoryID
go
select * from vProductsByCategories
order by CategoryName, ProductName
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

create
view vInventoriesByProductsByDates
as 
select
prod.[ProductName],
inv.[InventoryDate],
inv.[Count]
from Assignment06DB_SidTolbert.dbo.Products as prod
join Assignment06DB_SidTolbert.dbo.Inventories as inv
on prod.ProductID = inv.ProductID
go
select * from vInventoriesByProductsByDates
order by ProductName, InventoryDate, [Count]
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

create
view vInventoriesByEmployeesByDates
as 
select Distinct
inv.[InventoryDate],
[EmployeeName] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
from Assignment06DB_SidTolbert.dbo.Inventories as inv
join Assignment06DB_SidTolbert.dbo.Employees as emp
on inv.EmployeeID = emp.EmployeeID
go
select * from vInventoriesByEmployeesByDates
order by InventoryDate
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

create 
view vInventoriesByProductsByCategories
as 
select
cat.CategoryName,
prod.ProductName,
inv.InventoryDate,
inv.[Count]
from Assignment06DB_SidTolbert.dbo.Categories as cat
join Assignment06DB_SidTolbert.dbo.Products as prod
on cat.CategoryID = prod.CategoryID
join Assignment06DB_SidTolbert.dbo.Inventories as inv
on prod.ProductID = inv.ProductID
go
select * from vInventoriesByProductsByCategories
order by CategoryName, ProductName, InventoryDate, [Count]


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
create 
view vInventoriesByProductsByEmployees
as 
select
cat.CategoryName,
prod.ProductName,
inv.InventoryDate,
inv.[Count],
[EmployeeName] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName

from Assignment06DB_SidTolbert.dbo.Categories as cat
join Assignment06DB_SidTolbert.dbo.Products as prod
on cat.CategoryID = prod.CategoryID
join Assignment06DB_SidTolbert.dbo.Inventories as inv
on prod.ProductID = inv.ProductID
join Assignment06DB_SidTolbert.dbo.Employees as emp
on inv.EmployeeID = emp.EmployeeID
go
select * from vInventoriesByProductsByEmployees
order by InventoryDate, CategoryName, ProductName, EmployeeName


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

create 
view vInventoriesForChaiAndChangByEmployees
as 
select
cat.CategoryName,
prod.ProductName,
inv.InventoryDate,
inv.[Count],
[EmployeeName] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName

from Assignment06DB_SidTolbert.dbo.Categories as cat
join Assignment06DB_SidTolbert.dbo.Products as prod
on cat.CategoryID = prod.CategoryID
join Assignment06DB_SidTolbert.dbo.Inventories as inv
on prod.ProductID = inv.ProductID
join Assignment06DB_SidTolbert.dbo.Employees as emp
on inv.EmployeeID = emp.EmployeeID
go
select * from vInventoriesForChaiAndChangByEmployees
where ProductName like '%Chai' or ProductName like '%Chang'
order by InventoryDate, CategoryName, ProductName, EmployeeName

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

create
view vEmployeesByManager
as
select
a.EmployeeFirstName + ' ' + a.EmployeeLastName as Manager,
b.EmployeeFirstName + ' ' + b.EmployeeLastName as Employee

from Employees as a
right join Employees as b
on a.EmployeeID = b.ManagerID
go
select * from vEmployeesByManager
order by Manager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

create 
view vInventoriesByProductsByCategoriesByEmployees
as
select 
cat.CategoryID,
cat.CategoryName,
prod.ProductID,
prod.ProductName,
prod.UnitPrice,
inv.InventoryID,
inv.InventoryDate,
inv.[Count],
emp.EmployeeID,
emp.EmployeeFirstName + ' ' + emp.EmployeeLastName AS EmployeeName,
mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName AS ManagerName

from Assignment06DB_SidTolbert.dbo.Categories as cat
JOIN Assignment06DB_SidTolbert.dbo.Products as prod
    on cat.CategoryID = prod.CategoryID
JOIN Assignment06DB_SidTolbert.dbo.Inventories as inv
    on prod.ProductID = inv.ProductID
JOIN Assignment06DB_SidTolbert.dbo.Employees as emp
    on inv.EmployeeID = emp.EmployeeID
LEFT JOIN Assignment06DB_SidTolbert.dbo.Employees as mgr
    on emp.ManagerID = mgr.EmployeeID
go

select * 
from vInventoriesByProductsByCategoriesByEmployees
order by CategoryName, ProductName, InventoryID, EmployeeName;
go




-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/