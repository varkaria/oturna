from flask import Blueprint, render_template, request, session, redirect, url_for
from functools import wraps
from rich.console import Console
from objects import mysql, osuapi
from objects.logger import log

db = mysql.DB()
pickban = Blueprint('pickban', __name__)
console = Console()

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        console.log(dict(session))
        if session == {}:
            return redirect(url_for('pickban.gologin'))
        return f(*args, **kwargs)
    return decorated_function

@pickban.route('/callback')
def callback():
    if request.args.get('state') == 'login':
        u = osuapi.get_token_bp(request.args['code'])
        try:
            user = osuapi.get2(u['access_token'], me='')
            sql = db.query('SELECT id from player WHERE `user_id`=%s',[user['id']])
            if sql:
                login(sql)
                return redirect(url_for('pickban.index'))
            else:
                log.debug(user)
                return redirect(url_for('frontend.index'))
        except Exception as e:
            log.exception(e)
    return redirect(url_for('frontend.index'))

def login(user):
    session.clear()
    session.permanent = True
    session['id'] = user['id']
    session['user_id'] = user['user_id']
    session['username'] = user['username']

@pickban.route('/login/teama/')
def gologin():
    session.clear()
    session.permanent = True
    session['user_id'] = 5726517
    session['username'] = 'Leble'
    return redirect(url_for('pickban.index'))

@pickban.route('/login/teamb/')
def gologin_b():
    session.clear()
    session.permanent = True
    session['user_id'] = 259972
    session['username'] = 'Jakads'
    return redirect(url_for('pickban.index'))
    
@pickban.route('/')
def index():
    return render_template('pickban/pickban.html', data=db.get_match_ban_pick())