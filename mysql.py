import pymysql, os, json
from datetime import datetime
from pymysql.cursors import DictCursor
from config import Config
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
        mappool = {}
        round = self.query_one(f"SELECT * FROM round WHERE id = {round_id}")
        pooldata = self.query_all(f"SELECT m.*, mg.hex_color, s.user_id, s.username FROM mappool AS m LEFT JOIN staff AS s ON s.id=m.nominator LEFT JOIN map_group AS mg ON mg.name=m.mods WHERE round_id = {round_id} ORDER BY FIELD(`mods`, 'FM', 'NM', 'HD', 'HR', 'DT', 'Roll', 'EZ', 'TB'), code")
        if round['pool_publish'] or ingore_pool_publish:
            if format:
                for map in pooldata:
                    map['info'] = json.loads(map['info'])
                for map in pooldata:
                    if map['mods'] not in mappool.keys():
                        mappool[map['mods']] = []
                    mappool[map['mods']].append(map)
                return {
                    'round_id': int(round_id),
                    'mappool': mappool
                    }
            else:
                for map in pooldata:
                    map['info'] = json.loads(map['info'])
                return pooldata
       

    @property
    def active_rounds(self):
        rounds = self.query_all("SELECT * FROM round WHERE start_date < NOW()")
        return rounds

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
            'round', JSON_OBJECT('id', r.id, 'name', r.name, 'description', r.description, 'best_of', r.best_of, 'start_date', DATE_FORMAT(r.start_date, '%Y-%m-%d %H:%i')),
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
            'note', m.note,
            'winpoint', CEIL(r.best_of/2+1)
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
        matchs = []
        query = self.query_all(query_text)
        for m in query:
            matchs.append(json.loads(m['json']))

        return matchs

    def get_staff(self, staff_id=None, user_id=None, format=True, viewall=False):
        if user_id:
            query = self.query_one('select * from staff where user_id = %s and active = 1', (user_id,))
            return query

        if staff_id:
            query = self.query_one('select * from staff where id = %s and active = 1', (staff_id,))
            return query

        va = 'WHERE s.active = 1 ORDER BY s.active, s.id' if not viewall else 'ORDER BY s.id'

        query = self.query_all('SELECT s.id, s.user_id, s.username, s.privileges, s.active, g.* FROM staff s INNER JOIN `group` g ON g.id = s.group_id ' + va)
        if format:
            staff = {}
            for s in query:
                if s['th_name'] not in staff.keys():
                    staff[s['th_name']] = []
                staff[s['th_name']].append(s)
            return staff
        else:
            return query