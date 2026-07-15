-- ESX item table used by the supplied database.
INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('diving_gear', 'Dykkerudstyr', 5, 0, 1),
('old_coin', 'Gammel mønt', 1, 0, 1),
('coral_fragment', 'Koralfund', 1, 0, 1),
('antique_watch', 'Antikt ur', 1, 0, 1),
('pearl', 'Perle', 1, 0, 1),
('sealed_case', 'Forseglet værdikasse', 2, 0, 1);

-- Hvis du bruger ox_inventory, skal de samme items også tilføjes i ox_inventory/data/items.lua.
