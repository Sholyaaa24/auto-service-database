-- Autoservice database schema
-- Generated from the supplied autoservice_db_model.mwb on 2026-11-03.
-- Structure only: no records or customer information included.
-- The auto-increment flag on order_service.id_order is preserved from the source model.
-- Review that column before using this model outside an educational setting.

CREATE DATABASE IF NOT EXISTS `autoservice_db`
  CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci;
USE `autoservice_db`;

-- Existing database is not dropped. For a fresh install, run in an empty schema.

-- car
CREATE TABLE IF NOT EXISTS `car` (
  `id_car` INT NOT NULL AUTO_INCREMENT,
  `id_client` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `model` VARCHAR(45) NOT NULL,
  `plate_number` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_car`),
  KEY `fk_car_client_idx` (`id_client`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- client
CREATE TABLE IF NOT EXISTS `client` (
  `id_client` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NULL DEFAULT NULL,
  `email` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id_client`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- order_part
CREATE TABLE IF NOT EXISTS `order_part` (
  `id_order` INT NOT NULL,
  `id_part` INT NOT NULL,
  `quantity` INT NOT NULL,
  `cost` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_order`, `id_part`),
  KEY `fk_order_part_part_idx` (`id_part`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- order_service
CREATE TABLE IF NOT EXISTS `order_service` (
  `id_order` INT NOT NULL AUTO_INCREMENT,
  `id_service` INT NOT NULL,
  `quantity` INT NOT NULL,
  `cost` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_order`, `id_service`),
  KEY `fk_order_service_service_idx` (`id_service`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- payment
CREATE TABLE IF NOT EXISTS `payment` (
  `id_payment` INT NOT NULL AUTO_INCREMENT,
  `id_order` INT NOT NULL,
  `payment_date` TIMESTAMP(1) NOT NULL,
  `payment_method` VARCHAR(45) NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_payment`),
  KEY `fk_payment_order_idx` (`id_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- service
CREATE TABLE IF NOT EXISTS `service` (
  `id_service` INT NOT NULL AUTO_INCREMENT,
  `service_name` VARCHAR(45) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_service`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- spare_part
CREATE TABLE IF NOT EXISTS `spare_part` (
  `id_part` INT NOT NULL AUTO_INCREMENT,
  `part_name` VARCHAR(45) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `stock` INT NOT NULL,
  PRIMARY KEY (`id_part`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- work_order
CREATE TABLE IF NOT EXISTS `work_order` (
  `id_order` INT NOT NULL AUTO_INCREMENT,
  `id_car` INT NOT NULL,
  `order_date` TIMESTAMP(1) NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `total_amount` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`id_order`),
  KEY `fk_order_car_idx` (`id_car`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Foreign keys
ALTER TABLE `car`
  ADD CONSTRAINT `fk_car_client`
  FOREIGN KEY (`id_client`) REFERENCES `client` (`id_client`);
ALTER TABLE `order_part`
  ADD CONSTRAINT `fk_order_part_order`
  FOREIGN KEY (`id_order`) REFERENCES `work_order` (`id_order`);
ALTER TABLE `order_part`
  ADD CONSTRAINT `fk_order_part_part`
  FOREIGN KEY (`id_part`) REFERENCES `spare_part` (`id_part`);
ALTER TABLE `order_service`
  ADD CONSTRAINT `fk_order_service_order`
  FOREIGN KEY (`id_order`) REFERENCES `work_order` (`id_order`);
ALTER TABLE `order_service`
  ADD CONSTRAINT `fk_order_service_service`
  FOREIGN KEY (`id_service`) REFERENCES `service` (`id_service`);
ALTER TABLE `payment`
  ADD CONSTRAINT `fk_payment_order`
  FOREIGN KEY (`id_order`) REFERENCES `work_order` (`id_order`);
ALTER TABLE `work_order`
  ADD CONSTRAINT `fk_order_car`
  FOREIGN KEY (`id_car`) REFERENCES `car` (`id_car`);

-- Simplified view definition: the source model contains a local root@localhost DEFINER.
-- Avoid exporting machine-specific DEFINER settings into a public repository.
CREATE OR REPLACE VIEW `v_order_details` AS
SELECT
    wo.id_order,
    c.full_name,
    car.brand,
    car.model,
    car.plate_number,
    wo.order_date,
    wo.status,
    wo.total_amount
FROM `work_order` AS wo
JOIN `car` ON wo.id_car = car.id_car
JOIN `client` AS c ON car.id_client = c.id_client;
