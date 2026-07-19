CREATE TABLE IF NOT EXISTS `sb_illegalruns_cooldowns` (
    `identifier` VARCHAR(80) NOT NULL,
    `expires_at` BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
