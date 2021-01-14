/*============================= INITIALIZING =============================*/
/* Creating the database */
CREATE DATABASE OWISDB
GO

USE OWISDB
GO

/* Creating the login */
CREATE LOGIN owisLogin WITH PASSWORD=N'iküOwisAdmin', 
DEFAULT_DATABASE= OWISDB, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

/* Creating the schema */
CREATE SCHEMA owis
GO

/*============================= TABLES =============================*/
CREATE TABLE owis.Warehouses( /* The information about warehouses */
warehouseID INT IDENTITY PRIMARY KEY NOT NULL,
warehouseName varchar(30) NOT NULL,
country varchar(20) NOT NULL,
city varchar(20) NOT NULL,
warehouseAddress varchar(50) NOT NULL,
ZIP varchar(5) NOT NULL,
warehouseStatus varchar(20) DEFAULT 'Stable',  
phoneNumber varchar(15) UNIQUE NOT NULL,
email varchar(30) UNIQUE NOT NULL,
maxCapacity INT CHECK(maxCapacity>=0) NOT NULL,
currentCapacity INT DEFAULT 0,
CHECK(currentCapacity <= maxCapacity AND currentCapacity >= 0) 
);

CREATE TABLE owis.Products( /* The information about products*/
productID INT IDENTITY PRIMARY KEY NOT NULL,
productName varchar(30) NOT NULL,
productDescription varchar(30),
manufacturer varchar(20) DEFAULT 'None',
productWeight float NOT NULL, 
inStock bit NOT NULL, 
totalQuantity INT NOT NULL CHECK(totalQuantity>=0) DEFAULT 0, 
CHECK(totalQuantity=0 AND inStock=0 OR totalQuantity>0 AND inStock=1)
);

CREATE TABLE owis.WarehouseContents( /* The contents of the warehouses */
warehouseID INT NOT NULL,
productID INT NOT NULL,
quantity INT CHECK(quantity>=0) NOT NULL DEFAULT 0,
FOREIGN KEY(warehouseID) REFERENCES owis.Warehouses(warehouseID) ON DELETE CASCADE,
FOREIGN KEY(productID) REFERENCES owis.Products(productID) ON DELETE CASCADE
);

CREATE TABLE owis.Users( /* The information about users and their accounts*/
userID INT IDENTITY PRIMARY KEY NOT NULL,
userName varchar(20) NOT NULL,
userPassword varchar(20) NOT NULL,
firstName varchar(30) NOT NULL,
lastName varchar(20) NOT NULL,
userGender varchar(6),
userAge INT CHECK(userAge >= 18) NOT NULL,
userType char(1) NOT NULL DEFAULT 0, /* 0 -> basic user ====== 1 -> staff ======= 2 -> admin */
userAddress varchar(50),
phoneNumber varchar(15) UNIQUE NOT NULL,
email varchar(30) UNIQUE NOT NULL
);

CREATE TABLE owis.Staff( /* The information about staff users */
staffID INT IDENTITY PRIMARY KEY NOT NULL,
userID INT NOT NULL,
warehouseID INT NOT NULL, 
title varchar(20) DEFAULT 'Staff',
FOREIGN KEY(userID) REFERENCES owis.Users(userID) ON DELETE CASCADE,
FOREIGN KEY(warehouseID) REFERENCES owis.Warehouses(warehouseID)
);

CREATE TABLE owis.Orders( /* The records of current orders ( incoming )*/
orderID INT IDENTITY PRIMARY KEY NOT NULL,
staffID INT,
warehouseID INT NOT NULL, 
orderDescription nvarchar(100),
orderDate DATETIME NOT NULL DEFAULT GETDATE(),
FOREIGN KEY(staffID) REFERENCES owis.Staff(staffID),
FOREIGN KEY(warehouseID) REFERENCES owis.Warehouses(warehouseID) 
);

CREATE TABLE owis.Shipments( /* The records of current shipments ( outgoing )*/ 
shipmentID INT IDENTITY PRIMARY KEY NOT NULL,
staffID INT,
warehouseID INT NOT NULL, 
shipmentDescription nvarchar(100),
shipmentDate DATETIME NOT NULL DEFAULT GETDATE(),
FOREIGN KEY(staffID) REFERENCES owis.Staff(staffID),
FOREIGN KEY(warehouseID) REFERENCES owis.Warehouses(warehouseID) 
);

CREATE TABLE owis.Payments( /* The records of payments which are belonging to orders */
paymentID INT NOT NULL PRIMARY KEY IDENTITY,
orderID INT NOT NULL,
invoiceID varchar(10) UNIQUE NOT NULL, 
paymentType varchar(15) NOT NULL, 
amount INT NOT NULL,
operationDate DATETIME NOT NULL DEFAULT GETDATE(),
FOREIGN KEY(orderID) REFERENCES owis.Orders(orderID) ON DELETE CASCADE
);

CREATE TABLE owis.Bills(  /* The records of bills which are belonging to shipments */
billID INT NOT NULL PRIMARY KEY IDENTITY,
shipmentID INT NOT NULL,
invoiceID varchar(10) UNIQUE NOT NULL, 
paymentType varchar(15) NOT NULL, 
amount INT NOT NULL,
operationDate DATETIME NOT NULL DEFAULT GETDATE(),
FOREIGN KEY(shipmentID) REFERENCES owis.Shipments(shipmentID) ON DELETE CASCADE
);

CREATE TABLE owis.Suppliers( /* The suppliers of the packages */
supplierID INT IDENTITY PRIMARY KEY NOT NULL,
supplierName varchar(20) NOT NULL,
country varchar(20) NOT NULL,
city varchar(20) NOT NULL,
supplierAddress varchar(50),
phoneNumber varchar(15) UNIQUE NOT NULL,
email varchar(30) UNIQUE NOT NULL
);

