------------------------------------------------------------------------------------------------------------
------------------------Step-1 Create Database -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

--Scripts to create database Ecommerce2019

CREATE DATABASE Ecommerce2019;

USE Ecommerce2019;

-- Create Roles Table. 
-- This table will contain roles like  employee, customer, supplier.
-- Roles can be marked as ACTIVE Or INACIVE

CREATE TABLE Roles(
RoleID int NOT NULL PRIMARY KEY,
RoleName varchar (255) NOT NULL,
RoleStatus varchar (10)
);

CREATE TABLE Cities(
CityID int NOT NULL PRIMARY KEY,
CityName varchar (255)
);

CREATE TABLE States(
StateID int NOT NULL PRIMARY KEY,
StateName varchar(255)
);

CREATE TABLE Countries(
CountryID int NOT NULL PRIMARY KEY,
CountryName varchar (255)
);

CREATE TABLE Users(
UserID int NOT NULL Primary Key,
UserFirstName varchar (255),
UserMidName varchar (255),
UserLastName varchar (255),
UserEmail varchar (255),
UserPhoneNumber varchar (255),
UserStatus varchar (10),
LogInID varchar (50),
Password varchar (50),
RoleID int FOREIGN KEY REFERENCES Roles(RoleID)
);

-- Address Type will have reference values like - Shipping, Billing
CREATE TABLE AddressType(
AddressTypeID int NOT NULL PRIMARY KEY,
AddressTypeName varchar(25)
);

-- Address Table will hold the addresses of all the Users
CREATE TABLE Address(
AddressID int NOT NULL PRIMARY KEY,
AddressLine1 varchar(255),
AddressLine2 varchar(255),
CityID int FOREIGN KEY REFERENCES Cities(CityID),
StateID int FOREIGN KEY REFERENCES States(StateID),
CountryID int FOREIGN KEY REFERENCES Countries(CountryID),
AddressTypeID int FOREIGN KEY REFERENCES AddressType(AddressTypeID),
UserID int FOREIGN KEY REFERENCES Users(UserID)
);

---- Create Product Category Table
CREATE TABLE ProductCategory(
ProductCategoryID int  NOT NULL PRIMARY KEY,
CategoryName varchar(255), 
CategoryDesc varchar(255),
CategoryThumb varchar(MAX),
CategoryImage varchar(MAX),
CategoryActive varchar(10)
);
----- Product SubCategory Table
CREATE TABLE ProductSubCategory(
ProductSubCategoryID  int  NOT NULL PRIMARY KEY,
SubCategoryName varchar(255),
SubCategoryDesc varchar(255),
SubCategoryThumb varchar(MAX),
SubCategoryImage varchar(MAX),
SubCategoryActive varchar(10),
ProductCategoryID int FOREIGN KEY REFERENCES ProductCategory(ProductCategoryID)
);

---- Product Brand Table
CREATE TABLE ProductBrand(
ProductBrandID int NOT NULL PRIMARY KEY,
BrandName varchar(255),
BrandDesc varchar(255),
BrandThumb varchar(MAX),
BrandImage varchar(MAX),
BrandActive varchar(10) 
);

---- Create Product Table
CREATE TABLE Product(
ProductID int NOT NULL PRIMARY KEY,
ProductSKU int,
ProductName varchar(255),
ProductPurchasePrice money,
ProductSellingPrice money,
ProductShortDesc varchar(255),
ProductLongDesc varchar(1000),
ProductThumb varchar(MAX),
ProductImage varchar(MAX),
ProductCategoryID int FOREIGN KEY REFERENCES ProductCategory (ProductCategoryID),
ProductSubCategoryID int FOREIGN KEY REFERENCES ProductSubCategory (ProductSubCategoryID),
ProductBrandID int FOREIGN KEY REFERENCES ProductBrand (ProductBrandID),
ProductActive varchar(10),
ProductQuantity int
);

----Product Attribute Groups Table
CREATE TABLE ProductAttributeGroups(
AttributeGroupID int NOT NULL PRIMARY KEY,
AttributeGroupName VARCHAR(255)
);

---- ProductAttributes Table
CREATE TABLE ProductAttributes(
AttributeID int NOT NULL PRIMARY KEY,
AttributeName varchar(255),
AttributeGroupID int FOREIGN KEY REFERENCES ProductAttributeGroups(AttributeGroupID)
);

----Table to Manage Many to Many Relationship between Attribute Groups and Products
CREATE TABLE ProductAttributeMap(
ProductID INT NOT NULL,
AttributeGroupID INT NOT NULL,
Constraint FK_ProductID FOREIGN KEY(ProductID) REFERENCES Product(ProductID),
Constraint FK_AttributeGroupID FOREIGN KEY(AttributeGroupID) REFERENCES ProductAttributeGroups(AttributeGroupID),
Constraint PK_ProductAttributeMap PRIMARY KEY(ProductID, AttributeGroupID)
);

---- ShipmentOptions Table
CREATE TABLE ShipmentOptions(
ShipmentOptionID INT NOT NULL PRIMARY KEY,
ShipmentOptionName VARCHAR (255),
ShipmentOptionDetails VARCHAR (255)
);

----PaymentOptions Table
CREATE TABLE PaymentOptions(
PaymentOptionID INT NOT NULL PRIMARY KEY,
PaymentOptionName VARCHAR (255),
PaymentOptionDesc VARCHAR (255)
);

----DiscountCode Table -- Added New COlumn DiscountPercentage
CREATE TABLE DiscountCode(
DiscountCodeID INT  NOT NULL PRIMARY KEY,
DiscountCodeName VARCHAR (255),
DiscountCodeDetails VARCHAR (255),
DiscountPercentage decimal(9,2)
);

---- Relatioship in ERD should be changed of StateID which is incorrectly mared as PK
CREATE TABLE StateTaxRates(
TaxRateID INT  NOT NULL PRIMARY KEY,
StateID INT NOT NULL FOREIGN KEY REFERENCES States(StateID),
TaxRate decimal(9,2)
);

---- Create Orders Table
CREATE TABLE Orders(
OrderID INT PRIMARY KEY NOT NULL,
UserID INT FOREIGN KEY REFERENCES Users(UserID) NOT NULL,
DiscountCodeID INT FOREIGN KEY REFERENCES DiscountCode(DiscountCodeID) NULL ,
ShipmentOptionID INT FOREIGN KEY REFERENCES ShipmentOptions(ShipmentOptionID) NOT NULL,
PaymentOptionID INT FOREIGN KEY REFERENCES PaymentOptions(PaymentOptionID) NOT NULL,
TaxRateID INT FOREIGN KEY REFERENCES StateTaxRates(TaxRateID) NOT NULL,
OrderDate DATETIME,
OrderDeliverDate DATETIME,
OrderAmount money,
OrderStatus varchar(100)
);

CREATE TABLE OrderItems(
OrderID INT NOT NULL,
ProductID INT NOT NULL,
Constraint FK_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
Constraint FK_OI_ProductID FOREIGN KEY(ProductID) REFERENCES Product(ProductID),
Constraint PK_OrderItems PRIMARY KEY(OrderID, ProductID),
Quantity INT,
UnitPrice money,
TotalPriceBeforeTax money
);

---- Changed the Primry Key to single CArtID, removed USERID as Composite PK
CREATE TABLE Cart(
CartID INT NOT NULL PRIMARY KEY,
UserID INT NOT NULL,
Constraint FK_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID)
);

CREATE TABLE CartItems(
CartID INT NOT NULL,
ProductID INT NOT NULL,
Constraint FK_CartID FOREIGN KEY(CartID) REFERENCES Cart(CartID),
Constraint FK_CI_ProductID FOREIGN KEY(ProductID) REFERENCES Product(ProductID),
Constraint PK_CartItems PRIMARY KEY(CartID, ProductID)
);

