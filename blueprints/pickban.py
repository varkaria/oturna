from flask import Blueprint, render_template, request, jsonify
from objects import mysql

db = mysql.DB()

pickban = Blueprint('pickban', __name__)

@pickban.route('/')
def index(pool_id=db.current_round['id']):
    mappool = db.get_mappool(pool_id)
    if request.args.get('json'):
        return jsonify(mappool) 
    return render_template('pickban/pickban.html', team1='Varkaria', team2='Gusbell', team_choose='Varkaria', state='Ban', mappool=mappool, pool_id=pool_id)