CREATE TABLE owis.Packages( /* The records of the incoming or outgoing packages */
packageID INT IDENTITY PRIMARY KEY NOT NULL,
isProvided bit NOT NULL, /* 0 -> incoming ====== 1 -> outgoing*/
orderID INT, /* If isProvided is 0, this column must have record */
shipmentID INT, /* If isProvided is 1, this column must have record */
supplierID INT NOT NULL, 
createdTime DATETIME NOT NULL DEFAULT GETDATE(),
packageStatus varchar(20) NOT NULL DEFAULT 'Preparing',
notes varchar(100),
CHECK(isProvided=0 AND orderID IS NOT NULL OR isProvided=1 AND shipmentID IS NOT NULL),
FOREIGN KEY(orderID) REFERENCES owis.Orders(orderID),
FOREIGN KEY(shipmentID) REFERENCES owis.Shipments(shipmentID),
FOREIGN KEY(supplierID) REFERENCES owis.Suppliers(supplierID) ON DELETE CASCADE
);

CREATE TABLE owis.PackageContents( /* The contents of the packages */
contentID INT IDENTITY PRIMARY KEY NOT NULL,
packageID INT NOT NULL,
productID INT NOT NULL,
productQuantity INT NOT NULL DEFAULT 0,
FOREIGN KEY(productID) REFERENCES owis.Products(productID) ON DELETE CASCADE,
FOREIGN KEY(packageID) REFERENCES owis.Packages(packageID) ON DELETE CASCADE
);

CREATE TABLE owis.Shipping( /* The shipping detail of the packages */
packageID INT PRIMARY KEY NOT NULL,
shippingDate DATETIME NOT NULL DEFAULT GETDATE(),
estimatedDeliveryDate DATE, 
deliveryDate DATE,  
currentLocation varchar(20) NOT NULL,
currentStatus varchar(20) NOT NULL DEFAULT 'Pending',
shippingNote varchar(100),
FOREIGN KEY(packageID) REFERENCES owis.Packages(packageID) ON DELETE CASCADE
);

CREATE TABLE owis.Inventory( /* Current inventory */
productID INT NOT NULL,
totalQuantity INT NOT NULL CHECK(totalQuantity>=0) DEFAULT 0,
updateDate DATETIME NOT NULL DEFAULT GETDATE(),
FOREIGN KEY(productID) REFERENCES owis.Products(productID)
);
GO

/*============================= VIEWS =============================*/
CREATE VIEW owis.userTypeStaff /* Shows user information with staff information for all staff members */
AS
SELECT
	u.userName,
	u.firstName,
	u.lastName,
	u.userAge,
	u.userGender,
	u.email,
	s.warehouseID,
	s.staffID,
	s.title
FROM
    owis.Staff AS s
INNER JOIN owis.Users AS u
    ON u.userID = s.userID
GO

CREATE VIEW owis.localPackages /* Shows all packages from suppliers which are within "Turkey" */
AS
SELECT
	p.packageID,
	p.isProvided,
	CASE WHEN p.isProvided = 0 THEN p.orderID END AS orderID,
	CASE WHEN p.isProvided = 1 THEN p.shipmentID END AS shipmentID,
	p.createdTime,
	p.packageStatus,
	p.supplierID,
	s.supplierName,
	s.city,
	s.supplierAddress,
	s.email
FROM
    owis.Packages AS p
INNER JOIN owis.Suppliers AS s
    ON s.supplierID= p.supplierID
WHERE s.country LIKE '%turkey%' OR s.country LIKE '%Turkey%' OR s.country LIKE '%TURKEY%'
GO

CREATE VIEW owis.shipmentPaidByCash /* Shows all shipments that are all paid by cash */
AS
SELECT
	s.shipmentID,
	s.shipmentDescription,
	s.shipmentDate,
	b.invoiceID,
	b.amount,
	b.operationDate
FROM
    owis.Shipments AS s
INNER JOIN owis.Bills AS b
    ON s.shipmentID = b.shipmentID
WHERE b.paymentType LIKE '%cash%' OR b.paymentType LIKE '%Cash%' OR b.paymentType LIKE '%CASH%' 
GO


CREATE VIEW owis.orderPaidByCreditCard /* Shows all orders that are all paid by cash */
AS 
SELECT 
    o.orderID,
    o.orderDescription,
    o.orderDate,
    p.invoiceID,
    p.amount,
    p.operationDate
FROM
    owis.Orders AS o
INNER JOIN owis.Payments AS p
    ON o.orderID = p.orderID 
WHERE p.paymentType LIKE '%credit card%' OR p.paymentType LIKE '%Credit Card%' OR p.paymentType LIKE '%CREDIT CARD%'
GO

CREATE VIEW owis.pendingPackage /* Shows all packages that are pending at the moment */
AS 
SELECT 
    p.packageID,
    p.shipmentID,
    p.supplierID,
    p.createdTime,
    s.shippingDate,
    s.estimatedDeliveryDate,
    s.currentLocation
FROM
    owis.Packages AS p
INNER JOIN owis.Shipping AS s
    ON p.packageID = s.packageID 
WHERE s.currentStatus LIKE '%pending%' OR s.currentStatus LIKE '%Pending%' OR s.currentStatus LIKE '%PENDING%'
GO

CREATE VIEW owis.ordersFromAbroad /* Shows all orders from abroad */
AS
SELECT
	o.orderID,
	o.orderDescription,
	o.orderDate,
	o.warehouseID,
	w.warehouseName,
	w.city,
	w.currentCapacity,
	w.warehouseStatus,
	w.email
FROM
    owis.Orders AS o
INNER JOIN owis.Warehouses AS w
    ON o.warehouseID = w.warehouseID
WHERE w.country NOT LIKE '%turkey%' OR w.country NOT LIKE '%Turkey%' OR w.country NOT LIKE '%TURKEY%' 
GO

CREATE VIEW owis.sentPackages /* Shows all packages which sent by company */
AS 
SELECT 
    p.packageID,
    p.shipmentID,
    p.createdTime
FROM
    owis.Packages AS p
INNER JOIN owis.Suppliers AS s
    ON p.supplierID = s.supplierID 
WHERE s.supplierID = 1
GO

CREATE VIEW owis.receivedPackages /* Shows all packages which sent to company */
AS 
SELECT 
    p.packageID,
    p.shipmentID,
    p.createdTime,
    s.supplierID,
    s.supplierName,
	s.country,
	s.city,
    s.supplierAddress,
    s.phoneNumber,
    s.email
FROM
    owis.Packages AS p
