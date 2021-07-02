from blueprints.frontend import matchs
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
    next = db.query_one("SELECT date FROM `match` WHERE DATE > NOW() ORDER BY id DESC LIMIT 1")
    return render_template('stream/countdown.html', date=next['date'])

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
    if preducts:
        return render_template('stream/comment_preduction/preduction_match.html', preducts=preducts)
    
    return b'uwu'
    
@stream.route('/comment_match/<id>')
def commentator_match_id(id:int):
    preducts = db.query_all(f"SELECT cp.commentator, tw.full_name, tw.flag_name, tw.id, st.user_id, st.username, cp.s_team1, cp.s_team2, t1.full_name AS `team1`, t2.full_name AS `team2` FROM `com_preducts` `cp` LEFT JOIN `staff` `st` ON st.id = cp.commentator LEFT JOIN `team` `tw` ON tw.id = cp.s_win LEFT JOIN `match` `m` ON m.id = cp.match_id LEFT JOIN `team` `t1` ON t1.id = m.team1 LEFT JOIN `team` `t2` ON t2.id = m.team2 WHERE match_id=%s", (id))
    if preducts:
        return render_template('stream/comment_preduction/preduction_match.html', preducts=preducts)
    
    return b'uwu'

@stream.route('/incoming')
def incoming_match():
    data = db.query_one("SELECT t1.json AS `t1`, t2.json AS `t2` FROM `match` LEFT JOIN `json_team` `t1` ON `t1`.`id`=`match`.`team1` LEFT JOIN `json_team` `t2` ON `t2`.`id`=`match`.`team2` WHERE DATE < NOW() AND stats=0 ORDER BY match.id DESC LIMIT 1")
    if data:
        t1, t2 = json.loads(data['t1']), json.loads(data['t2'])
        return render_template('stream/incoming_match.html', t1=t1, t2=t2)

    return 'uwu'

@stream.route('/ingame')
def ingame_match():
    lastest = db.query_one("SELECT `match_sets`.id FROM `match_sets` LEFT JOIN `match` ON `match`.id=`match_sets`.match_id WHERE DATE < NOW() AND finish_ban=0 ORDER BY id DESC LIMIT 1")
    return render_template('stream/ingame_match.html', set=lastest['id'])

@stream.route('/schedule')
def schedule():
    next = db.query_one("SELECT date FROM `match` WHERE DATE > NOW() ORDER BY id DESC LIMIT 1")
    list = db.query_all("SELECT team1, team2, DATE_FORMAT(`match`.`date`,'%H:%i') AS `time`, `stats`, team1_score, team2_score, `t1`.full_name AS `team1_name` , `t2`.full_name AS `team2_name` FROM `match` LEFT JOIN `team` `t1` ON `t1`.id = `match`.`team1` LEFT JOIN `team` `t2` ON `t2`.id = `match`.`team2` WHERE DATE(`date`) = DATE(CURDATE())")
    return render_template('stream/schedule.html', matchs=list, count=next['date'])