-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.24 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for tourney
CREATE DATABASE IF NOT EXISTS `tourney` /*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `tourney`;

-- Dumping structure for table tourney.group
CREATE TABLE IF NOT EXISTS `group` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '群組 ID',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Group Name (English)',
  `th_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Group name (Thailand)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Group';

-- Dumping data for table tourney.group: ~10 rows (approximately)
DELETE FROM `group`;
/*!40000 ALTER TABLE `group` DISABLE KEYS */;
INSERT INTO `group` (`id`, `name`, `th_name`) VALUES
	(1, 'Host', 'เจ้าของ'),
	(2, 'Admin', 'แอดมิน'),
	(3, 'Referee', 'นักควบคุม'),
	(4, 'Commentator', 'นักพากย์'),
	(5, 'Steamer', 'นักเผยแพร่'),
	(6, 'Mappooler', 'นักจัดแมพ'),
	(7, 'GFX', 'นักออกแบบ'),
	(8, 'Tester', 'นักทดสอบ'),
	(9, 'Tech', 'นักพัฒนา'),
	(10, 'Staff', 'นักคุม');
/*!40000 ALTER TABLE `group` ENABLE KEYS */;

-- Dumping structure for view tourney.json_mappool
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `json_mappool` (
	`id` INT(10) NOT NULL COMMENT 'ID',
	`round_id` INT(10) NOT NULL COMMENT 'Round ID',
	`mods` VARCHAR(50) NULL COMMENT 'Use mod(s)' COLLATE 'utf8_general_ci',
	`code` VARCHAR(6) NULL COMMENT 'Photo code' COLLATE 'utf8_general_ci',
	`json` JSON NULL
) ENGINE=MyISAM;

-- Dumping structure for view tourney.json_player
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `json_player` (
	`user_id` INT(10) NOT NULL COMMENT 'OSU ID',
	`team` INT(10) NOT NULL COMMENT 'Team ID',
	`json` JSON NULL
) ENGINE=MyISAM;

-- Dumping structure for view tourney.json_round
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `json_round` (
	`id` INT(10) NOT NULL COMMENT 'Round ID',
	`pool_publish` TINYINT(3) NOT NULL COMMENT 'Whether the pool is open',
	`json` JSON NULL
) ENGINE=MyISAM;

-- Dumping structure for view tourney.json_team
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `json_team` (
	`id` INT(10) NOT NULL COMMENT 'Team ID',
	`json` JSON NULL
) ENGINE=MyISAM;

-- Dumping structure for table tourney.manager_log
CREATE TABLE IF NOT EXISTS `manager_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `log` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `from` int NOT NULL DEFAULT '0',
  `status` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `from` (`from`),
  CONSTRAINT `FROM` FOREIGN KEY (`from`) REFERENCES `staff` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table tourney.manager_log: ~1 rows (approximately)
DELETE FROM `manager_log`;
/*!40000 ALTER TABLE `manager_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `manager_log` ENABLE KEYS */;