INNER JOIN owis.Suppliers AS s
    ON p.supplierID = s.supplierID 
WHERE p.isProvided = 0
GO


CREATE VIEW owis.packageWeights /* Calculates the weights of all Packages */
AS
SELECT
	c.packageID,
	SUM(c.productQuantity * p.productWeight) as packageWeightKG
FROM
    owis.PackageContents AS c
INNER JOIN owis.Products AS p
    ON p.productID = c.productID
GROUP BY c.packageID
GO


CREATE VIEW owis.detailedPackages /* Shows packages with detailed supplier and weight info */
AS
SELECT
	p.packageID,
	p.shipmentID,
	p.orderID,
	p.isProvided,
	p.notes,
	w.PackageWeightKG,
	p.packageStatus,
	p.supplierID,
	s.supplierName,
	s.country,
	s.city,
	p.createdTime
FROM owis.Packages AS p
INNER JOIN owis.packageWeights AS w
	ON p.packageID = w.packageID
INNER JOIN owis.Suppliers AS s
	ON s.supplierID = p.supplierID
GO
 
CREATE VIEW owis.totalPaidmoney /* Calculates total amount of money paid for orders */
AS 
SELECT 
    SUM(p.amount) AS totalPaidMoney
FROM
    owis.Payments AS p
GO

CREATE VIEW owis.totalEarnedmoney /* Calculates total amount of money earned from shipments */
AS 
SELECT 
    SUM(b.amount) AS totalPaidMoney
FROM
    owis.Bills AS b
GO

CREATE VIEW owis.warehouseStaff /* Shows each staff of a spesific warehouse one by one with user detail */
AS 
SELECT 
	w.warehouseID,
	w.warehouseName,
	w.country,
	w.city,
	w.currentCapacity,
	u.staffID,
	u.firstName,
	u.lastName,
	u.title
FROM
	owis.Warehouses AS w
INNER JOIN owis.userTypeStaff AS u
	ON w.warehouseID = u.warehouseID
GROUP BY w.warehouseID,w.warehouseName,w.country,w.city,w.currentCapacity,u.staffID,u.firstName,u.lastName,u.title
GO 

CREATE VIEW owis.warehouseStaffCount /* Counts staff members of each warehouse separately */
AS 
SELECT 
	w.warehouseID,
	w.warehouseName,
	w.currentCapacity,
	w.country,
	w.city,
	COUNT(w.staffID) AS staffCount
FROM
	owis.warehouseStaff AS w
GROUP BY w.warehouseID,w.warehouseName,w.currentCapacity,w.country,w.city
GO

CREATE VIEW owis.getPackageContents
AS
SELECT
	pc.packageID,
	pc.productID,
	p.productName,
	pc.productQuantity
	FROM owis.Products p INNER JOIN 
	(SELECT packageID, productID, SUM(pc.productQuantity) AS productQuantity
	FROM owis.PackageContents pc GROUP BY pc.packageID, pc.productID) 
	AS pc ON p.productID = pc.productID
GO

/*============================= FUNCTIONS =============================*/
CREATE FUNCTION owis.getStockFromWarehouse(@productID INT,@warehouseID INT) /* Returns the current stock of a spesific product in a spesific warehouse */ 
RETURNS INT
AS   
BEGIN  
    DECLARE @ret INT;  
    SELECT 
		@ret = w.quantity
    FROM owis.WarehouseContents AS w
	WHERE w.warehouseID = @warehouseID
        AND w.productID = @productID  
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END
GO

CREATE FUNCTION owis.getWarehouseCurrentCapacity(@warehouseID INT) /* Returns the current capacity of a spesific warehouse over 100%*/
RETURNS INT
AS   
BEGIN  
    DECLARE @ret INT;  
    SELECT 
		@ret = (w.currentCapacity / w.maxCapacity) * 100
    FROM owis.Warehouses AS w
	WHERE w.warehouseID = @warehouseID
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END
GO

CREATE FUNCTION owis.checkWarehousesWithProductQuantity(@productID INT,@quantity INT) /* Returns the available warehouses that has the given product with at least given quantity */
RETURNS TABLE
AS   
RETURN(
    SELECT 
		w.warehouseID,
		wr.warehouseName,
		wr.country,
		wr.city,
		wr.currentCapacity,
		wr.warehouseStatus,
		w.quantity
    FROM owis.WarehouseContents AS w
	INNER JOIN owis.Warehouses AS wr
		ON wr.warehouseID = w.warehouseID
	WHERE @productID = w.productID 
        AND w.quantity > @quantity
)
GO


/*============================= TRIGGERS =============================*/
CREATE TRIGGER addStaffInfo   /* When added an user with user type 1,automatically adds a staff for new user with default information into the staff table */
ON owis.Users
AFTER INSERT
AS
 BEGIN
	DECLARE @userID INT
	DECLARE @userType char(1)

	SELECT @userID = userID, @userType = userType FROM inserted
	
	IF (@userType = '1')
		BEGIN
			INSERT INTO owis.Staff(userID, warehouseID, title) VALUES(@userID, 1, 'Staff')
		END

 END

GO

CREATE TRIGGER updateProductQuantityOrderDeleted
ON owis.Orders
AFTER DELETE
AS
 BEGIN
	DECLARE @orderID INT
	DECLARE @packageID INT
	DECLARE @productID INT

	SELECT @orderID = orderID FROM deleted
	SELECT @packageID = packageID FROM owis.Packages WHERE orderID = @orderID
	
	DELETE FROM owis.PackageContents WHERE packageID = @packageID

 END
GO