CREATE TABLE ProductRating(
ProductID INT NOT NULL,
UserID INT NOT NULL,
Constraint FK_PR_ProductID FOREIGN KEY(ProductID) REFERENCES Product(ProductID),
Constraint FK_PR_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID),
Constraint PK_ProductRating PRIMARY KEY(ProductID, UserID),
Ratings INT,
Review VARCHAR (100)
);

------------------------------------------------------------------------------------------------------------
------------------------Step-2 Create Functions ------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

USE Ecommerce2019;;
--- Computed Columns based on a function 
--- Function to Calculate the Total Order Amount

CREATE FUNCTION fn_CalculateOrderAmount(@OrderID int)
RETURNS money 
AS
BEGIN
	DECLARE @Return money;
	SELECT @Return =  SUM(TotalPriceBeforeTax)
		FROM OrderItems
		WHERE OrderID=@OrderID;

		return @Return;
END;

	/*
	----------------------------------------TEST SQL to validate after inserting the data -------
	  UPDATE dbo.Orders 
	  SET OrderAmount = dbo.fn_CalculateOrderAmount(10)
	  WHERE OrderID =10;

	  SELECT * FROM Orders;
	 ----------------------------------------TEST SQL QUERIES---END------------------------------
	 */

  ----Table-level CHECK Constraints based on a function
  ----- Function to check the Total Order Amount
  ------If the Total Order Amount is Greater than 5000, The Order creation will fail

  CREATE FUNCTION fn_CheckOrderAmount(@OrderAmount money)
  RETURNS smallint
  AS
  BEGIN
     DECLARE @OrderAllowed smallint=0;
	  if(@OrderAmount > 5000)
		  BEGIN
			SET @OrderAllowed =0;
		  END
	   else 
		   BEGIN
			 SET @OrderAllowed =1;
		   END

	  return @OrderAllowed;
	END;	   
	
	------ add constraint on Orders table, to check and reject the order above $5000 
	ALTER TABLE Orders ADD CONSTRAINT OrderExceedsMaxPrice CHECK (dbo.fn_CheckOrderAmount(OrderAmount)=1);
	
	SELECT * FROM Orders;

	/*
	-----------------------------------------------TEST SQL, to verifyconstraintafter loading data --------
		INSERT INTO Orders VALUES (11, 2,1,1,1,1,'07-28-2019','07-28-2019',6000,'Ordered');
	-----------------------------------------------TEST SQL QUERY ENDS------------------------
	*/
------------------------------------------------------------------------------------------------------------
------------------------Step-3 Create Views ----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
---- View 1, to check the Active Customers and the Order Amount they placed

CREATE VIEW ActiveCustomers AS
SELECT u.UserFirstName, u.UserLastName,o.OrderAmount
FROM Users u
INNER JOIN Orders o
ON u.UserID = o.UserID;

SELECT * FROM ActiveCustomers;

----View 2, to Check the Products on Demand
CREATE VIEW ProductsOnDemand AS
SELECT p.ProductName,pb.BrandName,pc.CategoryName,psc.SubCategoryName, oi.TotalPriceBeforeTax
FROM Product p
INNER JOIN OrderItems oi
ON p.ProductID= oi.ProductID
INNER JOIN ProductBrand pb
ON p.ProductBrandID = pb.ProductBrandID
INNER JOIN ProductCategory pc
ON p.ProductCategoryID = pc.ProductCategoryID
INNER JOIN ProductSubCategory psc
ON p.ProductCategoryID = psc.ProductSubCategoryID
;

SELECT * FROM ProductsOnDemand;

-----------------------------------------------------------------------------------------------------
------------------------------ Step 4: Populate Database --------------------------------------------
------------------------------------------------------------------------------------------------------
-- Insert statements to populate the database 

USE Ecommerce2019;

INSERT INTO Cities
VALUES
 (1, 'Melrose'),
 (2, 'Belmont'),
 (3, 'Brookline'),
 (4, 'Newton'),
 (5, 'Northborough'),
 (6, 'Norwood'),
 (7, 'Arlington'),
 (8, 'Winchester'),
 (9, 'Westborough'),
 (10, 'Wellesley'),
 (11, 'Needham'),
 (12, 'Dedham');



INSERT INTO States
VALUES
(1, 'Alabama'), 
(2, 'Alaska'),
(3, 'Arizona'), 
(4, 'Arkansas'), 
(5, 'California'),  
(6, 'Colorado'), 
(7, 'Connecticut'),  
(8, 'Delaware'), 
(9, 'Florida'), 
(10,'Georgia'), 
(11, 'Idaho'), 
(12, 'Hawaii'), 
(13, 'Illinois'), 
(14,'Indiana'), 
(15, 'Iowa'), 
(16, 'Kansas'), 
(17, 'Kentucky'),  
(18, 'Louisiana'), 
(19, 'Maine'), 
(20, 'Maryland'), 
(21, 'Massachusetts'), 
(22, 'Michigan'), 
(23, 'Minnesota'), 
(24, 'Mississippi'), 
(25, 'Missouri '), 
(26, 'Montana'), 
(27, 'Nebraska'), 
(28, 'Nevada'), 
(29, 'New Hampshire'), 
(30, 'New Jersey'), 
(31, 'New Mexico'), 
(32, 'New York'), 
(33, 'North Carolina '), 
(34, 'North Dakota '), 
(35, 'Ohio'), 
(36, 'Oklahoma '), 
(37, 'Oregon '), 
(38, 'Pennsylvania'), 
(39, 'Rhode Island'), 
(40, 'South Carolina'), 
(41, 'South Dakota'),  
(42, 'Tennessee'),  
(43, 'Texas'), 
(44, 'Utah'), 
(45, 'Vermont'), 
(46, 'Virginia'),  
(47, 'Washington'),  
(48, 'West Virginia'), 
(49, 'Wisconsin'), 
(50, 'Wyoming');

INSERT INTO Countries
VALUES
(1, 'United Kingdom'),
(2,'United States'), 
(3,'Australia'),
(4,'China'),
(5,'India'),
(6,'Japan');

INSERT INTO AddressType
VALUES
(1, 'Billing'),
(2,'Shipping');

