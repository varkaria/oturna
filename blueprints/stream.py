from flask import Blueprint, render_template, request
from objects import mysql
import json

db = mysql.DB()
stream = Blueprint('stream', __name__)

@stream.route('/bg')
def background():
    songpos = request.args.get('songpos')

    if request.args.get('t'):
        title = request.args.get('t')
    else:
        title = ''

    if request.args.get('s'):
        subtitle = request.args.get('s')
    else:
        subtitle = ''

    if songpos not in ['left', 'right', 'center']:
        return 'wrong value in args man'

    return render_template('stream/background.html', songpos=songpos, title=title, subtitle=subtitle)

@stream.route('/greeting_cm')
def greeting_cm():
    return render_template('stream/greeting/greeting_cm.html')

@stream.route('/greeting_host')
def greeting_host():
    return render_template('stream/greeting/greeting_host.html')

@stream.route('/countdown')
def countdown():
    return render_template('stream/countdown.html')

@stream.route('/leaderboard')
def leaderboard():
    data = db.query_all("SELECT * FROM `tourney`.`team` ORDER BY `points` DESC;")
    return render_template('stream/leaderboard.html', d=data)

@stream.route('/comment_points')
def commentator_points():
    score = db.query_all("SELECT c_score AS `a` FROM `tourney`.`staff` ORDER BY `id` ASC;")
    return render_template('stream/comment_preduction/preduction_points.html', s=score)

@stream.route('/comment_match')
def commentator_match():
    lastest = db.query_one("SELECT id FROM `match` WHERE DATE < NOW() ORDER BY id DESC LIMIT 1")
    preducts = db.query_all(f"SELECT cp.commentator, tw.full_name, tw.flag_name, tw.id, st.user_id, st.username, cp.s_team1, cp.s_team2, t1.full_name AS `team1`, t2.full_name AS `team2` FROM `com_preducts` `cp` LEFT JOIN `staff` `st` ON st.id = cp.commentator LEFT JOIN `team` `tw` ON tw.id = cp.s_win LEFT JOIN `match` `m` ON m.id = cp.match_id LEFT JOIN `team` `t1` ON t1.id = m.team1 LEFT JOIN `team` `t2` ON t2.id = m.team2 WHERE match_id=%s AND finish = 0", (lastest['id']))
    return render_template('stream/comment_preduction/preduction_match.html', preducts=preducts)

@stream.route('/comment_match/<id>')
def commentator_match_id(id:int):
    preducts = db.query_all(f"SELECT cp.commentator, tw.full_name, tw.flag_name, tw.id, st.user_id, st.username, cp.s_team1, cp.s_team2, t1.full_name AS `team1`, t2.full_name AS `team2` FROM `com_preducts` `cp` LEFT JOIN `staff` `st` ON st.id = cp.commentator LEFT JOIN `team` `tw` ON tw.id = cp.s_win LEFT JOIN `match` `m` ON m.id = cp.match_id LEFT JOIN `team` `t1` ON t1.id = m.team1 LEFT JOIN `team` `t2` ON t2.id = m.team2 WHERE match_id=%s", (id))
    return render_template('stream/comment_preduction/preduction_match.html', preducts=preducts)

@stream.route('/incoming')
def incoming_match():
    data = db.query_one("SELECT t1.json AS `t1`, t2.json AS `t2` FROM `match` LEFT JOIN `json_team` `t1` ON `t1`.`id`=`match`.`team1` LEFT JOIN `json_team` `t2` ON `t2`.`id`=`match`.`team2` WHERE DATE < NOW() ORDER BY match.id DESC LIMIT 1")
    t1 = json.loads(data['t1'])
    t2 = json.loads(data['t2'])
    return render_template('stream/incoming_match.html', t1=t1, t2=t2)

@stream.route('/ingame')
def ingame_match():
    return render_template('stream/ingame_match.html')