-- Dumping structure for table tourney.mappool
CREATE TABLE IF NOT EXISTS `mappool` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `round_id` int NOT NULL COMMENT 'Round ID',
  `beatmap_id` int NOT NULL COMMENT 'Beatmaps ID',
  `code` varchar(6) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Photo code',
  `mods` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Use mod(s)',
  `info` json DEFAULT NULL COMMENT 'Mappool information',
  `note` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT '' COMMENT 'Note',
  `nominator` int DEFAULT NULL COMMENT 'Nominator',
  `add_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `round_id` (`round_id`) USING BTREE,
  KEY `Nominator` (`nominator`) USING BTREE,
  KEY `beatmap_id` (`beatmap_id`),
  CONSTRAINT `round_id` FOREIGN KEY (`round_id`) REFERENCES `round` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Mappool';

-- Dumping data for table tourney.mappool: ~10 rows (approximately)
DELETE FROM `mappool`;
/*!40000 ALTER TABLE `mappool` DISABLE KEYS */;
/*!40000 ALTER TABLE `mappool` ENABLE KEYS */;

-- Dumping structure for table tourney.map_group
CREATE TABLE IF NOT EXISTS `map_group` (
  `name` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `hex_color` char(8) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `badge_color` char(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `enabled_mods` int DEFAULT '0',
  `freemod` tinyint(1) DEFAULT '0',
  `sort` int DEFAULT NULL,
  PRIMARY KEY (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Group of the map';

-- Dumping data for table tourney.map_group: ~5 rows (approximately)
DELETE FROM `map_group`;
/*!40000 ALTER TABLE `map_group` DISABLE KEYS */;
INSERT INTO `map_group` (`name`, `hex_color`, `badge_color`, `enabled_mods`, `freemod`, `sort`) VALUES
	('HB', 'FFF2CC', 'yellow', 0, 1, 2),
	('LN', 'F4CCCC', 'red', 0, 1, 3),
	('RC', 'D9D2E9', 'azure', 0, 1, 1),
	('SV', 'FFFFFF', 'muted', 0, 1, 4),
	('TB', 'D9EAD3', 'lime', 0, 1, 5);
/*!40000 ALTER TABLE `map_group` ENABLE KEYS */;

-- Dumping structure for table tourney.match
CREATE TABLE IF NOT EXISTS `match` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `code` char(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '自訂代碼',
  `round_id` int DEFAULT NULL COMMENT 'Round ID',
  `team1` int DEFAULT NULL COMMENT 'Team 1 ID',
  `team1_score` int NOT NULL DEFAULT '0' COMMENT 'Team 1 Score',
  `team2` int DEFAULT NULL COMMENT 'Team 2 ID',
  `team2_score` int NOT NULL DEFAULT '0' COMMENT 'Team 2 Score',
  `date` datetime DEFAULT NULL COMMENT 'Game date',
  `referee` int DEFAULT NULL COMMENT 'Referee',
  `streamer` int DEFAULT NULL COMMENT 'Streamer',
  `commentator` int DEFAULT NULL COMMENT 'Commentator',
  `commentator2` int DEFAULT NULL COMMENT 'Commentator 2',
  `mp_link` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'MP Link',
  `video_link` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT 'VOD Link',
  `loser` tinyint(1) DEFAULT '0' COMMENT 'Is it a failure?',
  `stats` tinyint(1) DEFAULT '0' COMMENT 'State (0 is not starting, 1 end, 2 abandoned)',
  `m_state` tinyint(1) DEFAULT '0',
  `note` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `winto` int DEFAULT NULL,
  `losto` int DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `code` (`code`) USING BTREE,
  KEY `FK_TEAM1` (`team1`) USING BTREE,
  KEY `FK_TEAM2` (`team2`) USING BTREE,
  KEY `FK_ROUND` (`round_id`) USING BTREE,
  CONSTRAINT `FK_ROUND` FOREIGN KEY (`round_id`) REFERENCES `round` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_TEAM1` FOREIGN KEY (`team1`) REFERENCES `team` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `FK_TEAM2` FOREIGN KEY (`team2`) REFERENCES `team` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Match';

-- Dumping data for table tourney.match: ~0 rows (approximately)
DELETE FROM `match`;
/*!40000 ALTER TABLE `match` DISABLE KEYS */;
/*!40000 ALTER TABLE `match` ENABLE KEYS */;

-- Dumping structure for table tourney.match_sets
CREATE TABLE IF NOT EXISTS `match_sets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `match_id` int DEFAULT NULL,
  `score_t1` int DEFAULT NULL,
  `score_t2` int DEFAULT NULL,
  `state` int DEFAULT '0',
  `random` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_set_match_match` (`match_id`),
  CONSTRAINT `FK_set_match_match` FOREIGN KEY (`match_id`) REFERENCES `match` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table tourney.match_sets: ~0 rows (approximately)
DELETE FROM `match_sets`;
/*!40000 ALTER TABLE `match_sets` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_sets` ENABLE KEYS */;

