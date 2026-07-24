-- ESX:
ALTER TABLE `users`
	ADD COLUMN `jail_items` LONGTEXT NULL,
	ADD COLUMN `jail_time` BIGINT(20) NULL,
	ADD COLUMN `jail_type` VARCHAR(50) NULL,
	ADD COLUMN `jail_cell` INT(11) NULL,
	ADD COLUMN `jail_cell_items` LONGTEXT NULL
;

-- QB:
ALTER TABLE `players`
	ADD COLUMN `jail_items` LONGTEXT NULL,
	ADD COLUMN `jail_time` BIGINT(20) NULL,
	ADD COLUMN `jail_type` VARCHAR(50) NULL,
	ADD COLUMN `jail_cell` INT(11) NULL
;