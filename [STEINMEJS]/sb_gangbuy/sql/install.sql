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