CREATE TRIGGER updateStockQuantity  /* Update product's stock in product table when a new package content is added */
ON [owis].[PackageContents]
AFTER INSERT 
AS
 BEGIN
	DECLARE @packageID INT
	DECLARE @isProvided BIT
	DECLARE @productQuantityInPackage INT
	DECLARE @productID INT
	DECLARE @total_quantity INT
	DECLARE @shipmentID INT
	DECLARE @warehouseID INT
	DECLARE @counter INT
	DECLARE @orderID INT

	SELECT @packageID = packageID, @productQuantityInPackage = productQuantity, @productID = productID FROM inserted
	SELECT @isProvided = isProvided FROM owis.Packages WHERE packageID = @packageID
	
	IF (@isProvided = 1)
		BEGIN
			SELECT @shipmentID = shipmentID FROM owis.Packages WHERE packageID = @packageID
			SELECT @warehouseID = warehouseID FROM owis.Shipments WHERE shipmentID = @shipmentID
			SELECT @total_quantity = SUM(quantity) FROM owis.WarehouseContents WHERE warehouseID = @warehouseID AND productID = @productID
			
			IF(@total_quantity >= @productQuantityInPackage)
				BEGIN

				IF((SELECT COUNT(*) FROM owis.WarehouseContents WHERE warehouseID = @warehouseID 
				AND productID = @productID AND @total_quantity >= @productQuantityInPackage) > 0)
					BEGIN
					
					UPDATE owis.Products
					SET totalQuantity = totalQuantity - @productQuantityInPackage
					WHERE productID = @productID
					
					UPDATE owis.WarehouseContents
					SET quantity = quantity - @productQuantityInPackage
					WHERE warehouseID = @warehouseID AND productID = @productID 

					SELECT @counter = @@ROWCOUNT
					SET @productQuantityInPackage = @productQuantityInPackage - (@productQuantityInPackage / @counter)

					UPDATE owis.WarehouseContents
					SET quantity = quantity + @productQuantityInPackage
					WHERE warehouseID = @warehouseID AND productID = @productID
					END
				ELSE
					BEGIN
						ALTER TABLE owis.PackageContents DISABLE TRIGGER afterDelete
						DELETE TOP(1) FROM owis.PackageContents WHERE packageID = @packageID AND productID = @productID AND productQuantity = @productQuantityInPackage
						ALTER TABLE owis.PackageContents ENABLE TRIGGER afterDelete
					END
				END
			ELSE
				BEGIN
					ALTER TABLE owis.PackageContents DISABLE TRIGGER afterDelete
					DELETE TOP(1) FROM owis.PackageContents WHERE packageID = @packageID AND productID = @productID AND productQuantity = @productQuantityInPackage
					ALTER TABLE owis.PackageContents ENABLE TRIGGER afterDelete
				END
		END
	ELSE IF(@isProvided = 0)
		BEGIN
		
		SELECT @orderID = orderID FROM owis.Packages WHERE packageID = @packageID
		SELECT @warehouseID = warehouseID FROM owis.Orders WHERE orderID = @orderID
			
		UPDATE owis.Products
		SET totalQuantity = totalQuantity + @productQuantityInPackage
		WHERE productID = @productID
		
		UPDATE owis.WarehouseContents
		SET quantity = quantity + @productQuantityInPackage
		WHERE warehouseID = @warehouseID AND productID = @productID 

		SELECT @counter = @@ROWCOUNT
		IF(@counter > 0)
			BEGIN
			SET @productQuantityInPackage = @productQuantityInPackage - (@productQuantityInPackage / @counter)

			UPDATE owis.WarehouseContents
			SET quantity = quantity - @productQuantityInPackage
			WHERE warehouseID = @warehouseID AND productID = @productID
			END

		END
	END
 GO

CREATE TRIGGER afterDelete
ON owis.packageContents
AFTER DELETE 
AS
 BEGIN
	DECLARE @packageID INT
	DECLARE @isProvided BIT
	DECLARE @productQuantityInPackage INT
	DECLARE @productID INT

	SELECT @packageID = packageID, @productQuantityInPackage = SUM(productQuantity), @productID = productID FROM deleted GROUP BY packageID, productID
	SELECT @isProvided = isProvided FROM owis.Packages WHERE packageID = @packageID
	
	IF (@isProvided = 1)
		BEGIN
		UPDATE owis.Products
		SET totalQuantity = totalQuantity + @productQuantityInPackage
		WHERE productID = @productID
		END
		
	ELSE IF(@isProvided = 0)
		BEGIN
		UPDATE owis.Products
		SET totalQuantity = totalQuantity - @productQuantityInPackage
		WHERE productID = @productID
		END

 END
 GO


CREATE TRIGGER addInventoryStock /* Insert a new record to inventory when a new product is added */
ON owis.Products
AFTER INSERT
AS
 BEGIN
	
	DECLARE @productID INT
	DECLARE @productQuantity INT
	DECLARE @inStock BIT

	SELECT @productID = productID, @productQuantity= totalQuantity, @inStock = inStock FROM inserted
	IF(@inStock = 1)
		BEGIN
		INSERT INTO owis.Inventory(productID, totalQuantity, updateDate)
		VALUES(@productID, @productQuantity, GETDATE())
		END

 END
GO

CREATE TRIGGER changeInventoryStock /* Update the inventory when the product is updated */
ON owis.Products
AFTER UPDATE
AS
 BEGIN
	
	DECLARE @productID INT
	DECLARE @productQuantity INT

	SELECT @productID = productID, @productQuantity= totalQuantity FROM inserted
	
	UPDATE owis.Inventory
	SET totalQuantity = @productQuantity
	WHERE productID = @productID

 END
GO

CREATE TRIGGER updateStaffOnWarehouseDelete /* When a warehouse is removed, assign the staff members of removed warehouse to the centre warehouse (ID = 1 ) */
ON owis.Warehouses
INSTEAD OF DELETE
AS
 BEGIN

    DECLARE @warehouseID INT
    DECLARE @staffID INT

    SELECT @warehouseID = warehouseID FROM deleted

    UPDATE owis.Staff
    SET warehouseID = 1
    WHERE warehouseID = @warehouseID

    DELETE FROM owis.Warehouses WHERE warehouseID = @warehouseID

 END
GO

CREATE TRIGGER shipmentDateCheck /* Checks if the shipment date is after package creation time or not */
ON owis.Packages
FOR INSERT, UPDATE
AS
 BEGIN
	DECLARE @shipmentID INT
	DECLARE @shipmentDate DATETIME
	DECLARE @packageCreateTime DATETIME
	DECLARE @currDate DATETIME

	SELECT @shipmentID = shipmentID, @packageCreateTime = createdTime FROM inserted
	SELECT @shipmentDate = shipmentDate FROM owis.Shipments WHERE shipmentID = @shipmentID

	IF(@shipmentDate > @packageCreateTime)
		BEGIN
			PRINT 'Shipment date must be before package create time'
			UPDATE owis.Packages
			SET createdTime = GETDATE() 
			WHERE shipmentID = @shipmentID
		END	

 END
