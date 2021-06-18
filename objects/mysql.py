import pymysql, json
from pymysql.cursors import DictCursor
from config import Config
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
        return [json.loads(m['json']) for m in query]

    def get_full_match(self, id=None):
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
        if not id:
            return 'no owo'
        else:
            query_text += " WHERE "
        if id: query_text += "m.id = %d " % id
        query = self.query_one(query_text)
        fulldata = json.loads(query['json'])
        o_score = [0,0]
        l_sets = self.query_all("SELECT id FROM match_sets WHERE match_id=%s", [id]) # ดึงข้อมูล sets จาก database
        o_sets = [] # แสดงตัวแปรที่จะออกในแต่ละ sets

        # ดึงข้อมูลจาก osu!api (ตอนนี้ใช้ json โง่ๆไปก่อน)
        with open('sample.json', 'r') as readfile:
            man = json.load(readfile)
        multi_games_data = man['games']

        """
        This part need HowtoplayLN to improve it 
        """

        for s in l_sets: # นำข้อมูล sets มาเรียง
            score = [0,0]
            points_to_win = 3 # i'll add in mysql soon
            state = 1 # state : map on 1 2 3 4 5 (Tiebreaker) 10 (Finished)
            pickbans = self.query_all("""
            SELECT m.id, m.map_id, m.from, m.type, p.info
            FROM match_sets_banpick `m` 
            LEFT JOIN `mappool` `p` ON p.beatmap_id = m.map_id 
            WHERE set_id=%s""", [s['id']]) # ดึงข้อมูลการแบนและการเลือกของรอบนั้น
            
            # คัดแยกว่าแมพไหนคือแบนหรือเลือก
            bans = list(
                filter(
                    lambda m: m['type'] == 'ban'
                    ,pickbans)
                )
            picks = list(
                filter(
                    lambda m: m['type'] == 'pick'
                    ,pickbans)
                )
            
            # นำคะแนนที่ได้มาจาก osu!api มาใส่ในการเลือกของเซ็ต
            for p in picks:
                dupli = [] # แมพที่ใช้ไปแล้วจะมาอยู่ในนี้ เพื่อกันว่าจะใส่ในแมพซ้ำหรือปล่าว
                if score[0] == points_to_win or score[1] == points_to_win: # ถ้าคะแนนของทีมครบตามที่กำหนด จะยกเลิกการทำงานของ picks sets นี้ทันที
                    # มอบคะแนนให้กับทีมนั้นๆ 🧶
                    if score[0] == points_to_win:
                        o_score[0] += 1
                    else:
                        o_score[1] += 1
                    # เปลี่ยนสถานะของเซ็ตนี้ให้กลายเป็น 10 (เซ็ตนี้จบแล้ว)
                    state = 10
                    break
                for idx, g in enumerate(multi_games_data): # นำผลที่ได้มาจาก osu!api มาเรัยง
                    if str(p['map_id']) == str(g['beatmap_id']) and str(p['map_id']) not in str(dupli): # ถ้าแมพใน pick(ทีละอัน) เท่ากันกับ osu!api map(ทีละอัน) และไม่อยู่ในแมพที่ใช้ไปแล้ว
                        dupli.append(str(p['map_id'])) # เอาแมพนั้นไปใส่ในแมพที่ใช้แล้ว
                        p['result'] = g['scores'] # เอาผลของคะแนนใส่ใน pick นั้นๆ
                        win = check_team_win(g['scores']) # เช็คว่าทีมไหนคะแนนเยอะกว่า
                        score[win] += 1 # เพิ่มคะแนนของทีมในเซ้ตๆนั้น
                        state += 1 # เพิ่มสถานะของเซ็ตนี้
                        multi_games_data.pop(idx) # เอาผลการแข่งนี้ออก

            if score[0] == points_to_win - 1 and score[1] == points_to_win - 1: # ถ้าคะแนนของทีมแต่ละทีม เท่ากันกับ คะแนนที่ต้องการ - 1 (Tiebreaker)
                # หาว่า Tiebreaker คือแมพอะไร
                tie_m = self.query_one("SELECT id, beatmap_id AS map_id, 'tiebreaker' AS 'from', 'pick' AS 'type', info FROM mappool WHERE round_id=%s AND mods='TB'",[fulldata['round']['id']])
                tie_m['info'] = json.loads(tie_m['info'])
                for idx, g in enumerate(multi_games_data): # นำผลที่ได้มาจาก osu!api มาเรียง
                    if str(tie_m['map_id']) == str(g['beatmap_id']) and str(tie_m['map_id']) not in str(dupli): # ถ้าแมพใน pick(ทีละอัน) เท่ากันกับ osu!api map(ทีละอัน) และไม่อยู่ในแมพที่ใช้ไปแล้ว
                        tie_m['result'] = g['scores'] # เอาผลของคะแนนใส่ใน pick นั้นๆ
                        win = check_team_win(g['scores']) # เช็คว่าทีมไหนคะแนนเยอะกว่า
                        score[win] += 1 # เพิ่มคะแนนของทีมในเซ้ตๆนั้น
                        state = 10 # ปรับสถานะของเซ็ตนี้ให้จบไปแล้ว เพราะรอบนี้คือรอบสุดท้าย
                        multi_games_data.pop(idx) # เอาผลการแข่งนี้ออก
                picks.append(tie_m)

            o_sets.append({
                'ban': bans,
                'pick': picks,
                'score': score,
                'state': state
            })
        fulldata['sets'] = o_sets
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
            'round_id', r.id,
            'mp_link', m.mp_link,
            'team1', JSON_OBJECT('id', t1.id, 'full_name', t1.full_name, 'flag_name', t1.flag_name, 'acronym', t1.acronym, 'online', p1.online, 'leader_id', p1.user_id, 'leader_name', p1.username),
            'team2', JSON_OBJECT('id', t2.id, 'full_name', t2.full_name, 'flag_name', t2.flag_name, 'acronym', t2.acronym, 'online', p2.online, 'leader_id', p2.user_id, 'leader_name', p2.username),
            'banpicks', JSON_ARRAYAGG(JSON_OBJECT('id', pb.id, 'set_id', pb.set_id, 'type', pb.type, 'map_id', pb.map_id, 'from', s.full_name, 'info', mp.info, 'mods', mp.mods)),
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

        """
        This part need HowtoplayLN to improve it 
        """
    
        res = json.loads(res['json'])
        mappool = self.query_all("SELECT id, mods, json FROM json_mappool where round_id = %s", res['round_id'])

        # checking it's sets 2?
        prev = self.query_all("SELECT id FROM match_sets WHERE match_id=%s", res['id'])
        if len(prev) >= 2:
            prevbanspicks = self.query_one("""SELECT JSON_ARRAYAGG(JSON_OBJECT('id', pb.id, 'set_id', pb.set_id, 'type', pb.type, 'map_id', pb.map_id, 'from', s.full_name, 'info', mp.info, 'mods', mp.mods)) AS 'last' 
            FROM match_sets ms
            LEFT JOIN `match_sets_banpick` pb ON pb.set_id = ms.id
            LEFT JOIN `mappool` mp ON mp.beatmap_id = pb.map_id
            LEFT JOIN `team` s ON s.id = pb.from
            WHERE ms.id=%s""", res['id'])

        available_maps = []
        for s in mappool:
            d = json.loads(s['json'])
            e = json.loads(prevbanspicks['last'])
            if str(d['beatmap_id']) in str(res['banpicks']) or str(d['mods']) == 'TB' or str(d['mods']) == 'TBSET':
                continue
            else:
                if len(prev) >= 2:
                    if res['banpicks'][0]['from'] != None:
                        try:
                            if d['beatmap_id'] == e[len(res['banpicks'])]['map_id']:
                                continue
                        except IndexError:
                            continue
                    else:
                        if d['beatmap_id'] == e[0]['map_id']:
                            continue

                available_maps.append({
                    'id': s['id'],
                    'mods': s['mods'],
                    'info': d
                })

        if res['banpicks']:
            t = len(res['banpicks']) - 1
            if res['banpicks'][0]['from'] != None:
                if t in [1,3,4]:
                    res['status'] = 'ban'
                else:
                    res['status'] = 'pick'

                if t in [2,4,5]:
                    res['picker'] = res['team1']['leader_id']
                    res['picker_t'] = res['team1']['full_name']
                elif t <= 6:
                    res['picker'] = res['team2']['leader_id']
                    res['picker_t'] = res['team2']['full_name']
                
            elif res['banpicks'][0]['from'] == None:
                res['picker'] = res['team1']['leader_id']
                res['picker_t'] = res['team1']['full_name']
                res['status'] = 'ban'
        res['available_maps'] = available_maps
    
        return res