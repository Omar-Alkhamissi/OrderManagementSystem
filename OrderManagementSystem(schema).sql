/* Final Project 1 */

DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Shippers;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Employees;


--Suppliers
CREATE TABLE Suppliers 
( 
  SupplierID  SMALLINT, 
  CompanyName  VARCHAR(40) NOT NULL, 
  ContactName  VARCHAR(30), 
  ContactTitle  VARCHAR(30), 
  Address  VARCHAR(60), 
  City  VARCHAR(15), 
  Region  VARCHAR(15), 
  PostalCode  VARCHAR(10), 
  Country  VARCHAR(15), 
  Phone  VARCHAR(24), 
  Fax  VARCHAR(24), 
  HomePage  VARCHAR(200), 
  CONSTRAINT Suppliers_SupplierID_pk PRIMARY KEY (SupplierID)
); 

-- Categories
CREATE TABLE Categories 
( 
  CategoryID  SMALLINT, 
  CategoryName  VARCHAR(15) NOT NULL, 
  CategoryCode SMALLINT,
  Description  VARCHAR(300),
  CONSTRAINT Categories_CategoryID_pk PRIMARY KEY (CategoryID),
  CONSTRAINT Categories_CategoryCode_uk UNIQUE (CategoryCode) 
); 

--Products
CREATE TABLE Products 
( 
  ProductID  SMALLINT, 
  ProductName  VARCHAR(40) NOT NULL, 
  SupplierID  SMALLINT, 
  CategoryID  SMALLINT, 
  QuantityPerUnit  SMALLINT, 
  UnitPrice  MONEY, 
  UnitsInStock  SMALLINT, 
  UnitsOnOrder  SMALLINT, 
  ReorderLevel  SMALLINT, 
  Discontinued  SMALLINT NOT NULL, 
  CONSTRAINT Products_ProductID_pk PRIMARY KEY (ProductID),
  CONSTRAINT Products_Categories_fk FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID), 
  CONSTRAINT Products_Suppliers_fk FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
  CONSTRAINT Products_UnitPrice_ck CHECK (UnitPrice >= 0), 
  CONSTRAINT Products_ReorderLevel_ck CHECK (ReorderLevel >= 0), 
  CONSTRAINT Products_UnitsInStock_ck CHECK (UnitsInStock >= 0), 
  CONSTRAINT Products_UnitsOnOrder_ck CHECK (UnitsOnOrder >= 0) 
);

-- Customers
CREATE TABLE Customers 
( 
  CustomerID  CHAR(5), 
  CompanyName  VARCHAR(40) NOT NULL, 
  ContactName  VARCHAR(30), 
  ContactTitle  VARCHAR(30), 
  Address  VARCHAR(60), 
  City  VARCHAR(15), 
  Region  VARCHAR(15), 
  PostalCode  VARCHAR(10), 
  Country  VARCHAR(15), 
  Phone  VARCHAR(24), 
  Fax  VARCHAR(24),
  Email VARCHAR(50) NULL,
  CONSTRAINT Customers_CustomerID_pk PRIMARY KEY (CustomerID),
); 

-- Employees
CREATE TABLE Employees 
( 
  EmployeeID  SMALLINT, 
  LastName  VARCHAR(20) NOT NULL, 
  FirstName  VARCHAR(10) NOT NULL, 
  Title  VARCHAR(30), 
  TitleOfCourtesy  VARCHAR(25), 
  BirthDate  DATE, 
  HireDate  DATE, 
  Address  VARCHAR(60), 
  City  VARCHAR(15), 
  Region  VARCHAR(15), 
  PostalCode  VARCHAR(10), 
  Country  VARCHAR(15), 
  HomePhone  VARCHAR(24), 
  Extension  VARCHAR(4), 
  Notes  VARCHAR(600), 
  ReportsTo  SMALLINT, 
  PhotoPath  VARCHAR(255),
  SIN        CHAR(9), 
  CONSTRAINT Employees_EmployeeID_pk PRIMARY KEY (EmployeeID),
  CONSTRAINT Employees_Employees_fk FOREIGN KEY (ReportsTo) REFERENCES Employees(EmployeeID),
  CONSTRAINT Employees_SIN_uk UNIQUE (SIN)
);  

--Shippers
CREATE TABLE Shippers 
( 
  ShipperID  SMALLINT, 
  CompanyName  VARCHAR(40) NOT NULL, 
  Phone  VARCHAR(24), 
  CONSTRAINT Shippers_ShipperID_pk PRIMARY KEY (ShipperID)
);

--Orders
CREATE TABLE Orders 
( 
  OrderID  SMALLINT, 
  CustomerID  CHAR(5), 
  EmployeeID  SMALLINT, 
  TerritoryID  VARCHAR(20), 
  OrderDate  DATE, 
  RequiredDate  DATE, 
  ShippedDate  DATE, 
  ShipVia  SMALLINT, 
  Freight  MONEY, 
  ShipName  VARCHAR(40), 
  ShipAddress  VARCHAR(60), 
  ShipCity  VARCHAR(15), 
  ShipRegion  VARCHAR(15), 
  ShipPostalCode  VARCHAR(10), 
  ShipCountry  VARCHAR(15), 
  CONSTRAINT Orders_OrderID_pk PRIMARY KEY (OrderID), 
  CONSTRAINT Orders_Customers_fk FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID), 
  CONSTRAINT Orders_Employees_fk FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID), 
  CONSTRAINT Orders_Shippers_fk FOREIGN KEY (ShipVia) REFERENCES Shippers(ShipperID)
);

--OrderDetails
CREATE TABLE OrderDetails 
( 
  OrderID  SMALLINT, 
  ProductID  SMALLINT, 
  UnitPrice  MONEY NOT NULL, 
  Quantity  SMALLINT NOT NULL, 
  Discount  DECIMAL(2,2) NOT NULL, 
  CONSTRAINT OrderDetails_OID_PID_pk PRIMARY KEY (OrderID, ProductID), 
  CONSTRAINT OrderDetails_Orders_fk FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), 
  CONSTRAINT OrderDetails_Products_fk FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
  CONSTRAINT OrderDetails_Discount_ck CHECK (Discount >= 0 and Discount <= 1), 
  CONSTRAINT OrderDetails_Quantity_ck CHECK (Quantity > 0), 
  CONSTRAINT OrderDetails_UnitPrice_ck CHECK (UnitPrice >= 0)
);


-- confirm there are 25 constraints
select TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME LIKE '%_pk' UNION
select TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME LIKE '%_fk' UNION
select TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME LIKE '%_uk' UNION
select TABLE_NAME, CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME LIKE '%_ck'
ORDER BY 1
 