GO


CREATE TRIGGER orderDateCheck  /* Checks if the order date is after package creation time or not */ 
ON owis.Packages
FOR INSERT, UPDATE
AS
 BEGIN
	DECLARE @orderID INT
	DECLARE @orderDate DATETIME
	DECLARE @packageCreateTime DATETIME
	DECLARE @currDate DATETIME

	SELECT @orderID = orderID, @packageCreateTime = createdTime FROM inserted
	SELECT @orderDate = orderDate FROM owis.Orders WHERE orderID = @orderID

	IF(@orderDate > @packageCreateTime)
		BEGIN
			PRINT 'Order date must be before package create time'
			UPDATE owis.Packages
			SET createdTime = GETDATE() 
			WHERE orderID = @orderID
		END	

 END
GO


CREATE TRIGGER checkWarehouseOpened /* Checks if an unstable warehouse is in use for any shipment */
ON owis.Shipments
AFTER INSERT
AS
 BEGIN
	DECLARE @shipmentID INT
	DECLARE @warehouseID INT
	DECLARE @warehouseStatus varchar(20)

	SELECT @shipmentID = shipmentID FROM inserted
	SELECT @warehouseID = warehouseID FROM owis.Shipments WHERE shipmentID = @shipmentID
	SELECT @warehouseStatus = warehouseStatus FROM owis.Warehouses WHERE warehouseID = @warehouseID

	IF(@warehouseStatus = 'Closed' OR @warehouseStatus = 'Defective')
		BEGIN
			RAISERROR('This warehouse is not stable', 0, 1);
			ROLLBACK;
		END

 END
GO

CREATE TRIGGER updateProductQuantityInInventory /* When a product existing in the inventory table inserted, update its quantity */
ON owis.Inventory
INSTEAD OF INSERT
AS
 BEGIN
	DECLARE @productID INT
	DECLARE @quantity INT
	DECLARE @date DATETIME
	DECLARE @inStock BIT

	SELECT @productID = productID, @quantity = totalQuantity, @date=updateDate FROM inserted

	IF EXISTS(
         SELECT * FROM owis.Inventory WHERE
            productID IN (SELECT productID FROM inserted)
         GROUP BY productID HAVING COUNT(*) >= 1)
		BEGIN
			UPDATE owis.Inventory
			SET totalQuantity = totalQuantity + @quantity
			WHERE productID = @productID

			UPDATE owis.Inventory
			SET updateDate = @date
			WHERE productID = @productID

			UPDATE owis.Products
			SET totalQuantity = totalQuantity + @quantity
			WHERE productID = @productID

		END
	ELSE
		BEGIN
		SELECT @inStock = inStock FROM owis.Products WHERE productID = @productID
		IF(@inStock = 0)
			BEGIN 
			
			UPDATE owis.Products
			SET inStock = 1, totalQuantity = @quantity
			WHERE productID = @productID
			
			INSERT INTO owis.Inventory(productID, totalQuantity, updateDate)
			VALUES(@productID, @quantity,@date)

			END
		ELSE
			BEGIN

			INSERT INTO owis.Inventory(productID, totalQuantity, updateDate)
			VALUES(@productID, @quantity,@date)
			END
		END
 END
GO

CREATE TRIGGER updateCurrentCapacity  /* When a new package content is added, update its warehouse */
ON owis.WarehouseContents
AFTER INSERT 
AS
 BEGIN
	DECLARE @warehouseID INT
	DECLARE @quantity INT

	SELECT @warehouseID = warehouseID, @quantity = quantity FROM inserted
	
	UPDATE owis.Warehouses
	SET currentCapacity = currentCapacity + @quantity
	WHERE warehouseID = @warehouseID
 END
GO

CREATE TRIGGER deleteProductFromInventory /* When a product is deleted, delete from both inventory and products tables */ 
ON owis.Products
INSTEAD OF DELETE
AS
 BEGIN
  
  DELETE FROM owis.Inventory WHERE productID IN(SELECT deleted.productID FROM deleted)
  DELETE FROM owis.WarehouseContents WHERE productID IN(SELECT deleted.productID FROM deleted) 
  DELETE FROM owis.Products where productID IN(SELECT deleted.productID FROM deleted)

 END
GO

CREATE TRIGGER deletePackageIfOrderDeleted  /* When an order is deleted, delete packages of that order */
ON owis.Orders
INSTEAD OF DELETE
AS
 BEGIN
	
	DECLARE @orderID INT

	SELECT @orderID = orderID FROM deleted

	DELETE FROM owis.Packages WHERE orderID = @orderID

	DELETE FROM owis.Orders WHERE orderID = @orderID

	DELETE FROM owis.Payments WHERE orderID = @orderID
 END
GO

CREATE TRIGGER deletePackageIfShipmentDeleted /* When an order is deleted, delete packages of that order */
ON owis.Shipments
INSTEAD OF DELETE
AS
 BEGIN
	
	DECLARE @shipmentID INT

	SELECT @shipmentID = shipmentID FROM deleted

	DELETE FROM owis.Packages WHERE shipmentID = @shipmentID

	DELETE FROM owis.Shipments WHERE shipmentID = @shipmentID

	DELETE FROM owis.Bills WHERE shipmentID = @shipmentID
 END
 GO


/*============================= STORED PROCEDURES =============================*/
CREATE PROCEDURE owis.lowStockItems /* List all items that has stock below 50 */ 
AS
SELECT * 
FROM owis.Products 
WHERE inStock = 1 AND totalQuantity < 50
GO

CREATE PROCEDURE owis.usersWithType /* List all users that has given type */
@userType char(1) = '0' 
AS
IF( @userType != '1')
	SELECT 
	u.firstName,
	u.lastName,
	u.userAge,
	u.userGender,
	u.userName,
	u.phoneNumber 
	FROM owis.Users AS	u
	WHERE u.userType = @userType
