CREATE TABLE IF NOT EXISTS `sb_gangbuy_gang_progress` (
    `gang_job` varchar(50) NOT NULL,
    `xp` int unsigned NOT NULL DEFAULT 0,
    `completed_missions` int unsigned NOT NULL DEFAULT 0,
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`gang_job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_progress` (
    `identifier` varchar(80) NOT NULL,
    `xp` int unsigned NOT NULL DEFAULT 0,
    `completed_missions` int unsigned NOT NULL DEFAULT 0,
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_orders` (
    `id` int unsigned NOT NULL AUTO_INCREMENT,
    `identifier` varchar(80) NOT NULL,
    `gang_job` varchar(50) NOT NULL,
    `product_id` varchar(60) NOT NULL,
    `item_name` varchar(60) NOT NULL,
    `amount` int unsigned NOT NULL DEFAULT 1,
    `price` int unsigned NOT NULL DEFAULT 0,
    `status` enum('waiting','ready','collected','expired','cancelled') NOT NULL DEFAULT 'waiting',
    `ready_at` datetime NOT NULL,
    `expires_at` datetime NOT NULL,
    `collected_at` datetime DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `idx_sb_gangbuy_orders_identifier` (`identifier`),
    KEY `idx_sb_gangbuy_orders_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_mission_history` (
    `id` int unsigned NOT NULL AUTO_INCREMENT,
    `identifier` varchar(80) NOT NULL,
    `gang_job` varchar(50) NOT NULL,
    `mission_id` varchar(60) NOT NULL,
    `xp_reward` int unsigned NOT NULL DEFAULT 0,
    `money_reward` int unsigned NOT NULL DEFAULT 0,
    `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `idx_sb_gangbuy_missions_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_gangs` (
    `job_name` varchar(50) NOT NULL,
    `label` varchar(100) NOT NULL,
    `minimum_grade` int NOT NULL DEFAULT 0,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_products` (
    `id` varchar(60) NOT NULL,
    `label` varchar(100) NOT NULL,
    `description` varchar(255) NOT NULL DEFAULT '',
    `item_name` varchar(80) NOT NULL,
    `amount` int unsigned NOT NULL DEFAULT 1,
    `price` int unsigned NOT NULL DEFAULT 0,
    `required_level` int unsigned NOT NULL DEFAULT 1,
    `required_grade` int NOT NULL DEFAULT 0,
    `delivery_min` int unsigned NOT NULL DEFAULT 1,
    `delivery_max` int unsigned NOT NULL DEFAULT 1,
    `icon` varchar(100) NOT NULL DEFAULT 'fa-solid fa-box',
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sb_gangbuy_missions` (
    `id` varchar(60) NOT NULL,
    `label` varchar(100) NOT NULL,
    `description` varchar(255) NOT NULL DEFAULT '',
    `required_level` int unsigned NOT NULL DEFAULT 1,
    `required_grade` int NOT NULL DEFAULT 0,
    `xp_reward` int unsigned NOT NULL DEFAULT 0,
    `money_reward` int unsigned NOT NULL DEFAULT 0,
    `mission_type` varchar(20) NOT NULL DEFAULT 'package',
    `required_item` varchar(80) NOT NULL DEFAULT '',
    `required_amount` int unsigned NOT NULL DEFAULT 1,
    `wait_min` int unsigned NOT NULL DEFAULT 10,
    `wait_max` int unsigned NOT NULL DEFAULT 10,
    `icon` varchar(100) NOT NULL DEFAULT 'fa-solid fa-box',
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Kør disse linjer, hvis tabellen allerede findes fra en ældre version:
ALTER TABLE `sb_gangbuy_missions`
    ADD COLUMN IF NOT EXISTS `mission_type` varchar(20) NOT NULL DEFAULT 'package' AFTER `money_reward`,
    ADD COLUMN IF NOT EXISTS `required_item` varchar(80) NOT NULL DEFAULT '' AFTER `mission_type`,
    ADD COLUMN IF NOT EXISTS `required_amount` int unsigned NOT NULL DEFAULT 1 AFTER `required_item`;