INSERT INTO Roles
VALUES
(1,'Customer', 'Active'),
(2,'Supplier','Active'),
(3,'Admin', 'Active');

 
INSERT INTO Users
VALUES
( 1,'fn_User-1','mn-User-1', 'ln_User-1','user1@gmail.com','123456789','Active','User-1','Password',1),
( 2,'fn_User-2','mn-User-2', 'ln_User-2','user2@gmail.com','212121212','Active','User-2','Password',1),
( 3,'fn_User-3','mn-User-3', 'ln_User-3','user3@gmail.com','565656565','Active','User-3','Password',1),
( 4,'fn_User-4','mn-User-4', 'ln_User-4','user4@gmail.com','549872618','Active','User-4','Password',1),
( 5,'fn_User-5','mn-User-5', 'ln_User-5','user5@gmail.com','182187218','Inactive','User-5','Password',1),
( 6,'fn_User-6','mn-User-6', 'ln_User-6','user6@gmail.com','498716542','Active','User-6','Password',1),
( 7,'fn_User-7','mn-User-7', 'ln_User-7','user7@gmail.com','198721864','Active','User-7','Password',1),
( 8,'fn_User-8','mn-User-8', 'ln_User-8','user8@gmail.com','789218462','Active','User-8','Password',1),
( 9,'fn_User-9','mn-User-9', 'ln_User-9','user9@gmail.com','198721862','Active','User-9','Password',1),
( 10,'fn_User-10','mn-User-10', 'ln_User-10','user10@gmail.com','872198721','Active','User-10','Password',1),
( 11,'fn_User-11','mn-User-11', 'ln_User-11','user11@gmail.com','954987562','Active','User-11','Password',1),
( 12,'fn_User-12','mn-User-12', 'ln_User-12','user12@gmail.com','872164521','Active','User-12','Password',1),
( 13,'fn_User-13','mn-User-13', 'ln_User-13','user13@gmail.com','875454624','Active','User-13','Password',1),
( 14,'fn_User-14','mn-User-14', 'ln_User-14','user14@gmail.com','624872467','Active','User-14','Password',1),
( 15,'fn_User-15','mn-User-15', 'ln_User-15','user15@gmail.com','315468756','Active','User-15','Password',1),
( 16,'fn_User-16','mn-User-16', 'ln_User-16','user16@gmail.com','875487245','Active','User-16','Password',1),
( 17,'fn_User-17','mn-User-17', 'ln_User-17','user17@gmail.com','216468421','Inactive','User-17','Password',1),
( 18,'fn_User-18','mn-User-18', 'ln_User-18','user18@gmail.com','216872158','Active','User-18','Password',1),
( 19,'fn_User-19','mn-User-19', 'ln_User-19','user19@gmail.com','216871284','Active','User-19','Password',1),
( 20,'fn_User-20','mn-User-20', 'ln_User-20','user20@gmail.com','549821568','Active','User-20','Password',1)
;

INSERT INTO Address
VALUES
(1,'131 Washington Street', 'Apt-51',4,21,2,1,1),
(2,'131 Washington Street', 'Apt-51',4,21,2,2,1),
(3,'2344 Commonwealth Avenue', 'Apt-3-2',4,21,2,1,2),
(4,'2344 Commonwealth Avenue', 'Apt-3-2',4,21,2,2,2),
(5,'34 Brookline Street', 'Apt-8-C',7,21,2,1,3),
(6,'34 Brookline Street', 'Apt-8-C',7,21,2,2,3),
(7,'18 Jersey Street', 'Apt-A',1,15,2,1,4),
(8,'18 Jersey Street', 'Apt-A',1,15,2,2,4),
(9,'1670 Lincoln Avenue', 'Apt-19',2,1,2,1,5),
(10,'1670 Lincoln Avenue', 'Apt-19',2,1,2,2,5),
(11,'53 Beach Street ', 'Apt-72',5,19,2,1,6),
(12,'53 Beach Street ', 'Apt-72',5,19,2,2,6),
(13,'21 Park Drive', 'Apt-41',3,37,2,1,7),
(14,'21 Park Drive', 'Apt-41',3,37,2,2,7),
(15,'1344 Commonwealth Avenue', 'Apt-32',10,41,2,1,8),
(16,'1344 Commonwealth Avenue', 'Apt-32',10,41,2,2,8),
(17,'144 State Avenue', 'Apt-2',3,23,2,1,9),
(18,'144 State Avenue', 'Apt-2',3,23,2,2,9),
(19,'134 Vershire Avenue',NULL,8,1,2,1,10),
(20,'134 Vershire Avenue',NULL,8,1,2,2,10),
(21,'2104 Clovely Street', NULL,12,5,2,1,11),
(22,'2104 Clovely Street', NULL,12,5,2,2,11),
(23,'130 Main st', 'Apt-2',5,46,2,1,12),
(24,'130 Main st', 'Apt-2',5,46,2,2,12),
(25,'65 Quincy Avenue', 'Apt-64',7,31,2,1,13),
(26,'65 Quincy Avenue', 'Apt-64',7,31,2,2,13),
(27,'201 Broadway Street', 'Apt-12',3,25,2,1,14),
(28,'201 Broadway Street', 'Apt-12',3,25,2,2,14),
(29,'314 Wiley Lewis Road', null,9,30,2,1,15),
(30,'314 Wiley Lewis Road', null,9,30,2,2,15),
(31,'40 North Tryon Street', 'Apt-28',6,41,2,1,16),
(32,'40 North Tryon Street', 'Apt-28',6,41,2,2,16),
(33,'13 Old Concord Road', 'Apt- 104',3,12,2,1,17),
(34,'13 Old Concord Road', 'Apt- 104',3,12,2,2,17),
(35,'2112 Clovely Street', null,1,19,2,1,18),
(36,'2112 Clovely Street', null,1,19,2,2,18),
(37,'58 FDR Drive', 'Apt-32',2,15,2,1,19),
(38,'58 FDR Drive', 'Apt-32',2,15,2,2,19),
(39,'44 Campus Walk Road', 'Apt-79',10,37,2,1,20),
(40,'44 Campus Walk Road', 'Apt-79',10,37,2,2,20);

  

INSERT INTO  ProductAttributeGroups
VALUES(1,'Size'),
(2,'Color');

INSERT INTO ProductAttributes
VALUES
(1,'XS',1),
(2,'S',1),
(3,'M',1),
(4,'L',1),
(5,'XL',1),
(6,'XXL',1),
(7,'Red',2),
(8,'Black',2),
(9,'Blue',2),
(10,'White',2);

INSERT INTO ProductBrand
VALUES(1,'Apple','Product by Apple','https://www.apple.com/today/','https://www.apple.com/today/','Active'),
(2,'Samsung','Product by Samsung','https://www.samsung.com/us/','https://www.samsung.com/us/','Active');

INSERT INTO ProductCategory
VALUES(1,'Electronics','Electronics Items','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active'),
(2,'TVs & Appliances','TVs & Appliances Items','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active'),
(3,'Sports and Outdoors','Sports, Fitness and Outdoors','https://www.walmart.com/cp/sports-and-outdoors/4125','https://www.walmart.com/cp/sports-and-outdoors/4125','Active'),
(4,'Clothing','Clothing, Shoes and Acceossories','https://www.walmart.com/cp/clothing/5438','https://www.walmart.com/cp/clothing/5438','Active');

INSERT INTO ProductSubCategory
VALUES
(1,'Tablets','Electronics Tablets','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',1),
(2,'Laptops','Electronics Laptops','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',1),
(3,'Smart Phone','Electronics Smart Phones','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',1),
(4,'Smart TVs','Electronics Televisions','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',2),
(5,'Women','Women - New Arrivals','https://www.walmart.com/cp/clothing/5438','https://www.walmart.com/cp/clothing/5438','Active',4),
(6,'Men','Men - New Arrivals','https://www.walmart.com/cp/clothing/5438','https://www.walmart.com/cp/clothing/5438','Active',4),
(7,'Kids','Kids - New Arrivals','https://www.walmart.com/cp/clothing/5438','https://www.walmart.com/cp/clothing/5438','Active',4),
(8,'Beauty','Beauty - New Arrivals','https://www.walmart.com/cp/clothing/5438','https://www.walmart.com/cp/clothing/5438','Active',4),
(9,'Bikes','Miles Of Smiles','https://www.walmart.com/cp/sports-and-outdoors/4125','https://www.walmart.com/cp/sports-and-outdoors/4125','Active',3),
(10,'Camping','At Home in the OUtdoors','https://www.walmart.com/cp/sports-and-outdoors/4125','https://www.walmart.com/cp/sports-and-outdoors/4125','Active',3),
(11,'Sports','Gears for all the sports','https://www.walmart.com/cp/sports-and-outdoors/4125','https://www.walmart.com/cp/sports-and-outdoors/4125','Active',3),
(12,'Fan Shop','Shop for the Fanatics','https://www.walmart.com/cp/sports-and-outdoors/4125','https://www.walmart.com/cp/sports-and-outdoors/4125','Active',3),
(13,'Cameras','Click the perfect photos','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',1),
(14,'DVD Players','TVs & Appliances Items','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',2),
(15,'TV Mounts','TVs & Appliances Items','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',2),
(16,'Home Audio and Theatre','TVs & Appliances Items','https://www.walmart.com/cp/electronics/3944','https://www.walmart.com/cp/electronics/3944','Active',2);


