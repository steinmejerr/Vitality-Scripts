CREATE TABLE IF NOT EXISTS `player_peds` (
  `citizenid` varchar(50) NOT NULL,
  `peds` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`citizenid`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
