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
ALTER TABLE Bookings DROP COLUMN Bookingscol;
ALTER TABLE Bookings RENAME COLUMN date TO BookingDate;
INSERT INTO customer_details (customerid, ContactNumber, Email, FullName) VALUES (1, 87654321, 'malo@nn', 'malo'), (2, 12345678, 'nano@nn','nano'), (3, 234567, 'kako@kk', 'kako'), (4, 87654, 'wan@ww', 'wan');
INSERT INTO bookings(Bookingid, BookingDate, table_number, customerid) VALUES (1, '2022-10-10', 5, 1), (2, '2022-11-12', 3, 3), (3, '2022-10-11', 2, 2), (4, '2022-10-13', 2, 1);
SELECT * FROM bookings;
SELECT * FROM customer_details;
DELIMITER // 
CREATE PROCEDURE CheckBooking (IN bookingdatee DATE, IN table_numberr DECIMAL)
BEGIN
SELECT CONCAT('table', table_numberr, 'is already booked') AS booking_status FROM bookings WHERE table_number = table_numberr;
END // 
DELIMITER ;
CALL CheckBooking("2022-11-12", 3);
SELECT * FROM bookings;
DELIMITER // 
CREATE PROCEDURE AddValidBooking (IN bookingdatee DATE, IN table_numberr DECIMAL)
BEGIN
DECLARE booking_count INT;
START TRANSACTION;
SELECT COUNT(*) INTO booking_count FROM bookings WHERE BookingDate = bookingdatee AND table_number = table_numberr;
  IF booking_count > 0 THEN
        ROLLBACK;
        SELECT CONCAT('Table is already booked for this date') AS booking_status;
    ELSE
         INSERT INTO bookings (BookingDate, table_number)
        VALUES (bookingdatee, table_numberr);
        COMMIT;
        SELECT 'Booking confirmed' AS booking_status;
  END IF;
END //
DELIMITER ;
SELECT * FROM bookings;
CALL AddValidBooking("2022-11-12", 3);
ALTER TABLE Bookings
 MODIFY COLUMN table_number INT;
 DELIMITER //
CREATE PROCEDURE AddBooking(bookingidd INT, BookingDatee DATE, table_numberr INT, customeridd INT )
BEGIN
INSERT INTO Bookings (bookingid, bookingdate, table_number, customerid) VALUES (bookingidd, BookingDatee, table_numberr, customeridd );
SELECT 'New Booking added' AS confirmation; 
END //
DELIMITER ;
CALL AddBooking(5, "2022-12-30", 6, 4);
DROP PROCEDURE UpdateBooking;
CALL UpdateBooking( 4, "2022-12-30");
DROP PROCEDURE UpdateBooking;
DELIMITER //
CREATE PROCEDURE UpdateBooking(bookingidd INT, BookingDatee DATE)
BEGIN
UPDATE Bookings SET BookingDate = BookingDatee, Bookingid = bookingidd WHERE Bookingid = bookingidd ;
SELECT CONCAT('booking', bookingidd, 'updated') AS confirmation; 
END //
DELIMITER ;
CALL UpdateBooking( 4, "2022-12-30");
DELIMITER //
CREATE PROCEDURE CancelBooking(bookingidd INT)
BEGIN
DELETE FROM Bookings WHERE Bookingid = bookingidd;
SELECT CONCAT('booking', bookingidd, 'cancelled') AS confirmation; 
END //
DELIMITER ; 
CALL CancelBooking (4);











 
