from config import Config
from functools import wraps
from flask import Blueprint, jsonify, abort, session, request
from werkzeug.exceptions import HTTPException
from pymysql.err import *
from objects import mysql
import json, requests

db = mysql.DB()
api = Blueprint('api', __name__)

funs = {
    'get_mappool': db.get_mappool,
    'get_teams': db.get_teams,
    'get_players': db.get_players,
    'get_matchs': db.get_matchs,
    'get_staff': db.get_staff,
}

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session == {}:
            abort(400, 'no session')
        return f(*args, **kwargs)
    return decorated_function

@api.route('/show/<table_name>')
@login_required
def show_data(table_name):
    def sql():
        try:
            return db.query_all("SELECT * FROM `%s`;" % table_name)
        except Exception:
            abort(404)

    if table_name == '*':
        return jsonify(db.query_all("SHOW TABLE STATUS FROM `tourney`;"))
    elif table_name in funs.keys():
        return jsonify(funs.get(table_name, sql)())
    else:
        abort(404)

@api.route('/data/<table_name>/<id>')
@login_required
def getdata(table_name:str, id:str):
    if table_name in ('group', 'map_group', 'mappool', 'match', 'player', 'round', 'staff', 'team', 'tourney', 'view_staff'):
        if id.isdigit():
            return jsonify(data=db.query_one('select * from `%s` where id = %s limit 1' % (table_name, id)))
        elif id == '*':
            return jsonify(data=db.query_all('select * from `%s`' % table_name))
        else:
            abort(404)
    else:
        abort(404)

@api.route('/m_preduct/<id>')
@login_required
def getdata_preduct(id:int):
    res = db.query_one("SELECT JSON_OBJECT('id', m.id, 'team1', JSON_OBJECT('id', t1.id, 'full_name', t1.full_name, 'flag_name', t1.flag_name, 'acronym', t1.acronym), 'team2', JSON_OBJECT('id', t2.id, 'full_name', t2.full_name, 'flag_name', t2.flag_name, 'acronym', t2.acronym)) AS `json` FROM `match` m LEFT JOIN team t1 ON t1.id = m.team1 LEFT JOIN team t2 ON t2.id = m.team2 where m.id = %s" % (id))
    d = json.loads(res['json'])
    for i in range(2):
        p = db.query_all("SELECT username FROM player WHERE team=%s", (d[f'team{i+1}']['id']))
        d[f'team{i+1}']['players'] = []
        for w in p:
            d[f'team{i+1}']['players'].append(w['username'])
    return jsonify(data=d)

@api.route('/match_mysql/<id>')
@login_required
def getdata_match_mysql(id:int):
    return jsonify(data=db.get_matchs(id=int(id)))
        
@api.route('/check_round')
def check_round():
    if request.args.get('id'):
        return db.query("SELECT COUNT(*) as match_count, r.pool_publish from `match` lnner join `round` as r on r.id=round_id WHERE round_id = %s", (request.args.get('id'),))
    else:
        abort(400, 'id?')

@api.route('/check_map')
def map_round():
    if request.args.get('id'):
        return db.query("SELECT COUNT(*) as map_count, id AS map_id FROM `mappool` WHERE id = %s", (request.args.get('id'),))
    else:
        abort(400, 'id?')

@api.route('/teams/<int:team_id>/')
@login_required
def teams(team_id: int):
    try:
        data = db.query_one("SELECT json FROM `json_team` WHERE id = %s", (team_id,))
        return jsonify(json.loads(data['json']))
    except Exception as e:
        abort(400, e)

@api.route('/maps/<int:map_id>/')
@login_required
def maps(map_id: int):
    try:
        data = db.query_one("SELECT json FROM `json_mappool` WHERE id = %s", (map_id,))
        return jsonify(json.loads(data['json']))
    except Exception as e:
        abort(400, e)

@api.route('/web/<p>')
@login_required
def osuapiv1(p):
    try:
        args = request.args.to_dict()
        args['k'] = Config.OSU_API_KEY
        req = requests.get(
            url = 'https://osu.ppy.sh/api/%s' % p,
            params = args
            )

        result = req.json()
        if result:
            return jsonify(result)
        else:
            return 'no context', 400
    except Exception as e:
        abort(400, e)

@api.errorhandler(HTTPException)
def handle_exception(e):
    return jsonify(error=str(e)), HTTPException.code
