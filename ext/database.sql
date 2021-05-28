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

-- Dumping structure for table tourney.game
CREATE TABLE IF NOT EXISTS `game` (
  `id` int NOT NULL AUTO_INCREMENT,
  `match_id` int NOT NULL,
  `map` int NOT NULL,
  `team1_score` int NOT NULL,
  `team2_score` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `match` (`match_id`) USING BTREE,
  KEY `map` (`map`) USING BTREE,
  CONSTRAINT `map` FOREIGN KEY (`map`) REFERENCES `mappool` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `match` FOREIGN KEY (`match_id`) REFERENCES `match` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- Dumping data for table tourney.game: ~0 rows (approximately)
DELETE FROM `game`;
/*!40000 ALTER TABLE `game` DISABLE KEYS */;
/*!40000 ALTER TABLE `game` ENABLE KEYS */;

-- Dumping structure for table tourney.group
CREATE TABLE IF NOT EXISTS `group` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '群組 ID',
  `name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Group Name (English)',
  `th_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Group name (Thailand)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Group';

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
	`round_id` INT(10) NOT NULL COMMENT 'Stage ID',
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
  `log` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0',
  `from` int NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table tourney.manager_log: ~0 rows (approximately)
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
  CONSTRAINT `round_id` FOREIGN KEY (`round_id`) REFERENCES `round` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Mappool';

-- Dumping data for table tourney.mappool: ~7 rows (approximately)
DELETE FROM `mappool`;
/*!40000 ALTER TABLE `mappool` DISABLE KEYS */;
INSERT INTO `mappool` (`id`, `round_id`, `beatmap_id`, `code`, `mods`, `info`, `note`, `nominator`, `add_date`) VALUES
	(1, 1, 2073859, '1', 'HD', '{"bpm": 124, "mode": 0, "tags": "lu^3 mapping cup 2019 lmc 2019", "packs": null, "title": "Libella Swing", "video": 0, "artist": "Parov Stelar", "rating": 0, "source": "", "creator": "Taeyang", "version": "Extra", "approved": -2, "diff_aim": 2.73824, "file_md5": "00de90eb826403d3fb31dcfb9635a39c", "genre_id": 1, "diff_size": 3.5, "max_combo": 1547, "passcount": 9, "playcount": 65, "beatmap_id": 2073859, "creator_id": 2732340, "diff_drain": 5.2, "diff_speed": 2.48492, "hit_length": 206, "storyboard": 0, "language_id": 1, "last_update": "2019-06-22 13:42:24", "submit_date": "2019-06-22 13:41:51", "count_normal": 384, "count_slider": 521, "diff_overall": 8.2, "total_length": 206, "approved_date": null, "beatmapset_id": 991657, "count_spinner": 0, "diff_approach": 9.5, "title_unicode": "Libella Swing", "artist_unicode": "Parov Stelar", "favourite_count": 4, "difficultyrating": 5.34982, "audio_unavailable": 0, "download_unavailable": 0}', '', 1, '2021-01-24 04:26:23'),
	(3, 1, 1061200, '3', 'FM', '{"bpm": 152, "mode": 0, "tags": "tantei opera milky holmes dai 2 maku ending ed remix eurobeat cobalt green", "packs": "S775", "title": "Lovely Girls Anthem -EuroBeatRemix-", "video": 0, "artist": "Aso Natsuko", "rating": 9.25446, "source": "探偵オペラ ミルキィホームズ 第2幕", "creator": "Aeril", "version": "Extra", "approved": 1, "diff_aim": 2.65866, "file_md5": "47bc0060418e745470fed9156c52401a", "genre_id": 3, "diff_size": 4.2, "max_combo": 1503, "passcount": 3159, "playcount": 35856, "beatmap_id": 1061200, "creator_id": 4334976, "diff_drain": 6.5, "diff_speed": 2.62426, "hit_length": 216, "storyboard": 0, "language_id": 3, "last_update": "2019-05-21 19:34:43", "submit_date": "2016-08-20 21:43:13", "count_normal": 654, "count_slider": 411, "diff_overall": 9, "total_length": 247, "approved_date": "2019-05-22 19:40:02", "beatmapset_id": 498505, "count_spinner": 6, "diff_approach": 9.1, "title_unicode": "Lovely Girls Anthem -EuroBeatRemix-", "artist_unicode": "麻生夏子", "favourite_count": 102, "difficultyrating": 5.30012, "audio_unavailable": 0, "download_unavailable": 0}', 'man', 1, '2021-01-24 04:26:23'),
	(4, 1, 1551262, '4', 'FM', '{"bpm": 112, "mode": 0, "tags": "claris presents welcome new galaxy groove \\t俺の妹がこんなに可愛いわけがない ore no imouto ga konna ni kawaii wake ga nai oreimo kokoro no inryoku ココロの引力", "packs": "S765", "title": "anime no mizo 420", "video": 0, "artist": "android52", "rating": 8.77181, "source": "", "creator": "pishifat", "version": "Extra", "approved": 1, "diff_aim": 2.30694, "file_md5": "735f97f8885a3f1d76c8cfd15ea57960", "genre_id": 10, "diff_size": 2, "max_combo": 519, "passcount": 1197, "playcount": 25245, "beatmap_id": 1551262, "creator_id": 3178418, "diff_drain": 6, "diff_speed": 1.73216, "hit_length": 123, "storyboard": 0, "language_id": 3, "last_update": "2019-03-02 07:23:07", "submit_date": "2018-02-14 07:33:35", "count_normal": 187, "count_slider": 152, "diff_overall": 7, "total_length": 138, "approved_date": "2019-04-26 16:20:09", "beatmapset_id": 734780, "count_spinner": 3, "diff_approach": 7, "title_unicode": "アニメの溝420", "artist_unicode": "android52", "favourite_count": 56, "difficultyrating": 4.32649, "audio_unavailable": 0, "download_unavailable": 0}', '', 1, '2021-01-24 04:26:23'),
	(5, 1, 1739583, '5', 'FM', '{"bpm": 140, "mode": 0, "tags": "chinese anime aotu world 七创社 7doc 杨秉音 樱谙 asuka_- angelsnow present ayyri eiri-", "packs": "S757", "title": "Zi You Sheng Guang", "video": 0, "artist": "Wang Yi Tao", "rating": 8.26316, "source": "凹凸世界", "creator": "Ryuusei Aika", "version": "Zero Vector", "approved": 1, "diff_aim": 2.51891, "file_md5": "00010f0eb02ee131aacac54bf72d5444", "genre_id": 3, "diff_size": 5, "max_combo": 939, "passcount": 3474, "playcount": 30384, "beatmap_id": 1739583, "creator_id": 7777875, "diff_drain": 5, "diff_speed": 2.44353, "hit_length": 215, "storyboard": 0, "language_id": 4, "last_update": "2019-03-26 15:42:07", "submit_date": "2018-08-11 11:49:32", "count_normal": 939, "count_slider": 0, "diff_overall": 8, "total_length": 221, "approved_date": "2019-04-02 17:20:03", "beatmapset_id": 830266, "count_spinner": 0, "diff_approach": 8, "title_unicode": "自由圣光", "artist_unicode": "王艺陶", "favourite_count": 61, "difficultyrating": 5.00013, "audio_unavailable": 0, "download_unavailable": 0}', '', 1, '2021-01-24 04:26:23'),
	(6, 1, 2267539, '1', 'HD', '{"bpm": 191, "mode": 0, "tags": "fixxis amity impurepug -xenon xen xehn agatsu divine gate anime japanese rock j-rock wowaka shinoda シノダ igarashi イガラシ yumao ゆーまお kowari", "packs": "S866", "title": "One Me Two Hearts", "video": 0, "artist": "hitorie", "rating": 9.34389, "source": "ディバインゲート", "creator": "Black Man", "version": "Expert", "approved": 1, "diff_aim": 2.74297, "file_md5": "487a64c16daf589ded1b6d0b697bc87b", "genre_id": 3, "diff_size": 4, "max_combo": 1296, "passcount": 3627, "playcount": 48366, "beatmap_id": 2267539, "creator_id": 4673089, "diff_drain": 6.5, "diff_speed": 2.65495, "hit_length": 199, "storyboard": 0, "language_id": 3, "last_update": "2020-02-15 04:21:14", "submit_date": "2019-12-26 18:18:08", "count_normal": 667, "count_slider": 298, "diff_overall": 8.5, "total_length": 200, "approved_date": "2020-02-22 07:27:18", "beatmapset_id": 1084284, "count_spinner": 0, "diff_approach": 9.2, "title_unicode": "ワンミーツハー", "artist_unicode": "ヒトリエ", "favourite_count": 147, "difficultyrating": 5.44193, "audio_unavailable": 0, "download_unavailable": 0}', '', 1, '2021-01-24 04:26:23'),
	(7, 1, 50354, '2', 'DT', '{"bpm": 175, "mode": 0, "tags": "sikieiki siki eiki shiki kaeidzuka phantasmagoria of flower view", "packs": "R26,S109", "title": "Danzai Yamaxanadu", "video": 0, "artist": "IOSYS", "rating": 9.45522, "source": "Touhou", "creator": "Zekira", "version": "Eternal Damnation", "approved": 2, "diff_aim": 2.35852, "file_md5": "3bf8f09b2255710a7638618949abb1c5", "genre_id": 2, "diff_size": 5, "max_combo": 1000, "passcount": 84839, "playcount": 719577, "beatmap_id": 50354, "creator_id": 36749, "diff_drain": 5, "diff_speed": 2.69785, "hit_length": 200, "storyboard": 1, "language_id": 3, "last_update": "2010-05-05 02:42:54", "submit_date": "2010-03-05 13:35:21", "count_normal": 693, "count_slider": 104, "diff_overall": 8, "total_length": 220, "approved_date": "2010-05-05 03:22:51", "beatmapset_id": 13654, "count_spinner": 4, "diff_approach": 8, "title_unicode": null, "artist_unicode": null, "favourite_count": 1042, "difficultyrating": 5.22603, "audio_unavailable": 0, "download_unavailable": 0}', '', 1, '2021-01-24 04:26:23');
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

-- Dumping data for table tourney.map_group: ~9 rows (approximately)
DELETE FROM `map_group`;
/*!40000 ALTER TABLE `map_group` DISABLE KEYS */;
INSERT INTO `map_group` (`name`, `hex_color`, `badge_color`, `enabled_mods`, `freemod`, `sort`) VALUES
	('DT', 'C9DAF8', 'purple', 65, 0, 5),
	('EZ', 'AEEDC9', 'green', 3, 0, 6),
	('FL', '828282', 'dark', 1025, 0, 7),
	('FM', 'D9D2E9', 'azure', 0, 1, 1),
	('HD', 'FFF2CC', 'yellow', 9, 0, 2),
	('HR', 'F4CCCC', 'red', 17, 0, 3),
	('NM', 'FFFFFF', 'muted', 1, 0, 4),
	('Roll', 'E8AEED', 'dark-lt', 0, 1, 8),
	('TB', 'D9EAD3', 'lime', 0, 1, 9);
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
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Match';

-- Dumping data for table tourney.match: ~0 rows (approximately)
DELETE FROM `match`;
/*!40000 ALTER TABLE `match` DISABLE KEYS */;
/*!40000 ALTER TABLE `match` ENABLE KEYS */;

-- Dumping structure for table tourney.player
CREATE TABLE IF NOT EXISTS `player` (
  `user_id` int NOT NULL COMMENT 'OSU ID',
  `username` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'OSU Username',
  `team` int NOT NULL COMMENT 'Team ID',
  `register_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'registration time',
  `info` json DEFAULT NULL COMMENT 'Player information',
  `bp1` json DEFAULT NULL COMMENT "Player's best results",
  `active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is it active?',
  `leader` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is it a captain?',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `user_id` (`user_id`) USING BTREE,
  KEY `FK1_team` (`team`) USING BTREE,
  CONSTRAINT `FK1_team` FOREIGN KEY (`team`) REFERENCES `team` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Player';

-- Dumping data for table tourney.player: ~26 rows (approximately)
DELETE FROM `player`;
/*!40000 ALTER TABLE `player` DISABLE KEYS */;
INSERT INTO `player` (`user_id`, `username`, `team`, `register_date`, `info`, `bp1`, `active`, `leader`) VALUES
	(654296, 'Bitcoin', 2, '2021-01-15 02:17:22', '{"level": 101.044, "pp_raw": 8187.21, "count50": 81905, "country": "TW", "pp_rank": 4368, "user_id": 654296, "accuracy": 98.5335464477539, "count100": 896120, "count300": 12503192, "username": "Bitcoin", "join_date": "2011-01-21 02:50:27", "playcount": 50878, "total_score": 131352923382, "count_rank_a": 848, "count_rank_s": 893, "ranked_score": 30479220582, "count_rank_sh": 1063, "count_rank_ss": 114, "count_rank_ssh": 73, "pp_country_rank": 72, "total_seconds_played": 2959327}', '{"pp": 492.174, "date": "2019-03-24 03:36:55", "rank": "B", "score": 31262182, "count50": 13, "perfect": 0, "user_id": 654296, "count100": 97, "count300": 881, "maxcombo": 1324, "score_id": 2765645759, "countgeki": 163, "countkatu": 31, "countmiss": 3, "beatmap_id": 1945175, "enabled_mods": 584, "replay_available": 1}', 1, 1),
	(1593180, 'XzCraftP', 20, '2021-01-15 02:17:43', '{"level": 100.431, "pp_raw": 8398.57, "count50": 50840, "country": "TW", "pp_rank": 4243, "user_id": 1593180, "accuracy": 99.0665054321289, "count100": 396248, "count300": 5569959, "username": "XzCraftP", "join_date": "2012-05-11 10:50:34", "playcount": 20312, "total_score": 70045589828, "count_rank_a": 1137, "count_rank_s": 597, "ranked_score": 32879723907, "count_rank_sh": 300, "count_rank_ss": 54, "count_rank_ssh": 46, "pp_country_rank": 63, "total_seconds_played": 1493743}', '{"pp": 518.912, "date": "2019-09-19 15:46:26", "rank": "A", "score": 126725030, "count50": 1, "perfect": 0, "user_id": 1593180, "count100": 37, "count300": 1934, "maxcombo": 2242, "score_id": 2897534935, "countgeki": 214, "countkatu": 15, "countmiss": 1, "beatmap_id": 658127, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(1786610, 'Naze Meiyue', 18, '2021-01-15 02:17:41', '{"level": 102.587, "pp_raw": 8004.52, "count50": 215712, "country": "TW", "pp_rank": 4963, "user_id": 1786610, "accuracy": 99.05582427978516, "count100": 1791046, "count300": 26200362, "username": "Naze Meiyue", "join_date": "2012-07-26 07:53:04", "playcount": 151047, "total_score": 285673729778, "count_rank_a": 2370, "count_rank_s": 1945, "ranked_score": 63803780142, "count_rank_sh": 236, "count_rank_ss": 219, "count_rank_ssh": 34, "pp_country_rank": 89, "total_seconds_played": 7071584}', '{"pp": 415.247, "date": "2020-01-01 15:12:53", "rank": "A", "score": 59985190, "count50": 0, "perfect": 0, "user_id": 1786610, "count100": 42, "count300": 1154, "maxcombo": 1787, "score_id": 2972494997, "countgeki": 307, "countkatu": 28, "countmiss": 1, "beatmap_id": 1583228, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(1860489, '_Shield', 11, '2021-01-15 02:17:31', '{"level": 104.455, "pp_raw": 12507.5, "count50": 68971, "country": "TW", "pp_rank": 254, "user_id": 1860489, "accuracy": 99.08057403564452, "count100": 942443, "count300": 28177552, "username": "_Shield", "join_date": "2012-08-21 15:10:18", "playcount": 116427, "total_score": 472480882978, "count_rank_a": 1780, "count_rank_s": 2324, "ranked_score": 106048446366, "count_rank_sh": 119, "count_rank_ss": 351, "count_rank_ssh": 15, "pp_country_rank": 6, "total_seconds_played": 6173490}', '{"pp": 742.292, "date": "2020-10-03 17:24:05", "rank": "S", "score": 187403050, "count50": 0, "perfect": 1, "user_id": 1860489, "count100": 43, "count300": 2273, "maxcombo": 2741, "score_id": 3265654159, "countgeki": 361, "countkatu": 27, "countmiss": 0, "beatmap_id": 2079597, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(2165650, 'mcy4', 22, '2021-01-15 02:17:45', '{"level": 102.923, "pp_raw": 15065.4, "count50": 488859, "country": "HK", "pp_rank": 39, "user_id": 2165650, "accuracy": 98.57315063476562, "count100": 4065898, "count300": 40866893, "username": "mcy4", "join_date": "2012-12-08 08:33:38", "playcount": 208934, "total_score": 319205326003, "count_rank_a": 1690, "count_rank_s": 575, "ranked_score": 39820280865, "count_rank_sh": 560, "count_rank_ss": 12, "count_rank_ssh": 14, "pp_country_rank": 2, "total_seconds_played": 9724688}', '{"pp": 867.191, "date": "2020-10-14 14:27:58", "rank": "A", "score": 40878591, "count50": 0, "perfect": 0, "user_id": 2165650, "count100": 13, "count300": 909, "maxcombo": 1243, "score_id": 3278943063, "countgeki": 236, "countkatu": 9, "countmiss": 2, "beatmap_id": 1778560, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(2200982, 'Muji', 6, '2021-01-15 02:17:25', '{"level": 100.188, "pp_raw": 10368.4, "count50": 48392, "country": "HK", "pp_rank": 1006, "user_id": 2200982, "accuracy": 97.6399917602539, "count100": 462554, "count300": 5159992, "username": "Muji", "join_date": "2012-12-21 08:18:30", "playcount": 32005, "total_score": 45758627674, "count_rank_a": 498, "count_rank_s": 226, "ranked_score": 11817957981, "count_rank_sh": 160, "count_rank_ss": 33, "count_rank_ssh": 19, "pp_country_rank": 22, "total_seconds_played": 1339046}', '{"pp": 605.812, "date": "2020-10-15 09:50:44", "rank": "A", "score": 1529014, "count50": 0, "perfect": 0, "user_id": 2200982, "count100": 21, "count300": 181, "maxcombo": 265, "score_id": 3279951206, "countgeki": 50, "countkatu": 15, "countmiss": 0, "beatmap_id": 2338610, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(2472609, 'Imokora', 3, '2021-01-15 02:17:23', '{"level": 100.673, "pp_raw": 9183.2, "count50": 88414, "country": "TW", "pp_rank": 2531, "user_id": 2472609, "accuracy": 98.94832611083984, "count100": 725456, "count300": 10689209, "username": "Imokora", "join_date": "2013-03-24 12:00:26", "playcount": 40977, "total_score": 94232731299, "count_rank_a": 1555, "count_rank_s": 755, "ranked_score": 27267063326, "count_rank_sh": 298, "count_rank_ss": 149, "count_rank_ssh": 110, "pp_country_rank": 38, "total_seconds_played": 2790461}', '{"pp": 567.919, "date": "2019-06-29 12:57:30", "rank": "S", "score": 133665590, "count50": 0, "perfect": 0, "user_id": 2472609, "count100": 32, "count300": 1780, "maxcombo": 2423, "score_id": 2840299012, "countgeki": 221, "countkatu": 15, "countmiss": 0, "beatmap_id": 1537566, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(2529213, 'SugiuraAyano', 21, '2021-01-15 02:17:44', '{"level": 100.876, "pp_raw": 7407.4, "count50": 72065, "country": "TW", "pp_rank": 7652, "user_id": 2529213, "accuracy": 99.1696319580078, "count100": 789914, "count300": 11655342, "username": "SugiuraAyano", "join_date": "2013-04-10 07:43:05", "playcount": 42829, "total_score": 114572531149, "count_rank_a": 2246, "count_rank_s": 1030, "ranked_score": 41459505390, "count_rank_sh": 621, "count_rank_ss": 47, "count_rank_ssh": 50, "pp_country_rank": 150, "total_seconds_played": 3075188}', '{"pp": 390.251, "date": "2019-12-14 06:25:20", "rank": "SH", "score": 31599079, "count50": 1, "perfect": 1, "user_id": 2529213, "count100": 9, "count300": 854, "maxcombo": 1259, "score_id": 2958666414, "countgeki": 154, "countkatu": 7, "countmiss": 0, "beatmap_id": 2188430, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(2808144, 'Music Lord', 8, '2021-01-15 02:17:28', '{"level": 101.491, "pp_raw": 8128.27, "count50": 161397, "country": "TW", "pp_rank": 4934, "user_id": 2808144, "accuracy": 98.47891235351562, "count100": 1842477, "count300": 19227786, "username": "Music Lord", "join_date": "2013-06-15 03:16:06", "playcount": 97271, "total_score": 176067410749, "count_rank_a": 2521, "count_rank_s": 292, "ranked_score": 49164370443, "count_rank_sh": 1825, "count_rank_ss": 9, "count_rank_ssh": 93, "pp_country_rank": 80, "total_seconds_played": 5103897}', '{"pp": 454.36, "date": "2019-09-25 12:08:19", "rank": "A", "score": 26123631, "count50": 1, "perfect": 0, "user_id": 2808144, "count100": 5, "count300": 840, "maxcombo": 1129, "score_id": 2901642155, "countgeki": 184, "countkatu": 5, "countmiss": 1, "beatmap_id": 574471, "enabled_mods": 72, "replay_available": 0}', 1, 0),
	(3066316, '[ MILK_Jiang]', 19, '2021-01-15 02:17:42', '{"level": 101.979, "pp_raw": 7378.27, "count50": 135706, "country": "TW", "pp_rank": 7854, "user_id": 3066316, "accuracy": 99.3375473022461, "count100": 1303419, "count300": 20739969, "username": "[ MILK_Jiang]", "join_date": "2013-08-04 02:41:30", "playcount": 80279, "total_score": 224861119801, "count_rank_a": 1495, "count_rank_s": 1089, "ranked_score": 40899483109, "count_rank_sh": 176, "count_rank_ss": 106, "count_rank_ssh": 26, "pp_country_rank": 155, "total_seconds_played": 4353586}', '{"pp": 389.145, "date": "2016-04-03 12:42:23", "rank": "SH", "score": 70741534, "count50": 0, "perfect": 0, "user_id": 3066316, "count100": 11, "count300": 1212, "maxcombo": 1737, "score_id": 2091603501, "countgeki": 308, "countkatu": 11, "countmiss": 0, "beatmap_id": 827803, "enabled_mods": 8, "replay_available": 1}', 1, 0),
	(3163649, 'GfMRT', 16, '2021-01-15 02:17:39', '{"level": 105.823, "pp_raw": 12348.7, "count50": 148437, "country": "TW", "pp_rank": 285, "user_id": 3163649, "accuracy": 99.09882354736328, "count100": 1720189, "count300": 36360084, "username": "GfMRT", "join_date": "2013-08-21 13:15:25", "playcount": 128104, "total_score": 609260190284, "count_rank_a": 948, "count_rank_s": 851, "ranked_score": 145321037859, "count_rank_sh": 4770, "count_rank_ss": 172, "count_rank_ssh": 801, "pp_country_rank": 7, "total_seconds_played": 8228788}', '{"pp": 655.787, "date": "2020-05-06 13:34:23", "rank": "SH", "score": 864708, "count50": 0, "perfect": 1, "user_id": 3163649, "count100": 3, "count300": 135, "maxcombo": 173, "score_id": 3077136058, "countgeki": 43, "countkatu": 3, "countmiss": 0, "beatmap_id": 1992711, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(3366658, 'MiyazonoKuma', 13, '2021-01-15 02:17:34', '{"level": 100.589, "pp_raw": 9035.97, "count50": 157854, "country": "TW", "pp_rank": 2450, "user_id": 3366658, "accuracy": 98.17486572265624, "count100": 1326694, "count300": 11443387, "username": "MiyazonoKuma", "join_date": "2013-10-01 10:28:03", "playcount": 67520, "total_score": 85792604412, "count_rank_a": 776, "count_rank_s": 166, "ranked_score": 19726324095, "count_rank_sh": 690, "count_rank_ss": 23, "count_rank_ssh": 80, "pp_country_rank": 42, "total_seconds_played": 3281271}', '{"pp": 535.755, "date": "2019-09-22 13:03:46", "rank": "XH", "score": 591005, "count50": 0, "perfect": 1, "user_id": 3366658, "count100": 0, "count300": 123, "maxcombo": 166, "score_id": 2899742728, "countgeki": 24, "countkatu": 0, "countmiss": 0, "beatmap_id": 2150733, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(3416783, '_kyuu', 5, '2021-01-15 02:17:25', '{"level": 100.92, "pp_raw": 5737.74, "count50": 49944, "country": "TW", "pp_rank": 28376, "user_id": 3416783, "accuracy": 99.33747863769533, "count100": 697794, "count300": 12078952, "username": "_kyuu", "join_date": "2013-10-12 10:19:14", "playcount": 46151, "total_score": 118945512963, "count_rank_a": 2878, "count_rank_s": 941, "ranked_score": 40365830109, "count_rank_sh": 517, "count_rank_ss": 93, "count_rank_ssh": 50, "pp_country_rank": 495, "total_seconds_played": 3211433}', '{"pp": 342.071, "date": "2018-08-29 08:36:53", "rank": "A", "score": 73320820, "count50": 0, "perfect": 0, "user_id": 3416783, "count100": 9, "count300": 1466, "maxcombo": 1800, "score_id": 2619479813, "countgeki": 342, "countkatu": 7, "countmiss": 1, "beatmap_id": 1519282, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(3517706, '[ Zane ]', 25, '2021-01-15 02:17:49', '{"level": 106.006, "pp_raw": 13868.8, "count50": 203748, "country": "TW", "pp_rank": 95, "user_id": 3517706, "accuracy": 99.2180633544922, "count100": 2534714, "count300": 44697245, "username": "[ Zane ]", "join_date": "2013-10-30 01:44:16", "playcount": 190618, "total_score": 627532069300, "count_rank_a": 2440, "count_rank_s": 1801, "ranked_score": 108639516926, "count_rank_sh": 1301, "count_rank_ss": 151, "count_rank_ssh": 119, "pp_country_rank": 1, "total_seconds_played": 10110143}', '{"pp": 789.862, "date": "2020-10-19 21:01:16", "rank": "S", "score": 423634160, "count50": 0, "perfect": 0, "user_id": 3517706, "count100": 29, "count300": 3378, "maxcombo": 4196, "score_id": 3285919901, "countgeki": 440, "countkatu": 20, "countmiss": 0, "beatmap_id": 2365752, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(4183988, 'Zxcy', 17, '2021-01-15 02:17:40', '{"level": 100.669, "pp_raw": 7578.18, "count50": 87376, "country": "HK", "pp_rank": 6765, "user_id": 4183988, "accuracy": 98.49141693115234, "count100": 1018564, "count300": 12363354, "username": "Zxcy", "join_date": "2014-03-25 11:27:06", "playcount": 78273, "total_score": 93811750881, "count_rank_a": 492, "count_rank_s": 517, "ranked_score": 10836505751, "count_rank_sh": 116, "count_rank_ss": 29, "count_rank_ssh": 9, "pp_country_rank": 109, "total_seconds_played": 3528194}', '{"pp": 447.867, "date": "2019-06-25 20:12:25", "rank": "SH", "score": 1759375, "count50": 0, "perfect": 0, "user_id": 4183988, "count100": 11, "count300": 211, "maxcombo": 273, "score_id": 2837744367, "countgeki": 34, "countkatu": 8, "countmiss": 0, "beatmap_id": 2060305, "enabled_mods": 72, "replay_available": 0}', 1, 0),
	(4519494, 'Spinesnight', 14, '2021-01-15 02:17:36', '{"level": 102.565, "pp_raw": 9255.88, "count50": 206352, "country": "TW", "pp_rank": 2148, "user_id": 4519494, "accuracy": 98.711669921875, "count100": 2474045, "count300": 27799311, "username": "Spinesnight", "join_date": "2014-06-13 09:02:53", "playcount": 122082, "total_score": 283469211797, "count_rank_a": 1531, "count_rank_s": 1943, "ranked_score": 78481561462, "count_rank_sh": 1221, "count_rank_ss": 76, "count_rank_ssh": 31, "pp_country_rank": 37, "total_seconds_played": 7077492}', '{"pp": 495.212, "date": "2020-04-23 12:22:43", "rank": "A", "score": 49907310, "count50": 0, "perfect": 0, "user_id": 4519494, "count100": 18, "count300": 1150, "maxcombo": 1448, "score_id": 3062573386, "countgeki": 192, "countkatu": 15, "countmiss": 1, "beatmap_id": 1270000, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(5155973, 'Rizer', 4, '2021-01-15 02:17:24', '{"level": 107.86, "pp_raw": 13699.8, "count50": 60655, "country": "TW", "pp_rank": 106, "user_id": 5155973, "accuracy": 99.13928985595705, "count100": 1069546, "count300": 41950272, "username": "Rizer", "join_date": "2014-11-04 14:04:46", "playcount": 165711, "total_score": 812885636530, "count_rank_a": 1629, "count_rank_s": 2788, "ranked_score": 215310474864, "count_rank_sh": 5613, "count_rank_ss": 781, "count_rank_ssh": 2136, "pp_country_rank": 2, "total_seconds_played": 9807816}', '{"pp": 780.894, "date": "2020-08-29 14:08:35", "rank": "S", "score": 422251960, "count50": 0, "perfect": 0, "user_id": 5155973, "count100": 37, "count300": 3370, "maxcombo": 4192, "score_id": 3217970033, "countgeki": 433, "countkatu": 27, "countmiss": 0, "beatmap_id": 2365752, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(5413624, 'Hibiki', 15, '2021-01-15 02:17:37', '{"level": 101.274, "pp_raw": 10893.1, "count50": 158831, "country": "HK", "pp_rank": 695, "user_id": 5413624, "accuracy": 98.67893981933594, "count100": 1259802, "count300": 15543007, "username": "Hibiki", "join_date": "2014-12-24 13:28:57", "playcount": 83155, "total_score": 154295013314, "count_rank_a": 865, "count_rank_s": 119, "ranked_score": 29463073477, "count_rank_sh": 681, "count_rank_ss": 15, "count_rank_ssh": 166, "pp_country_rank": 18, "total_seconds_played": 4125168}', '{"pp": 611.499, "date": "2019-11-19 07:42:45", "rank": "SH", "score": 4533140, "count50": 0, "perfect": 1, "user_id": 5413624, "count100": 7, "count300": 280, "maxcombo": 407, "score_id": 2940851121, "countgeki": 86, "countkatu": 6, "countmiss": 0, "beatmap_id": 1925194, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(5920715, '2rdiodul', 12, '2021-01-15 02:17:33', '{"level": 100.741, "pp_raw": 7937.81, "count50": 60547, "country": "TW", "pp_rank": 5225, "user_id": 5920715, "accuracy": 97.23833465576172, "count100": 986399, "count300": 10227158, "username": "2rdiodul", "join_date": "2015-02-09 02:07:41", "playcount": 52632, "total_score": 100991759710, "count_rank_a": 1565, "count_rank_s": 1016, "ranked_score": 30397938607, "count_rank_sh": 597, "count_rank_ss": 36, "count_rank_ssh": 4, "pp_country_rank": 94, "total_seconds_played": 2783576}', '{"pp": 449.783, "date": "2020-05-20 12:45:27", "rank": "SH", "score": 4234897, "count50": 0, "perfect": 0, "user_id": 5920715, "count100": 10, "count300": 329, "maxcombo": 459, "score_id": 3092541015, "countgeki": 70, "countkatu": 8, "countmiss": 0, "beatmap_id": 2118443, "enabled_mods": 72, "replay_available": 0}', 1, 0),
	(7172340, 'NekoKamui', 9, '2021-01-15 02:17:28', '{"level": 101.36, "pp_raw": 9836.83, "count50": 155574, "country": "TW", "pp_rank": 1448, "user_id": 7172340, "accuracy": 98.16925048828124, "count100": 1503440, "count300": 16942419, "username": "NekoKamui", "join_date": "2015-10-02 12:44:17", "playcount": 101699, "total_score": 162974127073, "count_rank_a": 1951, "count_rank_s": 1288, "ranked_score": 47579729585, "count_rank_sh": 481, "count_rank_ss": 140, "count_rank_ssh": 70, "pp_country_rank": 30, "total_seconds_played": 4847125}', '{"pp": 544.821, "date": "2020-05-24 13:28:06", "rank": "SH", "score": 1282720, "count50": 0, "perfect": 1, "user_id": 7172340, "count100": 1, "count300": 182, "maxcombo": 225, "score_id": 3097115524, "countgeki": 42, "countkatu": 1, "countmiss": 0, "beatmap_id": 1068383, "enabled_mods": 72, "replay_available": 1}', 1, 0),
	(9539163, 'EthanTC', 7, '2021-01-15 02:17:27', '{"level": 102.089, "pp_raw": 10054.3, "count50": 89474, "country": "TW", "pp_rank": 1274, "user_id": 9539163, "accuracy": 99.17862701416016, "count100": 908709, "count300": 18824828, "username": "EthanTC", "join_date": "2017-01-07 08:54:47", "playcount": 69590, "total_score": 235817637267, "count_rank_a": 1426, "count_rank_s": 2, "ranked_score": 37316960111, "count_rank_sh": 648, "count_rank_ss": 0, "count_rank_ssh": 46, "pp_country_rank": 25, "total_seconds_played": 4749461}', '{"pp": 613.157, "date": "2019-12-10 08:44:22", "rank": "SH", "score": 141649759, "count50": 3, "perfect": 1, "user_id": 9539163, "count100": 32, "count300": 1777, "maxcombo": 2424, "score_id": 2955865849, "countgeki": 216, "countkatu": 19, "countmiss": 0, "beatmap_id": 1537566, "enabled_mods": 8, "replay_available": 1}', 1, 0),
	(9632700, 'Odiz', 24, '2021-01-15 02:17:48', '{"level": 100.495, "pp_raw": 7842.59, "count50": 45314, "country": "TW", "pp_rank": 6320, "user_id": 9632700, "accuracy": 98.98811340332033, "count100": 586506, "count300": 8893212, "username": "Odiz", "join_date": "2017-01-25 07:18:32", "playcount": 54942, "total_score": 76467155434, "count_rank_a": 681, "count_rank_s": 182, "ranked_score": 9827963636, "count_rank_sh": 201, "count_rank_ss": 15, "count_rank_ssh": 24, "pp_country_rank": 100, "total_seconds_played": 2446194}', '{"pp": 429.261, "date": "2020-03-10 13:50:59", "rank": "A", "score": 32345484, "count50": 0, "perfect": 0, "user_id": 9632700, "count100": 6, "count300": 1164, "maxcombo": 1277, "score_id": 3020887081, "countgeki": 275, "countkatu": 5, "countmiss": 6, "beatmap_id": 915210, "enabled_mods": 0, "replay_available": 1}', 1, 0),
	(9991663, '[-koume-]', 23, '2021-01-15 02:17:47', '{"level": 101.086, "pp_raw": 7771.48, "count50": 106262, "country": "HK", "pp_rank": 5860, "user_id": 9991663, "accuracy": 98.63877868652344, "count100": 1351069, "count300": 17624791, "username": "[-koume-]", "join_date": "2017-04-02 14:14:29", "playcount": 104391, "total_score": 135566103186, "count_rank_a": 2313, "count_rank_s": 690, "ranked_score": 35869204640, "count_rank_sh": 1340, "count_rank_ss": 62, "count_rank_ssh": 228, "pp_country_rank": 94, "total_seconds_played": 5124911}', '{"pp": 458.453, "date": "2020-04-19 09:54:05", "rank": "SH", "score": 4326951, "count50": 0, "perfect": 1, "user_id": 9991663, "count100": 8, "count300": 313, "maxcombo": 468, "score_id": 3058174327, "countgeki": 72, "countkatu": 7, "countmiss": 0, "beatmap_id": 1619564, "enabled_mods": 72, "replay_available": 0}', 1, 0),
	(12717375, 'NashiKari', 10, '2021-01-15 02:17:29', '{"level": 100.523, "pp_raw": 8525.51, "count50": 150050, "country": "TW", "pp_rank": 3444, "user_id": 12717375, "accuracy": 97.90440368652344, "count100": 1623527, "count300": 13955807, "username": "NashiKari", "join_date": "2018-07-23 12:19:12", "playcount": 72710, "total_score": 79205359482, "count_rank_a": 1260, "count_rank_s": 404, "ranked_score": 16202723565, "count_rank_sh": 393, "count_rank_ss": 24, "count_rank_ssh": 39, "pp_country_rank": 59, "total_seconds_played": 3998076}', '{"pp": 495.754, "date": "2019-11-26 13:49:01", "rank": "A", "score": 30469108, "count50": 7, "perfect": 0, "user_id": 12717375, "count100": 82, "count300": 904, "maxcombo": 1321, "score_id": 2945892110, "countgeki": 166, "countkatu": 29, "countmiss": 1, "beatmap_id": 1945175, "enabled_mods": 64, "replay_available": 1}', 1, 0);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='round';

-- Dumping data for table tourney.round: ~1 rows (approximately)
DELETE FROM `round`;
/*!40000 ALTER TABLE `round` DISABLE KEYS */;
INSERT INTO `round` (`id`, `name`, `description`, `best_of`, `start_date`, `pool_publish`) VALUES
	(1, 'Qualifier', 'no fucking way', 9, '2021-05-24 16:00:28', 0);
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
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='staff member';

-- Dumping data for table tourney.staff: ~33 rows (approximately)
DELETE FROM `staff`;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` (`id`, `user_id`, `group_id`, `username`, `privileges`, `join_date`, `active`) VALUES
	(1, 4211179, 1, '[Hakura_San]', 1023, '2021-05-17 23:03:38', 1),
	(2, 7633130, 4, 'Poyoyo', 4, '2021-05-23 23:00:29', 0),
	(3, 7172340, 3, 'NekoKamui', 2, '2021-05-23 23:00:32', 0),
	(4, 1593180, 5, 'XzCraftP', 8, '2021-05-23 23:00:59', 0),
	(5, 4410916, 4, 'Hikari Awa', 4, '2021-05-23 23:01:01', 0),
	(6, 4360253, 4, 'lifeEX', 4, '2021-05-23 23:01:04', 0),
	(7, 2537924, 4, 'DazzLE_Wind', 4, '2021-05-23 23:01:05', 0),
	(8, 1921656, 4, 'NaNami RURU', 4, '2021-05-23 23:01:07', 0),
	(9, 12567451, 4, 'danielgood243', 4, '2021-05-23 23:01:09', 0),
	(10, 1786610, 3, 'Naze Meiyue', 2, '2021-05-23 23:01:11', 0),
	(11, 2317789, 3, 'Diaostrophism', 2, '2021-05-23 23:01:13', 0),
	(12, 9539163, 3, 'EthanTC', 2, '2021-05-23 23:01:15', 0),
	(13, 4438362, 3, 'YinyinMeiDaiZi', 2, '2021-05-23 23:01:17', 0),
	(14, 11047052, 3, '[ Guai ]', 2, '2021-05-23 23:01:20', 0),
	(15, 4783406, 3, '[ small black ]', 10, '2021-05-23 23:01:21', 0),
	(16, 8878107, 3, 'gggiantguygirl', 2, '2021-05-23 23:01:23', 0),
	(17, 12676270, 3, 'ostriich_LEN', 2, '2021-05-23 23:01:25', 0),
	(18, 1028615, 3, 'Y e c h I', 2, '2021-05-23 23:01:34', 0),
	(19, 6077567, 3, '[YAMATO]', 2, '2021-05-23 23:01:36', 0),
	(20, 2529213, 2, 'SugiuraAyano', 80, '2021-05-23 23:01:38', 0),
	(21, 7472477, 2, 'slowstart', 64, '2021-05-23 23:01:39', 0),
	(22, 9034233, 2, 'NachoNya', 64, '2021-05-23 23:01:41', 0),
	(24, 4086497, 6, 'Hey lululu', 16, '2021-05-23 23:01:44', 0),
	(25, 1285637, 6, 'Shiina Noriko', 16, '2021-05-23 23:01:46', 0),
	(26, 4464409, 7, 'Akshilsnow', 32, '2021-05-23 23:01:48', 0),
	(27, 1952803, 10, 'Oktavia', 1, '2021-05-23 23:01:50', 0),
	(28, 6720545, 9, 'jun112561', 256, '2021-05-23 23:01:52', 0),
	(29, 3759860, 3, 'Raniemi', 2, '2021-01-31 17:51:21', 0),
	(30, 3, 10, 'BanchoBot', 1, '2021-01-30 02:53:53', 0),
	(31, 9502522, 6, '[ TNTlealu ]', 16, '2021-05-23 23:01:59', 0),
	(32, 2, 9, 'peppy', 256, '2021-05-23 23:02:01', 0),
	(33, 9834516, 2, 'Himeno Sena', 64, '2021-05-23 23:02:04', 0),
	(34, 2465704, 1, 'John6023', 1023, '2021-05-23 23:01:31', 0);
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;

-- Dumping structure for table tourney.team
CREATE TABLE IF NOT EXISTS `team` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Team ID',
  `full_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Team full name',
  `flag_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Team banner name',
  `acronym` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Team Ancronym',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '狀態',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Team ';

-- Dumping data for table tourney.team: ~27 rows (approximately)
DELETE FROM `team`;
/*!40000 ALTER TABLE `team` DISABLE KEYS */;
INSERT INTO `team` (`id`, `full_name`, `flag_name`, `acronym`, `status`) VALUES
	(2, 'Bitcoin', 'avatar.654296', 'Bitcoin', 0),
	(3, 'Imokora', 'avatar.2472609', 'Imokora', 0),
	(4, 'Rizer', 'avatar.5155973', 'Rizer', 0),
	(5, '_kyuu', 'avatar.3416783', '_kyuu', 0),
	(6, 'Muji', 'avatar.2200982', 'Muji', 0),
	(7, 'EthanTC', 'avatar.9539163', 'EthanTC', 0),
	(8, 'Music Lord', 'avatar.2808144', 'Music Lord', 0),
	(9, 'NekoKamui', 'avatar.7172340', 'NekoKamui', 0),
	(10, 'NashiKari', 'avatar.12717375', 'NashiKari', 0),
	(11, '_Shield', 'avatar.1860489', '_Shield', 0),
	(12, '2rdiodul', 'avatar.5920715', '2rdiodul', 0),
	(13, 'MiyazonoKuma', 'avatar.3366658', 'MiyazonoKuma', 0),
	(14, 'Spinesnight', 'avatar.4519494', 'Spinesnight', 0),
	(15, 'Hibiki', 'avatar.5413624', 'Hibiki', 0),
	(16, 'GfMRT', 'avatar.3163649', 'GfMRT', 0),
	(17, 'Zxcy', 'avatar.4183988', 'Zxcy', 0),
	(18, 'Naze Meiyue', 'avatar.1786610', 'Naze Meiyue', 0),
	(19, '[ MILK_Jiang]', 'avatar.3066316', '[ MILK_Jiang]', 0),
	(20, 'XzCraftP', 'avatar.1593180', 'XzCraftP', 0),
	(21, 'SugiuraAyano', 'avatar.2529213', 'SugiuraAyano', 0),
	(22, 'mcy4', 'avatar.2165650', 'mcy4', 0),
	(23, '[-koume-]', 'avatar.9991663', '[-koume-]', 0),
	(24, 'Odiz', 'avatar.9632700', 'Odiz', 0),
	(25, '[ Zane ]', 'avatar.3517706', '[ Zane ]', 0);
/*!40000 ALTER TABLE `team` ENABLE KEYS */;

-- Dumping structure for table tourney.tourney
CREATE TABLE IF NOT EXISTS `tourney` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '比賽 ID',
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
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='Game information';

-- Dumping data for table tourney.tourney: ~0 rows (approximately)
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
	`mods` VARCHAR(50) NULL COMMENT '使用Mod(s)' COLLATE 'utf8_general_ci',
	`info` JSON NULL COMMENT '圖譜資訊',
	`note` VARCHAR(50) NULL COMMENT '備註' COLLATE 'utf8_general_ci',
	`add_date` DATETIME NOT NULL,
	`nominator_id` INT(10) NULL COMMENT '工作人員 ID',
	`nominator_uid` INT(10) NULL COMMENT 'OSU ID',
	`nominator_gid` INT(10) NULL COMMENT '群組 ID',
	`nominator_name` VARCHAR(16) NULL COMMENT 'OSU 用戶名' COLLATE 'utf8_general_ci'
) ENGINE=MyISAM;

-- Dumping structure for view tourney.view_staff
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_staff` (
	`id` INT(10) NOT NULL COMMENT 'Staff ID',
	`user_id` INT(10) NOT NULL COMMENT 'OSU ID',
	`group_id` INT(10) NOT NULL COMMENT 'Group ID',
	`username` VARCHAR(16) NOT NULL COMMENT 'OSU username' COLLATE 'utf8_general_ci',
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
