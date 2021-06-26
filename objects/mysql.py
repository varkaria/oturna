import pymysql, json
from pymysql.cursors import DictCursor
from config import Config
from objects import osuapi
from objects.objects import *

class DB(object):
    def __init__(self):
        self.connect = pymysql.connect(
            host=Config.MYSQL_HOST,
            port=Config.MYSQL_PORT,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DB,
            cursorclass=DictCursor,
            autocommit=True
        )
        self.cursor = self.connect.cursor()

    def query_one(self, query, args=None):
        self.connect.ping(reconnect=True)
        self.cursor.execute(query, args)
        self.connect.commit()
        return self.cursor.fetchone()

    def query_all(self, query, args=None):
        self.connect.ping(reconnect=True)
        self.cursor.execute(query, args)
        self.connect.commit()
        return self.cursor.fetchall()

    def query(self, query, args=None, one=True):
        if one:
            return self.query_one(query, args)
        return self.query_all(query, args)

    def update(self, table, id, **kargs):
        params = []
        for k, v in kargs.items():
            if v is not None:
                params.append(f"{k}='{v}'")
            else:
                params.append(f"{k}=NULL")

        self.connect.ping(reconnect=True)
        self.cursor.execute("update `{}` set {} where {} = '{}'".format(table, ', '.join(params), *id))
        self.connect.commit()

    def close(self):
        self.cursor.close()
        self.connect.close()

    def get_mappool(self, round_id, ingore_pool_publish=False, format=True):
        round = self.query_one(f"SELECT * FROM round WHERE id = {round_id}")
        pooldata = self.query_all(f"SELECT m.*, mg.hex_color, s.user_id, s.username FROM mappool AS m LEFT JOIN staff AS s ON s.id=m.nominator LEFT JOIN map_group AS mg ON mg.name=m.mods WHERE round_id = {round_id} ORDER BY FIELD(`mods`, 'FM', 'NM', 'HD', 'HR', 'DT', 'Roll', 'EZ', 'TB'), code")
        if round['pool_publish'] or ingore_pool_publish:
            for map in pooldata:
                map['info'] = json.loads(map['info'])
            if not format:
                return pooldata

            mappool = {}
            for map in pooldata:
                if map['mods'] not in mappool.keys():
                    mappool[map['mods']] = []
                mappool[map['mods']].append(map)
            return {
                'round_id': int(round_id),
                'mappool': mappool
                }
       

    @property
    def active_rounds(self):
        return self.query_all("SELECT * FROM round WHERE start_date < NOW()")

    @property
    def current_round(self):
        return self.query_one("SELECT * FROM round WHERE start_date < NOW() ORDER BY start_date DESC")

    @property
    def tourney(self):
        return self.query_one("SELECT * FROM tourney WHERE id = 1")

    def get_teams(self, id=None):
        query_team_text = "SELECT * FROM team"
        if id: query_team_text += " WHERE id = %d" % id

        teams = self.query_all(query_team_text)
        for t in teams:
            t['players'] = []
            players = self.query_all("SELECT * FROM player WHERE team = %s", (t['id'],))
            for p in players:
                p['info'] = json.loads(p['info'])
                p['bp1'] = json.loads(p['bp1'])
                t['players'].append(p)
        return teams

    def get_players(self, id=None):
        query_text = "SELECT * FROM player"
        if id: query_text += " WHERE id = %d" % id
        players = self.query_all(query_text)
        for p in players:
                p['info'] = json.loads(p['info'])
                p['bp1'] = json.loads(p['bp1'])
        return players

    def get_matchs(self, round_id=None, id=None):
        query_text = """SELECT JSON_OBJECT(
            'id', m.id,
            'code', m.code,
            'date', DATE_FORMAT(m.date, '%Y-%m-%d %H:%i'),
            'round', JSON_OBJECT('id', r.id, 'name', r.name, 'description', r.description, 'start_date', DATE_FORMAT(r.start_date, '%Y-%m-%d %H:%i')),
            'team1', JSON_OBJECT('id', t1.id, 'full_name', t1.full_name, 'flag_name', t1.flag_name, 'acronym', t1.acronym, 'score', m.team1_score),
            'team2', JSON_OBJECT('id', t2.id, 'full_name', t2.full_name, 'flag_name', t2.flag_name, 'acronym', t2.acronym, 'score', m.team2_score),
            'referee', JSON_OBJECT('id', ref.id, 'group_id', ref.group_id, 'user_id', ref.user_id, 'username', ref.username),
            'streamer', JSON_OBJECT('id', str.id, 'group_id', str.group_id, 'user_id', str.user_id, 'username', str.username),
            'commentator', JSON_OBJECT('id', com.id, 'group_id', com.group_id, 'user_id', com.user_id, 'username', com.username),
            'commentator2', JSON_OBJECT('id', com2.id, 'group_id', com2.group_id, 'user_id', com2.user_id, 'username', com2.username),
            'mp_link', m.mp_link,
            'video_link', m.video_link,
            'current', (m.stats = 0 AND m.date < NOW()),
            'live', (m.date < NOW()),
            'loser', (m.loser = 1),
            'stats', m.stats,
            'note', m.note
            ) AS `json`
            FROM `match` m
            LEFT JOIN `round` r ON r.id = m.round_id
            LEFT JOIN team t1 ON t1.id = m.team1
            LEFT JOIN team t2 ON t2.id = m.team2
            LEFT JOIN staff ref ON ref.id = m.referee
            LEFT JOIN staff str ON str.id = m.streamer
            LEFT JOIN staff com ON com.id = m.commentator
            LEFT JOIN staff com2 ON com2.id = m.commentator2
            """
        if round_id or id:
            query_text += " WHERE "
        if round_id: query_text += "m.round_id = %s " % round_id
        if id: query_text += "m.id = %d " % id
        query = self.query_all(query_text)
        res = []
        for m in query:
            m = json.loads(m['json'])
            m['preducts'] = []
            w = self.query_all(f'SELECT * FROM com_preducts WHERE match_id={m["id"]}')
            for a in w:
                m['preducts'].append(a)
            res.append(m)
        return res

    def get_full_match(self, id=None, set=0):
        query_text = """SELECT JSON_OBJECT(
        'id', m.id,
        'code', m.code,
        'date', DATE_FORMAT(m.date, '%Y-%m-%d %H:%i'),
        'round', JSON_OBJECT('id', r.id, 'name', r.name, 'description', r.description, 'start_date', DATE_FORMAT(r.start_date, '%Y-%m-%d %H:%i')),
        'team1', JSON_OBJECT('id', t1.id, 'full_name', t1.full_name, 'flag_name', t1.flag_name, 'acronym', t1.acronym, 'players', JSON_ARRAY(p1.username)),
        'team2', JSON_OBJECT('id', t2.id, 'full_name', t2.full_name, 'flag_name', t2.flag_name, 'acronym', t2.acronym, 'players', JSON_ARRAY(p2.username)),
        'referee', JSON_OBJECT('id', ref.id, 'group_id', ref.group_id, 'user_id', ref.user_id, 'username', ref.username),
        'streamer', JSON_OBJECT('id', str.id, 'group_id', str.group_id, 'user_id', str.user_id, 'username', str.username),
        'commentator', JSON_OBJECT('id', com.id, 'group_id', com.group_id, 'user_id', com.user_id, 'username', com.username),
        'commentator2', JSON_OBJECT('id', com2.id, 'group_id', com2.group_id, 'user_id', com2.user_id, 'username', com2.username),
        'mp_link', m.mp_link,
        'video_link', m.video_link,
        'live', (m.date < NOW()),
        'loser', (m.loser = 1),
        'note', m.note,
        'lock', m.lock
        ) AS `json`
        FROM `match` m
        LEFT JOIN `round` r ON r.id = m.round_id
        LEFT JOIN team t1 ON t1.id = m.team1
        LEFT JOIN team t2 ON t2.id = m.team2
        LEFT JOIN `player` p1 ON p1.team = t1.id
        LEFT JOIN `player` p2 ON p2.team = t2.id
        LEFT JOIN staff ref ON ref.id = m.referee
        LEFT JOIN staff str ON str.id = m.streamer
        LEFT JOIN staff com ON com.id = m.commentator
        LEFT JOIN staff com2 ON com2.id = m.commentator2
        """
        if not id:
            return 'no owo'
        else:
            query_text += " WHERE "
        if id: query_text += "m.id = %d " % id
        query = self.query_one(query_text)
        fulldata = json.loads(query['json'])
        
        # declare some owoall score
        o_score = [0,0]
        o_score_to_win = 2
        o_sets = []
        l_sets = self.query_all("SELECT id FROM match_sets WHERE match_id=%s", [id]) # ดึงข้อมูล sets จาก database

        if fulldata['mp_link'] != '':
            # osu!api part
            import os.path
            parsed = os.path.split(fulldata['mp_link'])
            man = osuapi.get(osuapi.V1Path.get_match, mp=int(parsed[1]))
            multi_games_data = man['games']
            temp = self.query_all("SELECT mp_link FROM temp_mplink WHERE match_id=%s", (fulldata['id']))
            if temp:
                for a in temp:
                    x = os.path.split(a['mp_link'])
                    man = osuapi.get(osuapi.V1Path.get_match, mp=int(x[1]))
                    multi_games_data.append(a['games'])
        else:
            multi_games_data = []


        for s in l_sets:
            score, points_to_win, state, finish = [0,0], 3, 1, False
            pickbans = self.query_all("""SELECT m.id, m.map_id, m.from, m.type, p.info, p.mods, p.code 
                                      FROM match_sets_banpick `m` LEFT JOIN `mappool` `p` ON p.beatmap_id = m.map_id 
                                      WHERE set_id=%s""", [s['id']])
            for e in pickbans: e['info'] = json.loads(e['info'])
            
            bans = list(filter(lambda m: m['type'] == 'ban',pickbans))
            picks = list(filter(lambda m: m['type'] == 'pick',pickbans))
            
            # pick result
            for p in picks:
                dupli = []
                for idx, g in enumerate(multi_games_data):
                    if str(p['map_id']) == str(g['beatmap_id']) and str(p['map_id']) not in str(dupli):
                        dupli.append(str(p['map_id']))
                        if g['scores']:
                            for w in g['scores']:
                                q = self.query_one("""SELECT player.username AS `player`, team.full_name AS `team` 
                                                   FROM player LEFT JOIN team ON team.id = player.team 
                                                   WHERE user_id=%s""", (w['user_id']))
                                w['username'] = q['player']
                                w['teamname'] = q['team']
                            win = check_team_win(g['scores'])
                            p['result'] = g['scores']
                            p['winner'] = g['scores'][win]
                            score[win] += 1
                            state += 1
                            multi_games_data.pop(idx)
                if score[0] == points_to_win or score[1] == points_to_win:
                    if score[0] == points_to_win:
                        o_score[0] += 1
                    else:
                        o_score[1] += 1
                    state = 0
                    finish = True
                    break

            # set tiebreaker
            if score[0] == points_to_win - 1 and score[1] == points_to_win - 1:
                tie_set = self.query_one("""SELECT id, beatmap_id AS map_id, 'tiebreaker' AS 'from', 
                                         'pick' AS 'type', info FROM mappool 
                                         WHERE round_id=%s AND mods='TB'""",[fulldata['round']['id']])
                tie_set['info'], tie_set['mods'], tie_set['code'] = json.loads(tie_set['info']), 'Sets Tiebreaker', ''

                for idx, g in enumerate(multi_games_data):
                    if str(tie_set['map_id']) == str(g['beatmap_id']) and str(tie_set['map_id']) not in str(dupli):
                        for w in g['scores']:
                            q = self.query_one("SELECT player.username AS `player`, team.full_name AS `team` FROM player LEFT JOIN team ON team.id = player.team WHERE user_id=%s", (w['user_id']))
                            w['username'] = q['player']
                            w['teamname'] = q['team']
                        win = check_team_win(g['scores'])
                        tie_set['result'], tie_set['winner'] = g['scores'], g['scores'][win]
                        score[win] += 1 
                        o_score[win] += 1
                        state, finish = 0, True
                        multi_games_data.pop(idx)
                picks.append(tie_set)
            o_sets.append({'ban': bans, 'pick': picks, 'score': score, 'state': state, 'finish': finish})
        
        # match tiebreaker
        if o_score[0] == o_score[1] and o_score[0] == o_score_to_win - 1:
            tiebreaker_match = self.query_one("SELECT id, beatmap_id AS map_id, 'tiebreaker' AS 'from', 'pick' AS 'type', info FROM mappool WHERE round_id=%s AND mods='TBS'",[fulldata['round']['id']])
            tiebreaker_match['mods'], tiebreaker_match['code'], tiebreaker_match['info'] = 'Match Tiebreaker', '', json.loads(tiebreaker_match['info'])
            score, finish, state = [0,0], False, 1
            
            for idx, g in enumerate(multi_games_data): # นำผลที่ได้มาจาก osu!api มาเรียง
                if str(tiebreaker_match['map_id']) == str(g['beatmap_id']) and str(tiebreaker_match['map_id']) not in str(dupli):
                    for w in g['scores']:
                        q = self.query_one("SELECT player.username AS `player`, team.full_name AS `team` FROM player LEFT JOIN team ON team.id = player.team WHERE user_id=%s", (w['user_id']))
                        w['username'], w['teamname'] = q['team'], q['player']
                    tiebreaker_match['result'] = g['scores']
                    tiebreaker_match['winner'] = g['scores'][check_team_win(g['scores'])]
                    win = check_team_win(g['scores'])
                    score[win] += 1
                    o_score[win] += 1
                    state, finish = 0, True
                    multi_games_data.pop(idx)
            o_sets.append({'ban': [],'pick': [tiebreaker_match],'score': score,'state': state,'finish': finish})

        fulldata['sets'], fulldata['score'], fulldata['finish'] = o_sets, o_score, False

        # match winner
        if o_score[0] == 2 or o_score[1] == 2:
            if o_score[0] == 2:
                fulldata['winner'] = fulldata['team1']
            else:
                fulldata['winner'] = fulldata['team2']
            fulldata['finish'] = True
        
        # currentround
        if o_sets:
            if len(o_sets) == 2:
                if len(o_sets[len(o_sets)-1]['pick']) >= 4:
                    fulldata['currentround'] = [len(o_sets)-1,o_sets[len(o_sets)-1]['state']-1]
                else:
                    fulldata['currentround'] = [len(o_sets)-2,o_sets[len(o_sets)-2]['state']-1]
            else:
                fulldata['currentround'] = [len(o_sets)-1,o_sets[len(o_sets)-1]['state']-1]
        else:
            fulldata['currentround'] = [0,0]

        def calculate_point(o_score):
            r, b = o_score
            return [r + 1 - min(b, 1), b + 1 - min(r, 1)]
        team_1_score, team_2_score = calculate_point(o_score)
        # Saving data in database       
        self.query_one(f'UPDATE `tourney`.`match` SET `team2_score`="{team_2_score}" WHERE `id`={fulldata["id"]};')
        self.query_one(f'UPDATE `tourney`.`match` SET `team1_score`="{team_1_score}" WHERE `id`={fulldata["id"]};')

        if set == 1 and finish == True and fulldata['lock'] == 0:
            self.query_one(f'UPDATE `tourney`.`team` SET `points`=`points`+ {team_1_score} WHERE `id`={fulldata["team1"]["id"]};')
            self.query_one(f'UPDATE `tourney`.`team` SET `points`=`points`+ {team_2_score} WHERE `id`={fulldata["team2"]["id"]};')
            if o_score[0] == 2:
                self.query_one(f'UPDATE `tourney`.`team` SET `win`=`win`+ 1 WHERE `id`={fulldata["team1"]["id"]};')
                self.query_one(f'UPDATE `tourney`.`team` SET `lose`=`lose`+ 1 WHERE `id`={fulldata["team2"]["id"]};')
            else:
                self.query_one(f'UPDATE `tourney`.`team` SET `win`=`win`+ 1 WHERE `id`={fulldata["team2"]["id"]};')
                self.query_one(f'UPDATE `tourney`.`team` SET `lose`=`lose`+ 1 WHERE `id`={fulldata["team1"]["id"]};')
            preducts = self.query_all(f'SELECT * FROM `tourney`.`com_preducts` WHERE `match_id`={fulldata["id"]} AND `finish`=0;')
            for p in preducts:
                point = 0
                parsed = f"{p['s_team1']} - {p['s_team2']}"
                if o_score[0] == 2 and o_score[0] == p['s_team1']:
                    point = point + 3
                    if o_score[1] == p['s_team2']:
                        point = point + 2
                    continue
                elif o_score[1] == 2 and o_score[1] == p['s_team2']:
                    point = point + 3
                    if o_score[0] == p['s_team1']:
                        point = point + 2
                    continue
                elif parsed == f"{o_score[0]} - {o_score[1]}" or f"{o_score[1]} - {o_score[0]}":
                    point = point + 2
                    continue
                self.query_one(f'UPDATE `tourney`.`staff` SET `c_score`=`c_score` + {point} WHERE `id`={p["commentator"]};')
            self.query_one(f'UPDATE `tourney`.`com_preducts` SET `finish`=1 WHERE `match_id`={fulldata["id"]} AND `finish`=0;')
            self.query_one(f'UPDATE `tourney`.`team` SET `match_play`=`match_play` + 1 WHERE `id`={fulldata["team1"]["id"]};')
            self.query_one(f'UPDATE `tourney`.`team` SET `match_play`=`match_play` + 1 WHERE `id`={fulldata["team2"]["id"]};')
            self.query_one(f'UPDATE `tourney`.`match` SET `lock`="1" WHERE  `id`={fulldata["id"]};')
            self.query_one(f'UPDATE `tourney`.`match` SET `stats`="1" WHERE  `id`={fulldata["id"]};')
                
        return fulldata

    def get_staff(self, staff_id=None, user_id=None, format=True, viewall=False):
        if user_id:
            query = self.query_one('select * from staff where user_id = %s and active = 1', (user_id,))
            return query

        if staff_id:
            query = self.query_one('select * from staff where id = %s and active = 1', (staff_id,))
            return query

        va = 'WHERE s.active = 1 ORDER BY s.active, s.id' if not viewall else 'ORDER BY s.id'

        query = self.query_all('SELECT s.id, s.user_id, s.username, s.privileges, s.active, g.* FROM staff s INNER JOIN `group` g ON g.id = s.group_id ' + va)
        if not format:
            return query
        staff = {}
        for s in query:
            if s['th_name'] not in staff.keys():
                staff[s['th_name']] = []
            staff[s['th_name']].append(s)
        return staff

    def get_match_sets_ban_pick_full(self, id): # for socket.io client
        res = self.query_one(
            f"""SELECT JSON_OBJECT(
            'id', m.id,
            'set_id', ms.id,
            'reverse', ms.reverse,
            'round_id', r.id,
            'mp_link', m.mp_link,
            'team1', JSON_OBJECT('id', t1.id, 'full_name', t1.full_name, 'flag_name', t1.flag_name, 
            'acronym', t1.acronym, 'online', p1.online, 'leader_id', p1.user_id, 'leader_name', p1.username),
            'team2', JSON_OBJECT('id', t2.id, 'full_name', t2.full_name, 'flag_name', t2.flag_name, 
            'acronym', t2.acronym, 'online', p2.online, 'leader_id', p2.user_id, 'leader_name', p2.username),
            'banpicks', JSON_ARRAYAGG(JSON_OBJECT('id', pb.id, 'set_id', pb.set_id, 'type', pb.type, 
            'map_id', pb.map_id, 'from', s.full_name, 'info', mp.info, 'mods', mp.mods)),
            'date', DATE_FORMAT(m.date, '%Y-%m-%d %H:%i')
            ) AS `json`
            FROM `match` m
            LEFT JOIN `round` r ON r.id = m.round_id
            LEFT JOIN `team` t1 ON t1.id = m.team1
            LEFT JOIN `team` t2 ON t2.id = m.team2
            LEFT JOIN `player` p1 ON p1.team = t1.id AND p1.leader = 1
            LEFT JOIN `player` p2 ON p2.team = t2.id AND p2.leader = 1
            LEFT JOIN `match_sets` ms ON ms.match_id = m.id 
            LEFT JOIN `match_sets_banpick` pb ON pb.set_id = ms.id
            LEFT JOIN `mappool` mp ON mp.beatmap_id = pb.map_id
            LEFT JOIN `team` s ON s.id = pb.from
            WHERE ms.id={id}
            """)

        res = json.loads(res['json'])
        mappool = self.query_all(f"SELECT id, mods, json FROM json_mappool where `round_id`={res['round_id']}")

        e = []

        available_maps = []
        for s in mappool:
            d = json.loads(s['json'])
            if str(d['beatmap_id']) in str(res['banpicks']) or str(d['mods']) == 'TB' or str(d['mods']) == 'TBS':
                continue
            else:
                available_maps.append({
                    'id': s['id'],
                    'mods': s['mods'],
                    'info': d
                })

        if res['banpicks']:
            t = len(res['banpicks'])
            if res['banpicks'][0]['from'] != None:
                if t in [0,1,4,5]:
                    res['status'] = 'ban'
                else:
                    res['status'] = 'pick'
                
                reverse = self.query("SELECT reverse FROM `match_sets` WHERE `finish_ban`=0 LIMIT 1")
                if reverse['reverse'] == 1:
                    if t in [0,3,5,6]:
                        res['picker'] = res['team2']['leader_id']
                        res['picker_t'] = res['team2']['full_name']
                    else:
                        res['picker'] = res['team1']['leader_id']
                        res['picker_t'] = res['team1']['full_name']
                else:
                    if t in [0,3,5,6]:
                        res['picker'] = res['team1']['leader_id']
                        res['picker_t'] = res['team1']['full_name']
                    else:
                        res['picker'] = res['team2']['leader_id']
                        res['picker_t'] = res['team2']['full_name']
                
            elif res['banpicks'][0]['from'] == None:
                res['picker'] = res['team1']['leader_id']
                res['picker_t'] = res['team1']['full_name']
                res['status'] = 'ban'

            if t == 8:
                self.query(f"UPDATE `tourney`.`match_sets` SET `finish_ban`='1' WHERE  `id`={res['set_id']};")
                res['picker'] = None
                res['picker_t'] = None

        res['available_maps'] = available_maps
    
        return res