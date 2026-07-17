CREATE TABLE IF NOT EXISTS `sb_mining_players` (
  `identifier` varchar(80) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `level` int NOT NULL DEFAULT 1,
  `completed_missions` int NOT NULL DEFAULT 0,
  `cooldown_until` datetime DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