ELSE 
	SELECT 
	u.firstName,
	u.lastName,
	us.userAge,
	us.userGender,
	u.userName,
	us.phoneNumber,
	u.title,
	u.warehouseID
	FROM owis.userTypeStaff AS u
	INNER JOIN owis.Users as us
	ON us.email = u.email
GO

CREATE PROCEDURE owis.findWarehouseWithZip /* Find the warehouse with the given ZIP code */
@zipCode char(5)
AS
IF(@zipCode IS NULL)
	BEGIN
	RAISERROR ('You must provide a ZIP code to execute the procedure!',10,1)
	END
ELSE
	SELECT 
	w.warehouseID,
	w.warehouseName,
	w.country,
	w.city,
	w.currentCapacity,
	w.maxCapacity,
	w.warehouseStatus,
	w.email
	FROM owis.Warehouses AS w
	WHERE w.ZIP = @zipCode
GO

CREATE PROCEDURE owis.searchForUser /* Search with a search parameter within users*/
@searchParameter varchar(30) 
AS
IF( @searchParameter IS NULL)
	BEGIN
	RAISERROR ('You must provide a search parameter to execute the procedure!',10,1)
	END
ELSE
	SELECT 
	u.firstName,
	u.lastName,
	u.userAge,
	u.userName,
	u.phoneNumber,
	u.email
	FROM owis.Users AS	u
	WHERE 
	u.userName LIKE '%'+ @searchParameter + '%' OR
	u.firstName LIKE '%'+ @searchParameter + '%' OR
	u.lastName LIKE '%'+ @searchParameter + '%' OR
	u.phoneNumber LIKE '%'+ @searchParameter + '%' OR
	u.email LIKE '%'+ @searchParameter + '%'
GO


CREATE PROCEDURE owis.searchForWarehouse /* Search with a search parameter within warehouse*/
@searchParameter varchar(30) 
AS
IF( @searchParameter IS NULL)
	BEGIN
	RAISERROR ('You must provide a search parameter to execute the procedure!',10,1)
	END
ELSE
	SELECT 
	w.warehouseID,
	w.warehouseName,
	w.country,
	w.city,
	w.warehouseStatus,
	w.warehouseAddress,
	w.email
	FROM owis.Warehouses AS	w
	WHERE 
	w.warehouseName LIKE '%'+ @searchParameter + '%' OR
	w.country LIKE '%'+ @searchParameter + '%' OR
	w.city LIKE '%'+ @searchParameter + '%' OR
	w.email LIKE '%'+ @searchParameter + '%' OR
	w.warehouseAddress LIKE '%'+ @searchParameter + '%' OR
	w.warehouseStatus LIKE '%'+ @searchParameter + '%'
GO 



CREATE PROCEDURE owis.searchForSupplier /* Search with a search parameter within suppliers*/
@searchParameter varchar(30) 
AS
IF( @searchParameter IS NULL)
	BEGIN
	RAISERROR ('You must provide a search parameter to execute the procedure!',10,1)
	END
ELSE
	SELECT 
	s.supplierID,
	s.supplierName,
	s.supplierAddress,
	s.phoneNumber,
	s.email
	FROM owis.Suppliers AS s
	WHERE 
	s.supplierName LIKE '%'+ @searchParameter + '%' OR
	s.supplierAddress LIKE '%'+ @searchParameter + '%' OR
	s.phoneNumber LIKE '%'+ @searchParameter + '%' OR
	s.email LIKE '%'+ @searchParameter + '%' 
GO 

	
CREATE PROCEDURE owis.searchForProduct /* Search with a search parameter within products*/
@searchParameter varchar(30) 
AS
IF( @searchParameter IS NULL)
	BEGIN
	RAISERROR ('You must provide a search parameter to execute the procedure!',10,1)
	END
ELSE
	SELECT 
	p.productID,
	p.productName,
	p.productDescription,
	p.manufacturer,
	p.productWeight,
	p.totalQuantity
	FROM owis.Products AS p
	WHERE 
	p.productName LIKE '%'+ @searchParameter + '%' OR
	p.productDescription LIKE '%'+ @searchParameter + '%' 
GO 


	
CREATE PROCEDURE owis.getDeliveredShipping /* Search with a search parameter within products*/
AS
SELECT 
	s.packageID,
	p.supplierID,
	su.supplierName,
	s.shippingDate,
	s.shippingNote,
	s.deliveryDate,
	p.createdTime
FROM owis.Shipping AS s
INNER JOIN owis.Packages AS p
ON p.packageID = s.packageID
INNER JOIN owis.Suppliers AS su
ON su.supplierID = p.supplierID
WHERE s.currentStatus = 'Delivered' OR s.currentStatus = 'delivered' OR s.currentStatus = 'DELIVERED' 
GO 


CREATE PROCEDURE owis.getPackageFromDate/* Get packages that are created at given time */
@date DATETIME
AS
SELECT * 
FROM owis.Packages AS p 
WHERE p.createdTime >= @date
GO


CREATE PROCEDURE owis.updateProductQuantity  /* Update total quantity of a product */
@productID varchar(30), @totalquantity INT
AS
	DECLARE @quantity INT
	SELECT @quantity = totalQuantity FROM owis.Products WHERE productID = @productID

	UPDATE owis.Products
	SET totalQuantity = @quantity + @totalquantity
	WHERE productID = @productID
	SELECT * FROM owis.Products
GO



CREATE PROCEDURE owis.sumProductQuantityInPackage /* Calculate the sum of all quantity of products in given package */
@packageID INT
AS
	DECLARE @sum_product INT
	SELECT @sum_product = SUM(productQuantity) FROM owis.PackageContents WHERE packageID = @packageID
	RETURN @sum_product
GO

CREATE PROCEDURE owis.getWarehouseInCountry  /* Get warehouses of a given spesific country */
@country varchar(20)
AS
	SELECT 
	w.warehouseID,
	w.warehouseName,
	w.country,
	w.city,
	w.warehouseAddress,
	w.ZIP,
	w.warehouseStatus,
	w.phoneNumber,
	w.email,
	wc.productID,
	wc.quantity
	FROM owis.Warehouses w 
	INNER JOIN owis.WarehouseContents wc ON w.warehouseID = wc.warehouseID
	WHERE w.country = @country
