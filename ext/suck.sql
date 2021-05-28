-- ----------------------------
-- View structure for view_mappool
-- ----------------------------
DROP VIEW IF EXISTS `view_mappool`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_mappool` AS
select `mappool`.`id` AS `id`,
    `mappool`.`round_id` AS `round_id`,
    `mappool`.`beatmap_id` AS `beatmap_id`,
    `map_group`.`name` AS `map_group`,
    `map_group`.`badge_color` AS `badge_color`,
    `map_group`.`hex_color` AS `hex_color`,
    `mappool`.`code` AS `code`,
    `mappool`.`mods` AS `mods`,
    `mappool`.`info` AS `info`,
    `mappool`.`note` AS `note`,
    `mappool`.`add_date` AS `add_date`,
    `view_staff`.`id` AS `nominator_id`,
    `view_staff`.`user_id` AS `nominator_uid`,
    `view_staff`.`group_id` AS `nominator_gid`,
    `view_staff`.`username` AS `nominator_name`
from (
        (
            `mappool`
            left join `view_staff` on((`view_staff`.`id` = `mappool`.`nominator`))
        )
        left join `map_group` on((`map_group`.`name` = `mappool`.`mods`))
    );
SET FOREIGN_KEY_CHECKS = 1;