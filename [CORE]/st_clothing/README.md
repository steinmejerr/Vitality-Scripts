# st_clothing

Complete clothing/appearance script for FiveM with support for ESX and QBCore.

## Requirements

Make sure these resources are installed:

- `oxmysql`
- `st_libs`
- `es_extended` **or** `qb-core`

Additional requirements:

- Server artifact matching `/server:6231` or newer
- `onesync` enabled

## Installation

1. Place the resource in your server resources folder as:
   - `resources/[st_scripts]/st_clothing`
2. Ensure dependencies exist and start before `st_clothing`.
3. Create the SQL tables manually in your database (see next section).
4. Adjust configuration in `config.lua` as needed.
5. Add the resource to your `server.cfg`.

Example start order in `server.cfg`:

```cfg
ensure oxmysql
ensure st_libs
ensure es_extended   # or qb-core
ensure st_clothing
```

## SQL (Create Manually)

Run these statements manually in your database.

### 1) playerskins

```sql
CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `model` varchar(255) NOT NULL,
  `skin` text NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
```

### 2) player_outfits

```sql
CREATE TABLE IF NOT EXISTS `player_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `outfitname` varchar(50) NOT NULL DEFAULT '0',
  `model` varchar(50) DEFAULT NULL,
  `props` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]' CHECK (json_valid(`props`)),
  `components` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]' CHECK (json_valid(`components`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid_outfitname_model` (`citizenid`,`outfitname`,`model`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### 3) player_outfit_codes

```sql
CREATE TABLE IF NOT EXISTS `player_outfit_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `outfitid` int(11) NOT NULL,
  `code` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `FK_player_outfit_codes_player_outfits` (`outfitid`),
  CONSTRAINT `fk_outfitid` FOREIGN KEY (`outfitid`) REFERENCES `player_outfits` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### 4) player_peds

```sql
CREATE TABLE IF NOT EXISTS `player_peds` (
  `citizenid` varchar(50) NOT NULL,
  `peds` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`citizenid`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

## Important Configuration

In `config.lua`, review at least these settings:

- `Config.Command` (default: `clothing`)
- `Config.CommandWardrobe`
- `Config.OnlyEnableCommandNearStore`
- `Config.UseNearestStore`
- `Config.HasPrices`
- `Config.PaymentType` (example: `bank`)
- `Config.AdminGroup` (admin rank)
- `Config.CdnUrl`
- `Config.Stores` (stores, blips, and coordinates)
- `Config.TattooShops` and `Config.TattooSettings`

## NEW!! CDN Setup

Use this if you want clothing images to load from a CDN instead of your game server files.

1. Upload your image folders to a CDN/web host.
2. Set `Config.CdnUrl` in `config.lua` to your CDN base URL.
3. Keep the same folder structure and file names as expected by the script.

Example:

```lua
Config.CdnUrl = "https://cdn.yourdomain.com/st_clothing"
```

Notes:

- Keep `Config.CdnUrl = "false"` to disable CDN usage.
- Do not add a broken URL or private URL, otherwise images will fail to load.
- After changing CDN URL, restart the resource.

## Compatibility

The script auto-detects framework:

- ESX if `es_extended` exists
- QBCore if `qb-core` exists

## Troubleshooting

If the script does not start correctly:

1. Check that `oxmysql` and `st_libs` start before `st_clothing`.
2. Check that SQL tables are created in the correct database.
3. Check that `onesync` is enabled.
4. Check server console for errors from `st_clothing` or missing dependencies.

## Notes

- The script includes `provide` compatibility for `illenium-appearance`, `esx_skin`, and `skinchanger`.
- `config.lua` and `lang.lua` are listed in `escrow_ignore`.
