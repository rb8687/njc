-- =============================================================================
-- NJC xprp – MySQL Database Schema
-- Run this script once against your MySQL database before starting the server.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `njc_xprp`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `njc_xprp`;

-- ── Accounts ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `xprp_accounts` (
    `id`         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `license`    VARCHAR(64)     NOT NULL,
    `created_at` DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Characters ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `xprp_characters` (
    `id`             INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `account_id`     INT UNSIGNED    NOT NULL,
    `firstname`      VARCHAR(64)     NOT NULL,
    `lastname`       VARCHAR(64)     NOT NULL,
    `dob`            DATE            NOT NULL,
    `gender`         ENUM('male','female') NOT NULL DEFAULT 'male',
    `cash`           INT UNSIGNED    NOT NULL DEFAULT 500,
    `bank`           INT UNSIGNED    NOT NULL DEFAULT 2500,
    `job`            VARCHAR(64)     NOT NULL DEFAULT 'unemployed',
    `job_grade`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
    -- XP earned through play time and clean gameplay
    `xp`             INT UNSIGNED    NOT NULL DEFAULT 0,
    -- Total seconds this character has been connected and loaded
    `playtime_secs`  INT UNSIGNED    NOT NULL DEFAULT 0,
    `created_at`     DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    KEY `fk_char_account` (`account_id`),
    CONSTRAINT `fk_char_account`
        FOREIGN KEY (`account_id`) REFERENCES `xprp_accounts` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Inventory ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `xprp_inventory` (
    `id`      INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `char_id` INT UNSIGNED    NOT NULL,
    `item`    VARCHAR(64)     NOT NULL,
    `amount`  INT UNSIGNED    NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_char_item` (`char_id`, `item`),
    CONSTRAINT `fk_inv_char`
        FOREIGN KEY (`char_id`) REFERENCES `xprp_characters` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
