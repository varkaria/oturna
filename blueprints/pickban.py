from flask import Blueprint, render_template
from requests.api import get
from rich.console import Console
from objects.decorators import *
from objects import mysql

db = mysql.DB()
pickban = Blueprint('pickban', __name__)
console = Console()

def get_leaders_match(id):
    out = db.query(f'''SELECT JSON_OBJECT('id', m.id, 'team1', JSON_OBJECT('leader_id', p1.user_id), 'team2', JSON_OBJECT('leader_id', p2.user_id)) AS `json`
    FROM `match` m
    LEFT JOIN `team` t1 ON t1.id = m.team1
    LEFT JOIN `team` t2 ON t2.id = m.team2
    LEFT JOIN `player` p1 ON p1.team = t1.id
    AND p1.leader = 1
    LEFT JOIN `player` p2 ON p2.team = t2.id
    AND p2.leader = 1
    WHERE m.id={id}
    ''')
    return out['json']

@pickban.route('/')
def index():
    return '<h1>Hi uwu</h1>'

@pickban.route('/<code>')
@login_required
def pickban_main(code):
    set_match = db.query('SELECT id, match_id FROM match_sets WHERE `random`=%s',[code])
    
    if set_match:
        session['match_set_id'] = set_match['id']
        if str(session['user_id']) not in str(get_leaders_match(set_match['match_id'])):
            return "you aren't being the leader of this match"
        return render_template('pickban/pickban.html', match_code=code, match_set=set_match['id'] )

    return '<h1>Hi uwu 2</h1>'

@pickban.route('/<code>/spectator')
def pickban_spec(code):
    set_match = db.query('SELECT id, match_id FROM match_sets WHERE `random`=%s',[code])
    if set_match:
        session['match_set_id'] = set_match['id']
    return render_template('pickban/pickban_spec.html', match_code=code, match_set=set_match['id'])

@pickban.route('/recent/spectator')
def pickban_spec_recent(code):
    set_match = db.query('SELECT id, match_id FROM match_sets WHERE `random`=%s',[code])
    if set_match:
        session['match_set_id'] = set_match['id']
    return render_template('pickban/pickban_spec.html', match_code=code, match_set=set_match['id'])