GO


CREATE PROCEDURE owis.getBillFromDate	/* Get bill informations of the given date */
@date DATETIME
AS
	SELECT 
	b.shipmentID,
	b.invoiceID,
	b.paymentType,
	b.amount,
	b.operationDate,
	s.shipmentDate,
	s.shipmentDescription
	FROM owis.Bills b
	INNER JOIN owis.Shipments s ON b.shipmentID = s.shipmentID
	WHERE b.operationDate >= @date

GO

CREATE PROCEDURE owis.getPaymentsFromDate /* Get payment informations of the given date */
@date DATETIME
AS
	SELECT 
	p.orderID,
	p.invoiceID,
	p.paymentType,
	p.amount,
	p.operationDate,
	o.orderDate,
	o.orderDescription
	FROM owis.Payments p
	INNER JOIN owis.Orders o ON p.orderID = o.orderID
	WHERE p.operationDate >= @date

GO

CREATE PROCEDURE owis.getShippingDetailOfPackage /* Get the details of a package that has the given package ID*/
@packageID INT
AS
SELECT 
	s.packageID,
	p.supplierID,
	su.supplierName,
	su.country,
	su.city,
	s.shippingDate,
	s.shippingNote,
	s.deliveryDate,
	p.createdTime
FROM owis.Shipping AS s
INNER JOIN owis.Packages AS p
ON p.packageID = s.packageID
INNER JOIN owis.Suppliers AS su
ON su.supplierID = p.supplierID
WHERE @packageID = p.packageID
GO 


/*============================= INSERTS =============================*/

INSERT INTO owis.Warehouses(warehouseName, country, city, warehouseAddress, ZIP, warehouseStatus,
phoneNumber, email, maxCapacity, currentCapacity)
VALUES('MainWarehouse', 'Türkiye', 'Ýstanbul', 'Okmeydaný', '45413', 'Stable',
'542-124-4565', 'warehousemain@gmail.com', 1000, 0)

INSERT INTO owis.Warehouses(warehouseName, country, city, warehouseAddress, ZIP, warehouseStatus,
phoneNumber, email, maxCapacity, currentCapacity)
VALUES('AnkaraWarehouse', 'Türkiye', 'Ankara', 'Cebeci', '42121', 'Stable',
'533-452-4523', 'ankarawarehouse@gmail.com', 800, 0)

INSERT INTO owis.Warehouses(warehouseName, country, city, warehouseAddress, ZIP, warehouseStatus,
phoneNumber, email, maxCapacity, currentCapacity)
VALUES('BursaWarehouse', 'Türkiye', 'Bursa', 'Osmangazi', '42456', 'Stable',
'555-654-1245', 'warehousebursa@gmail.com', 600, 0)

INSERT INTO owis.Warehouses(warehouseName, country, city, warehouseAddress, ZIP, warehouseStatus,
phoneNumber, email, maxCapacity, currentCapacity)
VALUES('AntalyaWarehouse', 'Türkiye', 'Antalya', 'Aksu', '12354', 'Stable',
'536-658-1230', 'warehouseantalya@gmail.com', 700, 0)

INSERT INTO owis.Warehouses(warehouseName, country, city, warehouseAddress, ZIP, warehouseStatus,
phoneNumber, email, maxCapacity, currentCapacity)
VALUES('KonyaWarehouse', 'Türkiye', 'Konya', 'Beyþehir', '48654', 'Stable',
'548-256-3654', 'konyawarehouse@gmail.com', 400, 0)


INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Elma', 'Torku Bayraktar', 0.2, 1, 200)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Armut', 'Aytaþ Tarým', 0.4, 1, 100)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Ananas', 'Kutlu Gýda', 0.9, 1, 50)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Portakal', 'Doruk Sebze', 0.6, 1, 180)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Ayva', 'Akkurt', 0.7, 0, 0)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Pirinç', 'Sambak', 0.2, 1, 250)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Bulgur', 'Nefis', 0.3, 1, 150)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Nohut', 'Sönmezler', 0.1, 1, 190)

INSERT INTO owis.Products(productName, manufacturer, productWeight, inStock, totalQuantity)
VALUES('Bor', 'Fabric', 5, 1, 280)


INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(1, 1, 200)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(2, 2, 50)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(1, 2, 50)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(3, 4, 80)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(4, 4, 100)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(4, 7, 100)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(4, 6, 100)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(2, 6, 150)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(2, 7, 50)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(2, 3, 50)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(3, 8, 190)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(3, 9, 130)

INSERT INTO owis.WarehouseContents(warehouseID, productID, quantity)
VALUES(5, 9, 150)


INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Admin', 'admin', 'Can', 'Yýlmaz', 35, 2, '545-256-9698', 'admin@gmail.com','Male')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Orhangb', 'barut455', 'Orhan', 'Barut', 30, 1, '537-856-5665', 'orhanbarut@gmail.com','Male')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Kemalklc', 'kilic4512', 'Kemal', 'Kýlýç', 25, 1, '547-455-1245', 'kemalkilic@gmail.com','Male')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Mehmettyld', 'mehmet1yildirim', 'Mehmet', 'Yýldýrým', 42, 1, '555-452-3635', 'mehmetyildirim@gmail.com','Male')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Yagmurbc12', 'yagmur454123', 'Yaðmur', 'Bir', 30, 1, '533-456-1254', 'yagmur@gmail.com','Female')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Nedime45', 'bakan142', 'Nedime', 'Gökebakan', 40, 1, '542-654-3652', 'nedimebakan@gmail.com','Female')

INSERT INTO owis.Users(userName, userPassword, firstName, lastName, userAge, 
userType, phoneNumber, email,userGender)
VALUES('Aleynakar12', 'kars1245', 'Aleyna', 'Kars', 32, 0, '542-145-9685', 'aleynakars@gmail.com','Female')


/*When add an user with user type 1, default value of staff warehouse ID is 1, and then we can change this column */
UPDATE owis.Staff SET warehouseID=1 WHERE staffID=1

UPDATE owis.Staff SET warehouseID=2 WHERE staffID=2

UPDATE owis.Staff SET warehouseID=3 WHERE staffID=3