-- Dumping structure for table tourney.match_sets_banpick
CREATE TABLE IF NOT EXISTS `match_sets_banpick` (
  `id` int NOT NULL AUTO_INCREMENT,
  `set_id` int DEFAULT NULL,
  `map_id` int DEFAULT NULL,
  `from` int DEFAULT NULL,
  `type` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `map_id` (`map_id`),
  KEY `set_id` (`set_id`) USING BTREE,
  KEY `FK_match_sets_banpick_team` (`from`),
  CONSTRAINT `FK__set_match` FOREIGN KEY (`set_id`) REFERENCES `match_sets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_match_sets_banpick_mappool` FOREIGN KEY (`map_id`) REFERENCES `mappool` (`beatmap_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_match_sets_banpick_team` FOREIGN KEY (`from`) REFERENCES `team` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table tourney.match_sets_banpick: ~0 rows (approximately)
DELETE FROM `match_sets_banpick`;
/*!40000 ALTER TABLE `match_sets_banpick` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_sets_banpick` ENABLE KEYS */;

-- Dumping structure for table tourney.match_sets_result
CREATE TABLE IF NOT EXISTS `match_sets_result` (
  `id` int NOT NULL AUTO_INCREMENT,
  `set_id` int DEFAULT NULL,
  `bm_id` int DEFAULT NULL,
  `data_t1` int DEFAULT NULL,
  `data_t2` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table tourney.match_sets_result: ~0 rows (approximately)
DELETE FROM `match_sets_result`;
/*!40000 ALTER TABLE `match_sets_result` DISABLE KEYS */;
/*!40000 ALTER TABLE `match_sets_result` ENABLE KEYS */;

-- Dumping structure for table tourney.player
CREATE TABLE IF NOT EXISTS `player` (
  `user_id` int NOT NULL COMMENT 'OSU ID',
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'OSU Username',
  `team` int NOT NULL COMMENT 'Team ID',
  `register_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'registration time',
  `info` json DEFAULT NULL COMMENT 'Player information',
  `bp1` json DEFAULT NULL COMMENT 'Player''s best results',
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is it active?',
  `leader` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is it a captain?',
  `online` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `user_id` (`user_id`) USING BTREE,
  KEY `FK1_team` (`team`) USING BTREE,
  CONSTRAINT `FK1_team` FOREIGN KEY (`team`) REFERENCES `team` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Player';

-- Dumping data for table tourney.player: ~6 rows (approximately)
DELETE FROM `player`;
/*!40000 ALTER TABLE `player` DISABLE KEYS */;
/*!40000 ALTER TABLE `player` ENABLE KEYS */;

-- Dumping structure for table tourney.round
CREATE TABLE IF NOT EXISTS `round` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Round ID',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Round name',
  `description` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Note',
  `best_of` int NOT NULL DEFAULT '9' COMMENT 'Round Base of',
  `start_date` datetime DEFAULT NULL COMMENT 'Round start time',
  `pool_publish` tinyint NOT NULL DEFAULT '0' COMMENT 'Whether the pool is open',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='round';

-- Dumping data for table tourney.round: ~2 rows (approximately)
DELETE FROM `round`;
/*!40000 ALTER TABLE `round` DISABLE KEYS */;
INSERT INTO `round` (`id`, `name`, `description`, `best_of`, `start_date`, `pool_publish`) VALUES
	(2, 'Phase I', 'man i hate this function lamo', 9, '2021-05-26 15:21:41', 0),
	(3, 'Final', 'asdasdasd', 9, '2021-05-19 12:22:35', 0);
/*!40000 ALTER TABLE `round` ENABLE KEYS */;

-- Dumping structure for table tourney.staff
CREATE TABLE IF NOT EXISTS `staff` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Staff ID',
  `user_id` int NOT NULL COMMENT 'OSU ID',
  `group_id` int NOT NULL COMMENT 'Group ID',
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'OSU Username',
  `privileges` int NOT NULL DEFAULT '1',
  `join_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `active` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `user_id` (`user_id`) USING BTREE,
  KEY `group_id` (`group_id`) USING BTREE,
  CONSTRAINT `group_id` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='staff member';

-- Dumping data for table tourney.staff: ~2 rows (approximately)
DELETE FROM `staff`;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` (`id`, `user_id`, `group_id`, `username`, `privileges`, `join_date`, `active`) VALUES
	(1, 4211179, 1, '[Hakura_San]', 1023, '2021-05-17 23:03:38', 1);
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;

-- Dumping structure for table tourney.team
CREATE TABLE IF NOT EXISTS `team` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Team ID',
  `full_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Team full name',
  `flag_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Team banner name',
  `acronym` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Team Ancronym',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '狀態',
  `points` int DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Team ';

-- Dumping data for table tourney.team: ~4 rows (approximately)
DELETE FROM `team`;
/*!40000 ALTER TABLE `team` DISABLE KEYS */;
/*!40000 ALTER TABLE `team` ENABLE KEYS */;

-- Dumping structure for table tourney.tourney
CREATE TABLE IF NOT EXISTS `tourney` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Match ID',
  `full_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Full name',
  `acronym` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Specialty',
  `register_start_date` datetime DEFAULT NULL COMMENT 'Game registration start time',
  `register_end_date` datetime DEFAULT NULL COMMENT 'Deadline for registration',
  `max_team` int NOT NULL DEFAULT '0' COMMENT 'Register the TEAM limit (0 = unlimited)',
  `room_size` int NOT NULL DEFAULT '9' COMMENT 'Preset room size',
  `team_size` int NOT NULL DEFAULT '4' COMMENT 'Preset rooms each team',
  `per_team_players_min` int NOT NULL DEFAULT '4' COMMENT 'Minimum number of people per team',
  `per_team_players_max` int NOT NULL DEFAULT '8' COMMENT 'Maximum number of people per team',
  `game_mode` int NOT NULL DEFAULT '0' COMMENT 'Preset room game mode',
  `win_condition` int NOT NULL DEFAULT '0' COMMENT 'Preset room victory conditions',
  `team_mode` int NOT NULL DEFAULT '0' COMMENT 'Preset room grouping method',
  `timer` int NOT NULL DEFAULT '90' COMMENT 'Preset room countdown',
  `live_link` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Live broadcast URL',
  `map_sort` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `1v1` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is it 1V1?',
  `rounds` varchar(50) NOT NULL DEFAULT 'start' CHARACTER SET utf8 COLLATE utf8_general_ci COMMENT 'For progression in dashboard',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Game information';

-- Dumping data for table tourney.tourney: ~1 rows (approximately)
DELETE FROM `tourney`;
/*!40000 ALTER TABLE `tourney` DISABLE KEYS */;
INSERT INTO `tourney` (`id`, `full_name`, `acronym`, `register_start_date`, `register_end_date`, `max_team`, `room_size`, `team_size`, `per_team_players_min`, `per_team_players_max`, `game_mode`, `win_condition`, `team_mode`, `timer`, `live_link`, `map_sort`, `1v1`) VALUES
	(1, 'osu!mania Thailand Pro League 2021', 'OMTHPL2021', '2019-12-01 00:00:00', '2020-01-10 23:59:59', 0, 3, 1, 1, 1, 3, 3, 0, 80, 'https://www.twitch.tv/840tourney', '', 0);
/*!40000 ALTER TABLE `tourney` ENABLE KEYS */;

-- Dumping structure for view tourney.view_mappool
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_mappool` (
	`id` INT(10) NOT NULL COMMENT 'ID',
	`round_id` INT(10) NOT NULL COMMENT 'Round ID',
	`beatmap_id` INT(10) NOT NULL COMMENT 'Beatmaps ID',
	`map_group` CHAR(10) NULL COLLATE 'utf8_general_ci',
	`badge_color` CHAR(50) NULL COLLATE 'utf8_general_ci',
	`hex_color` CHAR(8) NULL COLLATE 'utf8_general_ci',
	`code` VARCHAR(6) NULL COMMENT 'Photo code' COLLATE 'utf8_general_ci',
	`mods` VARCHAR(50) NULL COMMENT 'Use mod(s)' COLLATE 'utf8_general_ci',
	`info` JSON NULL COMMENT 'Mappool information',
	`note` VARCHAR(50) NULL COMMENT 'Note' COLLATE 'utf8_general_ci',
	`add_date` DATETIME NOT NULL,
	`nominator_id` INT(10) NULL COMMENT 'Staff ID',
	`nominator_uid` INT(10) NULL COMMENT 'OSU ID',
	`nominator_gid` INT(10) NULL COMMENT 'Group ID',
	`nominator_name` VARCHAR(16) NULL COMMENT 'OSU Username' COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view tourney.view_staff
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_staff` (
	`id` INT(10) NOT NULL COMMENT 'Staff ID',
	`user_id` INT(10) NOT NULL COMMENT 'OSU ID',
	`group_id` INT(10) NOT NULL COMMENT 'Group ID',
	`username` VARCHAR(16) NOT NULL COMMENT 'OSU Username' COLLATE 'utf8_general_ci',
	`privileges` INT(10) NOT NULL,
	`join_date` DATETIME NOT NULL,
	`active` TINYINT(3) NOT NULL,
	`group_name` VARCHAR(50) NULL COMMENT 'Group Name (English)' COLLATE 'utf8_general_ci',
	`group_thname` VARCHAR(50) NULL COMMENT 'Group name (Thailand)' COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view tourney.json_mappool
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `json_mappool`;
CREATE ALGORITHM=TEMPTABLE SQL SECURITY DEFINER VIEW `json_mappool` AS select `m`.`id` AS `id`,`m`.`round_id` AS `round_id`,`m`.`mods` AS `mods`,`m`.`code` AS `code`,json_object('id',`m`.`id`,'beatmap_id',`m`.`beatmap_id`,'round_id',`m`.`round_id`,'mods',`m`.`mods`,'code',`m`.`code`,'enabled_mods',`g`.`enabled_mods`,'freemod',(`g`.`freemod` = true),'info',`m`.`info`,'nominator',json_object('id',`s`.`id`,'user_id',`s`.`user_id`,'username',`s`.`username`,'group',json_object('id',`s`.`group_id`,'name',`s`.`group_name`,'th_name',`s`.`group_thname`)),'add_date',`m`.`add_date`,'note',`m`.`note`,'colour',json_object('hex',`g`.`hex_color`,'badge',`g`.`badge_color`)) AS `json` from ((`mappool` `m` left join `view_staff` `s` on((`s`.`id` = `m`.`nominator`))) left join `map_group` `g` on((`g`.`name` = `m`.`mods`))) order by `m`.`mods`,`m`.`code`;

-- Dumping structure for view tourney.json_player
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `json_player`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `json_player` AS select `player`.`user_id` AS `user_id`,`player`.`team` AS `team`,json_object('user_id',`player`.`user_id`,'username',`player`.`username`,'team',`player`.`team`,'register_date',`player`.`register_date`,'info',`player`.`info`,'bp1',`player`.`bp1`,'active',`player`.`active`,'leader',`player`.`leader`) AS `json` from `player`;

-- Dumping structure for view tourney.json_round
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `json_round`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `json_round` AS select `r`.`id` AS `id`,`r`.`pool_publish` AS `pool_publish`,json_object('id',`r`.`id`,'name',`r`.`name`,'description',`r`.`description`,'best_of',`r`.`best_of`,'start_date',`r`.`start_date`,'pool_publish',`r`.`pool_publish`,'mappool',json_arrayagg(json_object('id',`m`.`id`,'beatmap_id',`m`.`beatmap_id`,'round_id',`m`.`round_id`,'group',`m`.`mods`,'code',`m`.`code`,'enabled_mods',`g`.`enabled_mods`,'freemod',(`g`.`freemod` = true),'info',`m`.`info`,'nominator',json_object('id',`s`.`id`,'user_id',`s`.`user_id`,'username',`s`.`username`,'group',json_object('id',`s`.`group_id`,'name',`s`.`group_name`,'th_name',`s`.`group_thname`)),'add_date',`m`.`add_date`,'note',`m`.`note`,'colour',json_object('hex',`g`.`hex_color`,'badge',`g`.`badge_color`)))) AS `json` from (((`round` `r` left join `mappool` `m` on((`m`.`round_id` = `r`.`id`))) left join `view_staff` `s` on((`s`.`id` = `m`.`nominator`))) left join `map_group` `g` on((`g`.`name` = `m`.`mods`))) group by `r`.`id`;

-- Dumping structure for view tourney.json_team
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `json_team`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `json_team` AS select `t`.`id` AS `id`,json_object('id',`t`.`id`,'full_name',`t`.`full_name`,'acronym',`t`.`acronym`,'flag_name',`t`.`flag_name`,'players',`p`.`players`,'status',`t`.`status`) AS `json` from (`team` `t` left join (select `json_player`.`team` AS `id`,json_arrayagg(`json_player`.`json`) AS `players` from `json_player` group by `json_player`.`team`) `p` on((`p`.`id` = `t`.`id`)));

-- Dumping structure for view tourney.view_mappool
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_mappool`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_mappool` AS select `mappool`.`id` AS `id`,`mappool`.`round_id` AS `round_id`,`mappool`.`beatmap_id` AS `beatmap_id`,`map_group`.`name` AS `map_group`,`map_group`.`badge_color` AS `badge_color`,`map_group`.`hex_color` AS `hex_color`,`mappool`.`code` AS `code`,`mappool`.`mods` AS `mods`,`mappool`.`info` AS `info`,`mappool`.`note` AS `note`,`mappool`.`add_date` AS `add_date`,`view_staff`.`id` AS `nominator_id`,`view_staff`.`user_id` AS `nominator_uid`,`view_staff`.`group_id` AS `nominator_gid`,`view_staff`.`username` AS `nominator_name` from ((`mappool` left join `view_staff` on((`view_staff`.`id` = `mappool`.`nominator`))) left join `map_group` on((`map_group`.`name` = `mappool`.`mods`)));

-- Dumping structure for view tourney.view_staff
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_staff`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_staff` AS select `s`.`id` AS `id`,`s`.`user_id` AS `user_id`,`s`.`group_id` AS `group_id`,`s`.`username` AS `username`,`s`.`privileges` AS `privileges`,`s`.`join_date` AS `join_date`,`s`.`active` AS `active`,`g`.`name` AS `group_name`,`g`.`th_name` AS `group_thname` from (`staff` `s` left join `group` `g` on((`g`.`id` = `s`.`group_id`)));

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
