delimiter $$

$$

delimiter ;

DROP TABLE IF EXISTS `CC_INFO`;

CREATE TABLE IF NOT EXISTS `hollyhotel`.`CC_INFO` (
  `CCID` INT NOT NULL AUTO_INCREMENT COMMENT 'Surrogate Key',
  `CustomerID` INT NOT NULL COMMENT 'Links Customer to the Credit Card',
  `AddressSeq` INT NOT NULL COMMENT 'Links Credit Card to billing address.  If the same as the primary then 0, otherwise add new sequence',
  `NameOnCard` VARCHAR(100) NULL,
  `CreditCardNetwork` VARCHAR(45) NULL COMMENT 'Visa, Mastercard, Discover',
  `CCNumber` VARCHAR(16) NOT NULL COMMENT 'Credit card Number, Normally12 digits',
  `ExpMonth` INT NULL COMMENT 'Expiration Month 1-12',
  `ExpYear` INT NULL COMMENT 'Expiration Year',
  PRIMARY KEY (`CCID`),
  INDEX `CC_INFO_CustAddrSeq_FK_idx` (`CustomerID` ASC, `AddressSeq` ASC),
  CONSTRAINT `CC_INFO_CustAddrSeq_FK`
    FOREIGN KEY (`CustomerID` , `AddressSeq`)
    REFERENCES `hollyhotel`.`ADDRESS` (`CustomerID` , `AddressSeq`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `CC_INFO_CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `hollyhotel`.`CUSTOMER` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Holds Credit Card Information (would not exist in this manne' /* comment truncated */ /*r in real life)*/