UPDATE owis.Staff SET warehouseID=4 WHERE staffID=4

UPDATE owis.Staff SET warehouseID=5 WHERE staffID=5


INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(1,1, '2020-07-01')

INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(2,2, '2020-08-10')

INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(1,2, '2020-10-12')

INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(2,4, '2020-07-06')

INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(2,4, '2020-12-10')

INSERT INTO owis.Orders(staffID, warehouseID, orderDate)
VALUES(2,5, '2020-11-05')


INSERT INTO owis.Shipments(staffID, warehouseID, shipmentDate)
VALUES(3,1, '2020-11-07')

INSERT INTO owis.Shipments(staffID, warehouseID, shipmentDate)
VALUES(4,2, '2020-10-08')

INSERT INTO owis.Shipments(staffID, warehouseID, shipmentDate)
VALUES(3,2, '2020-12-10')

INSERT INTO owis.Shipments(staffID, warehouseID, shipmentDate)
VALUES(4,4, '2020-06-07')

INSERT INTO owis.Shipments(staffID, warehouseID, shipmentDate)
VALUES(5,4, '2020-12-10')


INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(1, '4561327845', 'Credit Card', 150, '2020-07-11')

INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(2, '9845654518', 'Cash', 400, '2020-08-10')

INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(3, '4256968545', 'Credit Card', 300, '2020-10-12')

INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(4, '2132566396', 'Credit Card', 200, '2020-07-06')

INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(5, '1245785698', 'Cash', 50, '2020-12-10')

INSERT INTO owis.Payments(orderID, invoiceID, paymentType, amount, operationDate)
VALUES(6, '5134351213', 'Cash', 150, '2020-11-05')


INSERT INTO owis.Bills(shipmentID, invoiceID, paymentType, amount, operationDate)
VALUES(1, '1658596587', 'Credit Card', 300, '2020-11-07')

INSERT INTO owis.Bills(shipmentID, invoiceID, paymentType, amount, operationDate)
VALUES(2, '4265986542', 'Cash', 200, '2020-10-08')

INSERT INTO owis.Bills(shipmentID, invoiceID, paymentType, amount, operationDate)
VALUES(3, '4512315132', 'Credit Card', 150, '2020-12-10')

INSERT INTO owis.Bills(shipmentID, invoiceID, paymentType, amount, operationDate)
VALUES(4, '4213543122', 'Cash', 50, '2020-06-07')

INSERT INTO owis.Bills(shipmentID, invoiceID, paymentType, amount, operationDate)
VALUES(5, '1234354541', 'Cash', 200, '2020-12-10')


INSERT INTO owis.Suppliers(supplierName, country, city, supplierAddress, phoneNumber, email)
VALUES('OWIS', 'Türkiye', 'Ýstanbul', 'Okmeydaný', '542-124-4565', 'owis@gmail.com')

INSERT INTO owis.Suppliers(supplierName, country, city, supplierAddress, phoneNumber, email)
VALUES('NKCOL', 'Türkiye', 'Ankara', 'Cebeci', '555-654-1265', 'nkcol@gmail.com')

INSERT INTO owis.Suppliers(supplierName, country, city, supplierAddress, phoneNumber, email)
VALUES('Aksu Tarým', 'Türkiye', 'Antalya', 'Aksu', '542-125-3656', 'aksutarim@gmail.com')

INSERT INTO owis.Suppliers(supplierName, country, city, supplierAddress, phoneNumber, email)
VALUES('Doðuþ', 'Türkiye', 'Ankara', 'Cebeci', '536-896-6356', 'dogus@gmail.com')

INSERT INTO owis.Suppliers(supplierName, country, city, supplierAddress, phoneNumber, email)
VALUES('Can Tarým', 'Türkiye', 'Ýstanbul', 'Bahçelievler', '542-256-9685', 'cantarim@gmail.com')


INSERT INTO owis.Packages(isProvided, orderID, supplierID, createdTime,packageStatus)
VALUES(0, 1, 2, '2020-07-02','On Shipping')

INSERT INTO owis.Packages(isProvided, orderID, supplierID, createdTime)
VALUES(0, 2, 2, '2020-11-08')

INSERT INTO owis.Packages(isProvided, shipmentID, supplierID, createdTime)
VALUES(1, 1, 1, '2020-11-07')

INSERT INTO owis.Packages(isProvided, shipmentID, supplierID, createdTime)
VALUES(1, 1, 3, '2020-11-08')

INSERT INTO owis.Packages(isProvided, orderID, supplierID, createdTime,packageStatus)
VALUES(0, 3, 5, '2020-10-13','On Shipping')

INSERT INTO owis.Packages(isProvided, orderID, supplierID, createdTime)
VALUES(0, 6, 4, '2020-11-06')

INSERT INTO owis.Packages(isProvided, shipmentID, supplierID, createdTime)
VALUES(1, 4, 4, '2020-06-07')

INSERT INTO owis.Packages(isProvided, shipmentID, supplierID, createdTime)
VALUES(1, 5, 4, '2020-12-10')


INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(1, 1, 100)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(2, 1, 200)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(3, 2, 30)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(5, 3, 40)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(3, 6, 50)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(5, 7, 60)

INSERT INTO owis.PackageContents(packageID, productID, productQuantity)
VALUES(6, 9, 160)


INSERT INTO owis.Shipping(packageID, shippingDate, deliveryDate, currentLocation, currentStatus)
VALUES(1, '2020-11-10', '2020-11-15', 'Adana','Delivered')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(2, '2020-11-10', '2020-11-15', 'Bolu')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(3, '2020-06-10', '2020-06-12', 'Antalya')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(4, '2020-12-15', '2020-12-18', 'Ankara')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation,currentStatus)
VALUES(5, '2020-11-10', '2020-11-15', 'Hatay','Delivered')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(6, '2020-11-10', '2020-11-15', 'Þanlýurfa')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(7, '2020-06-10', '2020-06-12', 'Niðde')

INSERT INTO owis.Shipping(packageID, shippingDate, estimatedDeliveryDate, currentLocation)
VALUES(8, '2020-12-15', '2020-12-18', 'Kars')

GO