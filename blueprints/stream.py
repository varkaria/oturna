import os, datetime
from flask import Blueprint, render_template, request, session, current_app, Response, send_file
from objects import mysql

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
    return render_template('stream/greeting_cm.html')

@stream.route('/greeting_host')
def greeting_host():
    return render_template('stream/greeting_host.html')

@stream.route('/showcase')
def m_showcase():
    return render_template('stream/showcase.html')

@stream.route('/match')
def match():
    return render_template('stream/match.html')

@stream.route('/countdown')
def countdown():
    return render_template('stream/countdown.html')

@stream.route('/leaderboard')
def leaderboard():
    return render_template('stream/leaderboard.html')
