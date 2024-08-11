-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Customer_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Customer_details` (
  `customerid` INT NOT NULL AUTO_INCREMENT,
  `ContactNumber` INT NOT NULL,
  `Email` VARCHAR(255) NOT NULL,
  `FullName` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`customerid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Bookings` (
  `Bookingid` INT NOT NULL,
  `date` DATE NULL,
  `table_number` DECIMAL(30) NOT NULL,
  `customerid` INT NOT NULL,
  `Bookingscol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Bookingid`),
  INDEX `customerid_idx` (`customerid` ASC) VISIBLE,
  CONSTRAINT `customerid`
    FOREIGN KEY (`customerid`)
    REFERENCES `mydb`.`Customer_details` (`customerid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`MenuItems`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`MenuItems` (
  `MenuItemsID` INT NOT NULL,
  `StarterName` VARCHAR(45) NULL,
  `CourseName` VARCHAR(45) NULL,
  `DesertName` VARCHAR(45) NULL,
  PRIMARY KEY (`MenuItemsID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Menu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Menu` (
  `MenuID` INT NOT NULL,
  `cuisines` VARCHAR(50) NULL,
  `MenuName` VARCHAR(45) NULL,
  `MenuItemsID` INT NOT NULL,
  PRIMARY KEY (`MenuID`),
  INDEX `MenuItemsID_idx` (`MenuItemsID` ASC) VISIBLE,
  CONSTRAINT `MenuItemsID`
    FOREIGN KEY (`MenuItemsID`)
    REFERENCES `mydb`.`MenuItems` (`MenuItemsID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT,
  `quantity` INT NOT NULL,
  `total_cost` DECIMAL(15) NOT NULL,
  `OrderDate` DATE NOT NULL,
  `Bookingid` INT NOT NULL,
  `menuid` INT NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `Bookingid_idx` (`Bookingid` ASC) VISIBLE,
  INDEX `menuid_idx` (`menuid` ASC) VISIBLE,
  CONSTRAINT `Bookingid`
    FOREIGN KEY (`Bookingid`)
    REFERENCES `mydb`.`Bookings` (`Bookingid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `menuid`
    FOREIGN KEY (`menuid`)
    REFERENCES `mydb`.`Menu` (`MenuID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Order_delivery_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Order_delivery_status` (
  `deliverydate` DATE NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `OrderID` INT NOT NULL,
  PRIMARY KEY (`deliverydate`),
  INDEX `OrderID_idx` (`OrderID` ASC) VISIBLE,
  CONSTRAINT `OrderID`
    FOREIGN KEY (`OrderID`)
    REFERENCES `mydb`.`Orders` (`OrderID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Staff_information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Staff_information` (
  `staffid` INT NOT NULL,
  `role` VARCHAR(20) NULL,
  `salary` DECIMAL(20) NULL,
  `MenuID` INT NOT NULL,
  PRIMARY KEY (`staffid`),
  INDEX `MenuID_idx` (`MenuID` ASC) VISIBLE,
  CONSTRAINT `MenuID`
    FOREIGN KEY (`MenuID`)
    REFERENCES `mydb`.`Menu` (`MenuID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
SELECT Customer_Details.customerid, Customer_Details.FullName, Bookings.Bookingid, Orders.OrderID, Orders.total_cost, Menu.MenuName, MenuItems.CourseName FROM Customer_Details INNER JOIN Bookings ON Customer_Details.customerid = Bookings.customerid INNER JOIN Orders ON Bookings.Bookingid = Orders.Bookingid INNER JOIN Menu ON Orders.MenuID = Menu.MenuID INNER JOIN MenuItems ON Menu.MenuItemsID = MenuItems.MenuItemsID WHERE total_cost > 150;
SELECT MenuName From Menu WHERE MenuName = ANY (SELECT quantity From Orders WHERE quantity > 2);
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
SELECT MAX(quantity) FROM Orders;
END //
DELIMITER ; 
CALL GetMaxQuantity ();
CREATE VIEW OrdersView AS SELECT * FROM Orders;
SELECT * FROM OrdersView;
PREPARE GetOrderDetail FROM 'SELECT OrderID, quantity, total_cost FROM Orders WHERE OrderID = ? ';
SET @OrderID = 1; 
EXECUTE GetOrderDetail USING @OrderID; 
DELIMITER //
CREATE PROCEDURE CancelOrder(IN ID INT)
BEGIN
DELETE FROM Orders WHERE OrderID = ID;
END //
DELIMITER ; 
CALL CancelOrder(5);