INSERT INTO Product
VALUES 
(1,
1111,
'Samsung Galaxy J6(Black 64 GB)',150, 180,
'Samsung Galaxy J6(Black 64 GB) Short Description',
'The Samsung Galaxy J6 is here, with its virtually continuous Bezel-free Screen, to make work and entertainment seem even more appealing. And, while you revel in your favorite show, you can simultaneously chat with your loved ones without having to switch screens and disturb your viewing experience.',
'https://www.flipkart.com/samsung-galaxy-j6-black-64-gb/p/itmf5bkh5snxdanh?pid=MOBF5BKHAK33A75F&srno=b_1_1&otracker=CLP_Filters&lid=LSTMOBF5BKHAK33A75FF5GAS6&fm=organic&iid=331deb7e-b8dc-4e0d-befa-29ae85ccba82.MOBF5BKHAK33A75F.SEARCH&ppt=sp&ppn=sp&ssid=5eodxtabs00000001564338399745',
'https://www.flipkart.com/samsung-galaxy-j6-black-64-gb/p/itmf5bkh5snxdanh?pid=MOBF5BKHAK33A75F&srno=b_1_1&otracker=CLP_Filters&lid=LSTMOBF5BKHAK33A75FF5GAS6&fm=organic&iid=331deb7e-b8dc-4e0d-befa-29ae85ccba82.MOBF5BKHAK33A75F.SEARCH&ppt=sp&ppn=sp&ssid=5eodxtabs00000001564338399745',
1,
3,
2,
'ACTIVE',
100
),
(2,
2222,
'Samsung Galaxy S10 Plus (Ceramic White, 1 TB)  (12 GB RAM))',1000, 1200,
'Samsung Galaxy S10 Plus (Ceramic White, 1 TB)  (12 GB RAM)) Short Description',
'Get ready to explore the next generation of powerful computing and mobile photography with the Samsung Galaxy S10 Plus. It comes with an Intelligent Camera that automatically optimizes its settings to give you picture-perfect photos. Thats not all, the Samsung S10 Plus has the Infinity-O Display and a seamless design that make this smartphone a true masterpiece.',
'https://www.flipkart.com/samsung-galaxy-s10-plus-ceramic-white-1-tb/p/itmfdyp6yc3fu2fg?pid=MOBFDNMZC29CBUPF&srno=b_1_1&otracker=CLP_Filters&lid=LSTMOBFDNMZC29CBUPFET8ALO&fm=organic&iid=85069697-afe2-4288-aa06-8fb5309ded6b.MOBFDNMZC29CBUPF.SEARCH&ppt=sp&ppn=sp',
'https://www.flipkart.com/samsung-galaxy-s10-plus-ceramic-white-1-tb/p/itmfdyp6yc3fu2fg?pid=MOBFDNMZC29CBUPF&srno=b_1_1&otracker=CLP_Filters&lid=LSTMOBFDNMZC29CBUPFET8ALO&fm=organic&iid=85069697-afe2-4288-aa06-8fb5309ded6b.MOBFDNMZC29CBUPF.SEARCH&ppt=sp&ppn=sp',
1,
3,
2,
'ACTIVE',
100),
(3,
2323,
'Samsung 165.1cm (65 inch) Ultra HD (4K) LED Smart TV',1100, 1400,
'Samsung 165.1cm (65 inch) Ultra HD (4K) LED Smart TV Short Description',
'Bring home this Samsung TV and enjoy your content in 4K UHD resolution. The PurColour feature of this TV delivers natural colours with rich details. You can use the SmartThings app to set up your smart TV from your smartphone.',
'https://www.flipkart.com/samsung-165-1cm-65-inch-ultra-hd-4k-led-smart-tv/p/itmfggqbzsqkzczz?pid=TVSFGGQBXHWDG76H&srno=b_1_2&otracker=browse&lid=LSTTVSFGGQBXHWDG76HGIBFVX&fm=organic&iid=a65eb55e-199d-4fae-aa82-7a81d6c6b68f.TVSFGGQBXHWDG76H.SEARCH&ppt=browse&ppn=browse&ssid=028b8fr3cg0000001564355880631',
'https://www.flipkart.com/samsung-165-1cm-65-inch-ultra-hd-4k-led-smart-tv/p/itmfggqbzsqkzczz?pid=TVSFGGQBXHWDG76H&srno=b_1_2&otracker=browse&lid=LSTTVSFGGQBXHWDG76HGIBFVX&fm=organic&iid=a65eb55e-199d-4fae-aa82-7a81d6c6b68f.TVSFGGQBXHWDG76H.SEARCH&ppt=browse&ppn=browse&ssid=028b8fr3cg0000001564355880631',
2,
4,
2,
'ACTIVE',
50),
(4,
2333,
'Samsung Super 6 NU6100 108cm (43 inch) Ultra HD (4K) LED Smart TV',650, 900,
'Samsung Super 6 NU6100 108cm (43 inch) Ultra HD (4K) LED Smart TV Short Description',
'Indulge in the brilliance of real 4K (3840 x 2160) resolution by bringing home this TV from Samsung. Not only does this TV let you mirror the contents of your smartphone, such as images and videos, on its screen, but it also lets you enjoy some lag-free gaming in case you get bored of watching videos/movies.',
'https://www.flipkart.com/samsung-super-6-nu6100-108cm-43-inch-ultra-hd-4k-led-smart-tv/p/itmfdzq6khv2pcvz?pid=TVSFDZQ6KMPJYWBV&srno=b_1_1&otracker=browse&lid=LSTTVSFDZQ6KMPJYWBVSJV5AK&fm=organic&iid=dbebf0fa-7a4d-4d11-9da2-4f69ff3583bd.TVSFDZQ6KMPJYWBV.SEARCH&ppt=browse&ppn=browse&ssid=st5dtn0mnk0000001564355126510',
'https://www.flipkart.com/samsung-super-6-nu6100-108cm-43-inch-ultra-hd-4k-led-smart-tv/p/itmfdzq6khv2pcvz?pid=TVSFDZQ6KMPJYWBV&srno=b_1_1&otracker=browse&lid=LSTTVSFDZQ6KMPJYWBVSJV5AK&fm=organic&iid=dbebf0fa-7a4d-4d11-9da2-4f69ff3583bd.TVSFDZQ6KMPJYWBV.SEARCH&ppt=browse&ppn=browse&ssid=st5dtn0mnk0000001564355126510',
2,
4,
2,
'ACTIVE',
50),
(5,
2334,
'Apple iPhone XS (Space Grey, 512 GB)',600, 1000,
'Apple iPhone XS (Space Grey, 512 GB) Short Description',
'Apple brings the big screen onto the palm of your hands with the iPhone Xs. Its 14.73 cm (5.8) display is as indulgent and tough as it gets. ',
'https://www.flipkart.com/apple-iphone-xs-space-grey-512-gb/p/itmf944ekkvgte45?pid=MOBF944EMFSDPY4U&srno=b_1_1&otracker=clp_banner_1_2.banner.BANNER_iphone-xs-i9e7-y75j-store_5JAKPKUE0Y3F&lid=LSTMOBF944EMFSDPY4UKKSQJ2&fm=neo%2Fmerchandising&iid=294b34dd-0607-42fc-a8fe-a02a6b6e6ccf.MOBF944EMFSDPY4U.SEARCH&ppt=browse&ppn=browse&ssid=qoxrtajw3k0000001564356261480',
'https://www.flipkart.com/apple-iphone-xs-space-grey-512-gb/p/itmf944ekkvgte45?pid=MOBF944EMFSDPY4U&srno=b_1_1&otracker=clp_banner_1_2.banner.BANNER_iphone-xs-i9e7-y75j-store_5JAKPKUE0Y3F&lid=LSTMOBF944EMFSDPY4UKKSQJ2&fm=neo%2Fmerchandising&iid=294b34dd-0607-42fc-a8fe-a02a6b6e6ccf.MOBF944EMFSDPY4U.SEARCH&ppt=browse&ppn=browse&ssid=qoxrtajw3k0000001564356261480',
1,
3,
1,
'ACTIVE',
150),
(6,
2434,
'Apple iPhone XR (Black, 128 GB)',350, 750,
'Apple iPhone XR (Black, 128 GB) Short Description',
'The iPhone XR has arrived to stun our senses with a host of features such as the Liquid Retina Display, a faster Face ID, and the powerful A12 Bionic Chip.',
'https://www.flipkart.com/apple-iphone-xr-black-128-gb/p/itmf9z7zhdgzwmzm?pid=MOBF9Z7ZYWNFGZUC&srno=b_1_1&otracker=clp_banner_1_2.banner.BANNER_apple-products-store_2XLEYVFO3M8Z&lid=LSTMOBF9Z7ZYWNFGZUCEOHXKN&fm=neo%2Fmerchandising&iid=644dbee6-3e0a-4a7a-8c7b-5c0b8276830f.MOBF9Z7ZYWNFGZUC.SEARCH&ppt=browse&ppn=browse&ssid=v248q8m6340000001564355316300',
'https://www.flipkart.com/apple-iphone-xr-black-128-gb/p/itmf9z7zhdgzwmzm?pid=MOBF9Z7ZYWNFGZUC&srno=b_1_1&otracker=clp_banner_1_2.banner.BANNER_apple-products-store_2XLEYVFO3M8Z&lid=LSTMOBF9Z7ZYWNFGZUCEOHXKN&fm=neo%2Fmerchandising&iid=644dbee6-3e0a-4a7a-8c7b-5c0b8276830f.MOBF9Z7ZYWNFGZUC.SEARCH&ppt=browse&ppn=browse&ssid=v248q8m6340000001564355316300',
1,
3,
1,
'ACTIVE',
150),
(7,
2535,
'Apple MacBook Air Core i5 5th Gen',620, 950,
'Apple MacBook Air Core i5 5th Gen - (8 GB/128 GB SSD/Mac OS Sierra) MQD32HN/A A1466  (13.3 inch, Silver, 1.35 kg) Short Description',
'It is fun to use, it is powerful and it looks incredible, meet the Apple MacBook Air. This Sleek and Lightweight laptop is powered by Intel Core i5 5th Gen processor with 8 GB DDR3 RAM and 128 GB of SSD capacity to make multitasking smooth and easy. It is designed with a Backlit Keyboard and its Multi-Touch Trackpad will be an absolute pleasure to use.',
'https://www.flipkart.com/apple-macbook-air-core-i5-5th-gen-8-gb-128-gb-ssd-mac-os-sierra-mqd32hn-a-a1466/p/itmevcpqqhf6azn3?pid=COMEVCPQBXBDFJ8C&srno=b_1_1&otracker=CLP_Filters&lid=LSTCOMEVCPQBXBDFJ8C4V6AHG&fm=organic&iid=a80a84a0-019a-4841-9b57-6293f53ef65b.COMEVCPQBXBDFJ8C.SEARCH&ppt=sp&ppn=sp&ssid=y50ssgrxcg0000001564358027876',
'https://www.flipkart.com/apple-macbook-air-core-i5-5th-gen-8-gb-128-gb-ssd-mac-os-sierra-mqd32hn-a-a1466/p/itmevcpqqhf6azn3?pid=COMEVCPQBXBDFJ8C&srno=b_1_1&otracker=CLP_Filters&lid=LSTCOMEVCPQBXBDFJ8C4V6AHG&fm=organic&iid=a80a84a0-019a-4841-9b57-6293f53ef65b.COMEVCPQBXBDFJ8C.SEARCH&ppt=sp&ppn=sp&ssid=y50ssgrxcg0000001564358027876',
1,
2,
1,
'ACTIVE',
200),
(8,
2636,
'Samsung 11.6 HD Chromebook',350, 750,
'Samsung 11.6 HD Chromebook - 2GB DDR3, Chrome OS Short Description',
'2017 Newest Premium High Performance Samsung 11.6 HD Chromebook - Intel Dual-Core Celeron N3050 Up to 2.16GHz, 2GB DDR3, 16GB eMMC Hard Drive, 802.11ac, Bluetooth, HDMI, HD Webcam, USB 3.0, Chrome OS',
'https://www.walmart.com/ip/3-0-HDMI-Drive-802-11ac-Premium-Celeron-2GB-Intel-Bluetooth-16GB-Chrome-Webcam-Chromebook-High-OS-N3050-2-16GHz-USB-Newest-Dual-Core-Hard-eMMC-2017-D/581375507',
'https://www.walmart.com/ip/3-0-HDMI-Drive-802-11ac-Premium-Celeron-2GB-Intel-Bluetooth-16GB-Chrome-Webcam-Chromebook-High-OS-N3050-2-16GHz-USB-Newest-Dual-Core-Hard-eMMC-2017-D/581375507',
1,
3,
2,
'ACTIVE',
50),
(9,
2734,
'Apple MacBook Pro Core i5 8th Gen',800, 1300,
'Apple MacBook Pro Core i5 8th Gen Short Description',
'Apple MacBook Pro Core i5 8th Gen - (8 GB/512 GB SSD/Mac OS Mojave) MR9R2HN/A  (13.3 inch, Space Grey, 1.37 kg) ',
'https://www.flipkart.com/apple-macbook-pro-core-i5-8th-gen-8-gb-512-gb-ssd-mac-os-mojave-mr9r2hn-a/p/itmf9egnm4yzmzy7?pid=COMF9EGNJ3EZFCRB&srno=b_1_2&otracker=CLP_Filters&lid=LSTCOMF9EGNJ3EZFCRBWFZYYC&fm=organic&iid=fc6ce331-e493-4998-aa57-20f6dcd2a479.COMF9EGNJ3EZFCRB.SEARCH&ppt=sp&ppn=sp&ssid=7xdu0hcwrk0000001564358225087',
'https://www.flipkart.com/apple-macbook-pro-core-i5-8th-gen-8-gb-512-gb-ssd-mac-os-mojave-mr9r2hn-a/p/itmf9egnm4yzmzy7?pid=COMF9EGNJ3EZFCRB&srno=b_1_2&otracker=CLP_Filters&lid=LSTCOMF9EGNJ3EZFCRBWFZYYC&fm=organic&iid=fc6ce331-e493-4998-aa57-20f6dcd2a479.COMF9EGNJ3EZFCRB.SEARCH&ppt=sp&ppn=sp&ssid=7xdu0hcwrk0000001564358225087',
1,
3,
1,
'ACTIVE',
50),
(10,
2504,
'SAMSUNG 11.6" Chromebook 3',150, 250,
'SAMSUNG 11.6" Chromebook 3, 16GB eMMC, 4GB RAM, Metallic Black - XE500C13-K04US Short Description',
'The Chromebook 3 is a quality device. But then you’d expect nothing less from a leading technology brand like Samsung.',
'https://www.walmart.com/ip/SAMSUNG-11-6-Chromebook-3-16GB-eMMC-4GB-RAM-Metallic-Black-XE500C13-K04US/796891786',
'https://www.walmart.com/ip/SAMSUNG-11-6-Chromebook-3-16GB-eMMC-4GB-RAM-Metallic-Black-XE500C13-K04US/796891786',
1,
3,
2,
'ACTIVE',
100),
(11,
1598,
' Nike Game Jersey - Red',80, 100,
'Patrick Mahomes Kansas City Chiefs Nike Game Jersey - Red',
'Get the look of a tried and true Kansas City Chiefs fan with this Game jersey and let everyone know you are a die-hard fan! ',
'https://www.walmart.com/ip/Patrick-Mahomes-Kansas-City-Chiefs-Nike-Game-Jersey-Red/602226803',
'https://www.walmart.com/ip/Patrick-Mahomes-Kansas-City-Chiefs-Nike-Game-Jersey-Red/602226803',
4,
12,
NULL,
'ACTIVE',
1000
),
(12,
1558,
'Fanatics Branded Fast Break Jersey',80, 100,
'Fanatics Branded Fast Break Replica Jersey White',
'Kawhi Leonard LA Clippers Fanatics Branded Fast Break Replica Jersey White - Association Edition',
'https://www.walmart.com/ip/Kawhi-Leonard-LA-Clippers-Fanatics-Branded-Fast-Break-Replica-Jersey-White-Association-Edition/439005440',
'https://www.walmart.com/ip/Kawhi-Leonard-LA-Clippers-Fanatics-Branded-Fast-Break-Replica-Jersey-White-Association-Edition/439005440',
4,
12,
NULL,
'ACTIVE',
1000
),
(13,
1358,
'Boston Celtics Mitchell & Ness Swingman',90, 120,
'Larry Bird Boston Celtics Mitchell & Ness 1985-86 Hardwood Classics Swingman',
'Larry Bird Boston Celtics Mitchell & Ness 1985-86 Hardwood Classics Swingman Jersey - White',
'https://www.walmart.com/ip/Larry-Bird-Boston-Celtics-Mitchell-Ness-1985-86-Hardwood-Classics-Swingman-Jersey-White/917318234',
'https://www.walmart.com/ip/Larry-Bird-Boston-Celtics-Mitchell-Ness-1985-86-Hardwood-Classics-Swingman-Jersey-White/917318234',
4,
12,
NULL,
'ACTIVE',
1000
),
(14,
1358,
'Allen Iverson Philadelphia 76ers T-Shirt',20, 36,
'Allen Iverson Philadelphia 76ers Mitchell & Ness Hardwood Classics T-Shirt',
'Allen Iverson Philadelphia 76ers Mitchell & Ness Hardwood Classics Retro Name & Number T-Shirt - Royal',
'https://www.walmart.com/ip/Allen-Iverson-Philadelphia-76ers-Mitchell-Ness-Hardwood-Classics-Retro-Name-Number-T-Shirt-Royal/602575913',
'https://www.walmart.com/ip/Allen-Iverson-Philadelphia-76ers-Mitchell-Ness-Hardwood-Classics-Retro-Name-Number-T-Shirt-Royal/602575913',
4,
12,
NULL,
'ACTIVE',
1000
),
(15,
1251,
'Detroit Pistons Swingman Jersey - Blue',100, 130,
'Grant Hill Detroit Pistons Hardwood Classics Swingman Jersey',
'Grant Hill Detroit Pistons Mitchell & Ness 1995-96 Hardwood Classics Swingman Jersey - Blue',
'https://www.walmart.com/ip/Grant-Hill-Detroit-Pistons-Mitchell-Ness-1995-96-Hardwood-Classics-Swingman-Jersey-Blue/354195509',
'https://www.walmart.com/ip/Grant-Hill-Detroit-Pistons-Mitchell-Ness-1995-96-Hardwood-Classics-Swingman-Jersey-Blue/354195509',
4,
12,
NULL,
'ACTIVE',
1000
),
(16,
1252,
'LG Entertainment System ',120, 155,
'LG 230W Hi-Fi Entertainment System with Bluetooth Connectivity - CM4360',
'LG 230W Hi-Fi Entertainment System with Bluetooth Connectivity - CM4360',
'https://www.walmart.com/ip/Grant-Hill-Detroit-Pistons-Mitchell-Ness-1995-96-Hardwood-Classics-Swingman-Jersey-Blue/354195509',
'https://www.walmart.com/ip/Grant-Hill-Detroit-Pistons-Mitchell-Ness-1995-96-Hardwood-Classics-Swingman-Jersey-Blue/354195509',
2,
16,
NULL,
'ACTIVE',
100
),
(17,
1253,
'LG DVD Player',40, 50,
'LG DVD Player with USB Direct Recording and HDMI Output - DP132H',
'LG DVD Player with USB Direct Recording and HDMI Output - DP132H',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
16,
NULL,
'ACTIVE',
100
),
(18,
1254,
'Google Home',80, 100,
'Google Home - Smart Speaker & Google Assistant',
'Google Home - Smart Speaker & Google Assistant',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
16,
NULL,
'ACTIVE',
100
),
(19,
1255,
'Logitech Speaker System',25, 33,
'Logitech Z313 Multimedia Speaker System',
'Logitech Z313 Multimedia Speaker System',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
16,
NULL,
'ACTIVE',
100
),
(20,
1256,
'RCA DVD Home Theater System ',50, 70,
'RCA DVD Home Theater System with HDMI 1080p Output 8 pc Box',
'RCA DVD Home Theater System with HDMI 1080p Output 8 pc Box',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
16,
NULL,
'ACTIVE',
100
),
(21,
2751,
'Onn Tilting TV Wall Mount Kit ',15, 22,
'Onn Tilting TV Wall Mount Kit for 24" to 84" TVs with HDMI Cable (ONA16TM013E)',
'Onn Tilting TV Wall Mount Kit for 24" to 84" TVs with HDMI Cable (ONA16TM013E)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
15,
NULL,
'ACTIVE',
100
),
(22,
2753,
'ONN Universal Wall Mount Kit ',30, 42,
'ONN Full-Motion Articulating, Tilt/Swivel, Universal Wall Mount Kit for 19" to 84" TVs with HDMI Cable (ONA16TM014E)',
'ONN Full-Motion Articulating, Tilt/Swivel, Universal Wall Mount Kit for 19" to 84" TVs with HDMI Cable (ONA16TM014E)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
15,
NULL,
'ACTIVE',
100
),
(23,
2755,
'ONN Full-Motion Wall Mount ',35, 45,
'ONN Full-Motion Wall Mount for 10"- 50" TVs with Tilt and Swivel Articulating Arm and HDMI Cable (UL Certified)',
'ONN Full-Motion Wall Mount for 10"- 50" TVs with Tilt and Swivel Articulating Arm and HDMI Cable (UL Certified)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
15,
NULL,
'ACTIVE',
100
),
(24,
2757,
'SANUS Tilting Wall Mount ',50, 72,
'SANUS Tilting Wall Mount for 32"-70" Flat-Panel TVs',
'SANUS Tilting Wall Mount for 32"-70" Flat-Panel TVs',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
15,
NULL,
'ACTIVE',
100
),
(25,
2758,
'SANUS Dual-Purpose Wall Mount ',90, 122,
'SANUS Dual-Purpose Wall Mount offers choice of tilting or low-profile mount for 27" – 110" TVs',
'SANUS Dual-Purpose Wall Mount offers choice of tilting or low-profile mount for 27" – 110" TVs',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
15,
NULL,
'ACTIVE',
100
),
(26,
3110,
'Philips Blu-Ray and DVD Player',45, 58,
'Philips WiFi Streaming Blu-Ray and DVD Player - BDP2501/F7',
'Philips WiFi Streaming Blu-Ray and DVD Player - BDP2501/F7',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
14,
NULL,
'ACTIVE',
150
),
(27,
3112,
'Philips - BDP1502/F7',40, 50,
'Philips Blu-Ray and DVD Player - BDP1502/F7',
'Philips Blu-Ray and DVD Player - BDP1502/F7',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
14,
NULL,
'ACTIVE',
150
),
(28,
3114,
'Sony BDP-S1700 ',50, 70,
'Sony Streaming Blu-ray Disc Player - BDP-S1700',
'Sony Streaming Blu-ray Disc Player - BDP-S1700',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
14,
NULL,
'ACTIVE',
150
),
(29,
3116,
'Sony 4K BDPS6700',82, 98,
'Sony 4K Upscaling 3D Streaming Blu-ray Disc Player - BDPS6700',
'Sony 4K Upscaling 3D Streaming Blu-ray Disc Player - BDPS6700',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
14,
NULL,
'ACTIVE',
150
),
(30,
3118,
'Sony UBP-X700',130, 168,
'Sony 4K UHD Blu-ray Player - UBP-X700',
'Sony 4K UHD Blu-ray Player - UBP-X700',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
14,
NULL,
'ACTIVE',
150
),
(31,
3210,
'Canon EOS 1300D',350, 500,
'Canon EOS 1300D / Rebel T6 Digital SLR Camera w/ EF-S 18-55mm IS EF-S 75-300mm Lens Bundle',
'Canon EOS 1300D / Rebel T6 Digital SLR Camera w/ EF-S 18-55mm IS EF-S 75-300mm Lens Bundle',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
13,
NULL,
'ACTIVE',
50
),
(32,
3212,
'Nikon D5300',270,350,
'Nikon D5300 - Digital camera - SLR - 24.2 MP - APS-C - body only - Wi-Fi - black',
'Nikon D5300 - Digital camera - SLR - 24.2 MP - APS-C - body only - Wi-Fi - black',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
13,
NULL,
'ACTIVE',
50
),
(33,
3214,
'Nikon D5300 Camera Body',250, 300,
'Nikon D5300 24.2MP CMOS DX-Format Digital SLR Camera Body ONLY ',
'Nikon D5300 24.2MP CMOS DX-Format Digital SLR Camera Body ONLY ',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
13,
NULL,
'ACTIVE',
50
),
(34,
3216,
'Nikon D3400',310, 380,
'Nikon D3400 Digital SLR Camera with 24.2 Megapixels and 18-55mm Lens Included',
'Nikon D3400 Digital SLR Camera with 24.2 Megapixels and 18-55mm Lens Included',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
13,
NULL,
'ACTIVE',
50
),
(35,
3218,
'Over Shoulder Sling Padded Camera Case Bag',35, 50,
'Over Shoulder Sling Padded Camera Case Bag with Weather Resistant Design by USA Gear ',
'Over Shoulder Sling Padded Camera Case Bag with Weather Resistant Design by USA Gear - Work With Olympus , Fujifilm , Pentax and More Cameras',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
13,
NULL,
'ACTIVE',
50
),
(36,
3310,
'Optihot 2',220, 300,
'Optihot 2 Golf Simulator',
'Optihot 2 Golf Simulator',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
11,
NULL,
'ACTIVE',
500
),
(37,
3312,
'Wilson Basketball',20, 30,
'Wilson Basketball Street shot, 29.s" ',
'Wilson Basketball Street shot, 29.s" ',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
11,
NULL,
'ACTIVE',
5000
),
(38,
3314,
'Wilson Profile XD',230, 300,
'Wilson Profile XD Senior Package Golf Set, Right Handed',
'Wilson Profile XD Senior Package Golf Set, Right Handed',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
11,
NULL,
'ACTIVE',
200
),
(39,
3316,
'Riddell Helmet',270, 340,
'Riddell Speedflex Youth Football Helmet',
'Riddell Speedflex Youth Football Helmet',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
11,
NULL,
'ACTIVE',
500
),
(40,
3318,
'Shock Doctor Ultra Carbon Chin Strap-Cup ',20, 30,
'Shock Doctor Ultra Carbon Chin Strap-Cup Football/Lacrosse Anti-Microbial New',
'Shock Doctor Ultra Carbon Chin Strap-Cup Football/Lacrosse Anti-Microbial New',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
11,
NULL,
'ACTIVE',
500
),
(41,
3418,
'Ozark Trail Cabin Tent',160, 200,
'Ozark Trail 10-Person Dark Rest Instant Cabin Tent',
'Ozark Trail 10-Person Dark Rest Instant Cabin Tent',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
10,
NULL,
'ACTIVE',
50
),
(42,
3416,
'Ozark Trail 3-Room Cabin Tent ',70, 100,
'Ozark Trail 10-Person 3-Room Cabin Tent with 2 Side Entrances',
'Ozark Trail 10-Person 3-Room Cabin Tent with 2 Side Entrances',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
10,
NULL,
'ACTIVE',
50
),
(43,
3510,
'Roadmaster Granite Peak Mountain Bike',60, 100,
'Roadmaster Granite Peak Mountain Bike, 26" wheels, Black/White',
'Roadmaster Granite Peak Mountain Bike, 26" wheels, Black/White',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
9,
NULL,
'ACTIVE',
300
),
(44,
3512,
'Hyper 26" Shocker Mountain Bike',950, 130,
'Hyper 26" Shocker Dual Suspension Mountain Bike, Black',
'Hyper 26" Shocker Dual Suspension Mountain Bike, Black',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
3,
9,
NULL,
'ACTIVE',
320
),
(45,
3616,
'Gucci Bloom Acqua ',40, 70,
'Gucci Bloom Acqua Di Fiori Eau De Toilette Perfume For Women 3.3 Oz',
'Gucci Bloom Acqua Di Fiori Eau De Toilette Perfume For Women 3.3 Oz',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
8,
NULL,
'ACTIVE',
50
),
(46,
3612,
'Prada Candy Eau De Parfum',22, 40,
'Prada Candy Eau De Parfum, Perfume For Women, 1 Oz',
'Prada Candy Eau De Parfum, Perfume For Women, 1 Oz',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
8,
NULL,
'ACTIVE',
50
),
(47,
3718,
'Boys Slim School Uniform Twill Pant',20, 30,
'Wonder Nation Boys Slim School Uniform Twill Pant with Double Knee (Little Boys & Big Boys)',
'Wonder Nation Boys Slim School Uniform Twill Pant with Double Knee (Little Boys & Big Boys)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
7,
NULL,
'ACTIVE',
400
),
(48,
3714,
'Cherokee Boys Jogger Pant ',12, 15,
'Cherokee Boys School Uniform Twill Jogger Pant (Little Boys & Big Boys)',
'Cherokee Boys School Uniform Twill Jogger Pant (Little Boys & Big Boys)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
7,
NULL,
'ACTIVE',
500
),
(49,
3818,
'George Jean',20, 30,
'George Slim Straight Fit Jean',
'George Slim Straight Fit Jean',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
6,
NULL,
'ACTIVE',
500
),
(50,
3812,
'No Boundaries Jacket',15, 20,
'No Boundaries Mens Bomber Jacket',
'No Boundaries Mens Bomber Jacket',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
6,
NULL,
'ACTIVE',
520
),
(51,
3918,
'Brinley Co. ',30, 40,
'Brinley Co. Womens Faux Leather Strappy Wedges',
'Brinley Co. Womens Faux Leather Strappy Wedges',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
5,
NULL,
'ACTIVE',
200
),
(52,
3915,
'iFLY',28, 35,
'iFLY - Backpack Heather 16", White / Rose Gold Print',
'iFLY - Backpack Heather 16", White / Rose Gold Print',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
4,
5,
NULL,
'ACTIVE',
100
),
(53,
4010,
'Sceptre 50" Class FHD LED TV',120, 180,
'Sceptre 50" Class FHD (1080P) LED TV (X505BV-FSR)',
'Sceptre 50" Class FHD (1080P) LED TV (X505BV-FSR)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
4,
NULL,
'ACTIVE',
50
),
(54,
4014,
'ONN Smart TV Bundle',200, 300,
'ONN 55" Class 4K LED TV + Google Chromecast (Smart TV Bundle)',
'ONN 55" Class 4K LED TV + Google Chromecast (Smart TV Bundle)',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
2,
4,
NULL,
'ACTIVE',
60
),
(55,
4118,
'HP ZBook Studio x360 G5 15.6" LCD',1570, 2230,
'HP ZBook Studio x360 G5 15.6" LCD 2 in 1 Mobile Workstation ',
'HP ZBook Studio x360 G5 15.6" LCD 2 in 1 Mobile Workstation - Intel Core i7 (8th Gen) i7-8750H Hexa-core (6 Core) 2.2GHz - 16GB DDR4 SDRAM - 512GB SSD - Windows 10 Pro',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
2,
NULL,
'ACTIVE',
20
),
(56,
4114,
'HP Pavilion 15 Laptop 15.6" ',500, 800,
'HP Pavilion 15 Horizon Blue Laptop 15.6" Full HD Display',
'HP Pavilion 15 Horizon Blue Laptop 15.6" Full HD Display, AMD Ryzen 5 3500U, AMD Radeon™ Vega 8 Graphic , 8GB SDRAM, 1TB HDD + 128GB SSD, 15-cw1063wm',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
2,
NULL,
'ACTIVE',
40
),
(57,
4218,
'Microsoft Surface Pro 4 ',450, 600,
'Microsoft Surface Pro 4 12.3" 4GB/128GB Intel Core m3',
'Microsoft Surface Pro 4 12.3" 4GB/128GB Intel Core m3',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
1,
NULL,
'ACTIVE',
100
),
(58,
4214,
'Microsoft Surface Go',320, 400,
'NEW 10'' Microsoft Surface Go, Intel Pentium, 4GB Memory, 64GB Storage, MHN-00001',
'NEW 10'' Microsoft Surface Go, Intel Pentium, 4GB Memory, 64GB Storage, MHN-00001',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
1,
NULL,
'ACTIVE',
150
),
(59,
3318,
'Lenovo Tab E7, 7" Android Tablet',35, 55,
'Lenovo Tab E7, 7" Android Tablet, Quad-Core Processor, 8GB Storage, Slate Black, Bundle with Back Cover Included',
'Lenovo Tab E7, 7" Android Tablet, Quad-Core Processor, 8GB Storage, Slate Black, Bundle with Back Cover Included',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
1,
NULL,
'ACTIVE',
300
),
(60,
3318,
'Digiland 8" Tablet ', 45, 60,
'Digiland 8" 8GB 1.3GHz Quad-Core CPU Tablet - DL8006',
'Digiland 8" 8GB 1.3GHz Quad-Core CPU Tablet - DL8006',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
'https://www.walmart.com/cp/televisions-video/1060825?povid=3944+%7C+2018-08-03+%7C+Shop%20by%20Cat_TV%20&%20Video',
1,
1,
NULL,
'ACTIVE',
270
)
;



