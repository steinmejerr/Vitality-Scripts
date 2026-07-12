CREATE TABLE IF NOT EXISTS sb_admin_player_notes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    character_identifier VARCHAR(100) NOT NULL,
    player_name VARCHAR(128) NOT NULL,
    note VARCHAR(500) NOT NULL,
    source ENUM('fivem','discord') NOT NULL,
    created_by_identifier VARCHAR(100) NULL,
    created_by_name VARCHAR(128) NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    deleted_by_identifier VARCHAR(100) NULL,
    PRIMARY KEY (id),
    INDEX idx_notes_character (character_identifier, active, created_at),
    INDEX idx_notes_active (active, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
