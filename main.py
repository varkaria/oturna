from config import Config
from objects.flag import Staff
from flask.json import JSONEncoder
from flask import Flask, send_from_directory, session, redirect, url_for, request
from flask_socketio import SocketIO, send, emit
from datetime import datetime
from functools import wraps
from objects import osuapi, mysql
import re, os
class CustomJSONEncoder(JSONEncoder):
    def default(self, obj):
        try:
            if isinstance(obj, datetime):
                return obj.isoformat()
            iterable = iter(obj)
        except TypeError:
            pass
        else:
            return list(iterable)
        return JSONEncoder.default(self, obj)

db = mysql.DB()
app = Flask(__name__, instance_relative_config=True)
app.config.from_object(Config)
socketio = SocketIO(app)

# Pick ban Socket.io
@socketio.on('firstdata', namespace='/pickban')
def handle_data(d):
    emit(f'data_result_{session["match_set_id"]}', db.get_match_sets_ban_pick_full(session["match_set_id"]))

@socketio.on('pickban', namespace='/pickban')
def handle_data(d):
    if not session:
        return emit('new_result', 'You are not login yet?')
    t_data = db.query('SELECT team as id FROM player WHERE user_id=%s', session['user_id'])
    db.query('INSERT INTO match_sets_banpick (`set_id`, `map_id`, `from`, `type`) VALUES (%s, %s, %s, %s);', [d['set'], d['map'], t_data['id'], d['type']])
    emit(f'new_result_{session["match_set_id"]}', db.get_match_sets_ban_pick_full(session["match_set_id"]), broadcast=True)

@socketio.on('ready', namespace='/pickban')
def handle_data(d):
    if not session:
        return emit('new_result', 'You are not login yet?')
    emit(f'new_result_{session["match_set_id"]}', db.get_match_sets_ban_pick_full(session["match_set_id"]), broadcast=True)

@socketio.on('disconnect', namespace='/pickban')
def handle_dis():
    try:
        db.query("UPDATE `tourney`.`player` SET `online`='0' WHERE `user_id`=%s;", session['user_id'])
    except KeyError:
        print("Someone disconnecting socket with Anonymous person")
    print('disconnect activated')
    emit(f'new_result_{session["match_set_id"]}', db.get_match_sets_ban_pick_full(session["match_set_id"]), broadcast=True)

@socketio.on('connect', namespace='/pickban')
def handle_dis():
    try:
        db.query("UPDATE `tourney`.`player` SET `online`='1' WHERE `user_id`=%s;", session['user_id'])
    except KeyError:
        print("Someone connecting socket with Anonymous person")
    emit(f'new_result_{session["match_set_id"]}', 'connect', broadcast=True)
# End of Pick ban Socket.io

from blueprints.stream import stream
app.register_blueprint(stream, url_prefix='/stream')
from blueprints.backend import backend
app.register_blueprint(backend, url_prefix='/manager')
from blueprints.api import api
app.register_blueprint(api, url_prefix='/api')
from blueprints.frontend import frontend
app.register_blueprint(frontend, url_prefix='/')
from blueprints.pickban import pickban
app.register_blueprint(pickban, url_prefix='/pickban')
app.json_encoder = CustomJSONEncoder

def let_login(user):
    session.clear()
    session.permanent = True
    session['id'] = user['id']
    session['user_id'] = user['user_id']
    session['username'] = user['username']

@app.route('/login')
def callback():
    if request.args.get('code'):
        u = osuapi.get_token(request.args['code'])
        try:
            next_url = request.args.get('state').split('->')
            user = osuapi.get2(u['access_token'], me='')
            player = db.query('SELECT id, user_id, username from player WHERE `user_id`=%s', [user['id']])
            staff = db.get_staff(user_id=user['id'])
            if staff:
                let_login(staff)
                print('Someone Logged to This Website With Staff Perm')
                return redirect(Config.BASE_URL + next_url[1])
            elif player:
                let_login(player)
                print('Someone Logged to This Website With Player Perm')
                return redirect(Config.BASE_URL + next_url[1])
            else:
                return redirect(Config.BASE_URL)
        except Exception as e:
            print(e)
    return redirect(Config.BASE_URL)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(Config.BASE_URL)

@app.route('/favicon.ico')
def faviconico():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'favicon.ico', mimetype='image/vnd.microsoft.icon')

@app.context_processor
def rounds():
    return dict(active_rounds=db.active_rounds)

@app.context_processor
def current_round():
    return dict(current_round=db.current_round)

@app.context_processor
def tourney_info():
    return dict(tourney=db.tourney)

@app.template_filter('num')
def num_filter(num):
    if type(num) == int:
        return f'{num:,}'
    remain_amount = '%0.2f' % (num * 100 / 100.0)
    return re.sub(r"(\d)(?=(\d\d\d)+(?!\d))", r"\1,", remain_amount)

@app.template_filter('floatfix')
def num_filter(num):
    remain_amount = '%0.2f' % (float(num))
    return re.sub(r"(\d)(?=(\d\d\d)+(?!\d))", r"\1,", remain_amount)

@app.template_filter('timef')
def timef(num):
    return '%d:%02d' % (num//60, num%60)

@app.template_filter('datetime')
def dtf(date_time: datetime, sep='T', timespec='auto'):
    return date_time.isoformat(sep, timespec)

@app.template_filter('strdtf')
def strdtf(str_dt: str, sep='T', timespec='auto'):
    return datetime.fromisoformat(str_dt).isoformat(sep, timespec)

@app.template_filter('flag_url')
def flag_url(flag_name: str):
    if not flag_name:
        return ''

    flag_name = flag_name.split('.')
    if flag_name[0] == 'avatar':
        return f'https://a.ppy.sh/{flag_name[1]}'
    elif flag_name[0] == 'local':
        return f'/team_flag/{flag_name[1]}'
    elif flag_name[0] == 'url':
        return flag_name[1]
    elif flag_name[0] == 'none':
        return ''

@app.template_filter('privilege')
def privilege(num):
    return str(Staff(num))[6:].replace('|', ', ')

@app.errorhandler(404)
def page_not_foubd(error):
    return error

if __name__ == '__main__':
    socketio.run(
        app,
        host='127.0.0.1',
        port=int(os.environ.get('PORT', 5000)),
        debug=True
    )