INSERT INTO ProductAttributeMap
VALUES(1,2);

INSERT INTO PaymentOptions
VALUES
(1, 'Credit Card', 'Payment using Credit Card'),
(2, 'Cash On Delivery', 'Payment using COD'),
(3, 'Debit Card', 'Payment using Debit Card');

INSERT INTO ShipmentOptions
VALUES
(1,'Same Day','Delivers within a day'),
(2,'2 Business Days','Delivers within 2 days'),
(3,'5 Business Days','Delivers within 5 days');

INSERT INTO DiscountCode
VALUES
(1,'Summer Sale','Summer Discount',10),
(2,'Thanks Giving','Thanks Giving Discount',15),
(3,'Memorial Day','Memorial Day Discount',5),
(4,'Season End','Seasons End  Disocunt',10);


INSERT INTO StateTaxRates
VALUES
(1,21, 20),
(2,1, 15);

INSERT INTO Orders
VALUES
(1, 1,		1,		 1,	1,1,'07-28-2019','07-28-2019',162,'Delivered'),
(2, 3,		1,		 2,	3,1,'07-28-2019','08-02-2019',1170,'Processing'),
(3, 4,		2,		 1,	1,1,'11-22-2018','11-22-2018',2210,'Delivered'),
(4, 7,		4,		 2,	2,1,'06-28-2019','06-30-2019',675,'Delivered'),
(5, 9,		4,		 3,	3,1,'07-25-2019','08-01-2019',675,'Processing'),
(6, 13,		3,		 1,	1,2,'05-25-2019','05-25-2019',1805,'Delivered'),
(7, 18,		1,		 1,	3,2,'07-28-2019','07-28-2019',225,'Delivered'),
(8, 20,		2,		 3,	1,2,'11-22-2018','11-29-2018',475,'Delivered'),
(9, 6,		4,		 3,	1,2,'07-27-2019','08-03-2019',855,'Processing'),
(10,16,		3,		 3,	1,1,'05-25-2019','05-29-2019',950,'Delivered'),
(12, 14,	NULL,	 3,	2,2,'01-07-2019','01-11-2019',855,'Delivered'),
(15, 2,		1,		 2,	1,2,'03-07-2019','03-10-2019',855,'Processing'),
(12, 18,	NULL,	 2,	3,2,'02-17-2019','02-23-2019',855,'Delivered'),
(13, 10,	NULL,	 1,	1,2,'05-21-2019','05-21-2019',855,'Delivered'),
(14, 12,	4,		 3,	1,2,'08-06-2019','08-11-2019',855,'Processing'),
(11, 19,	2,		 3,	1,2,'11-22-2018','11-27-2018',855,'Delivered'),
(3, 15,		NULL,	 3,	3,2,'03-17-2019','03-22-2019',855,'Delivered'),
(5, 8,		4,		 3,	2,2,'06-27-2019','07-02-2019',855,'Processing'),
(7, 11,		NULL,	 3,	3,2,'06-27-2019','07-03-2019',855,'Delivered');

INSERT INTO OrderItems
VALUES
(1,1,1,180,180),
(2,2,2,1200,2400),
(3,3,1,1400, 1400),
(6,5,1,1000,1000),
(4,8,1,750,750),
(5,6,1,750,750),
(9,7,1,950,950),
(7,10,1,250,250),
(3,2,1,1200,1200),
(6,4,1,180,180),
(2,9,1,1300,1300),
(8,10,2,250,500),
(10,5,1,1000,1000);

INSERT INTO Cart 
VALUES (2,2);

INSERT INTO CartItems
VALUES
(2,1),
(2,2);

INSERT INTO ProductRating
VALUES
(1,1,4,'Happy with Purchase'),
(8,2,5, 'Nice Purchase'),
(6,2,5, 'Great Product'),
(2,3,4, 'Cool Purchase'),
(5,3,5, 'Happy Customer');












