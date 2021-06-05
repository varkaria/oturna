from flask import Blueprint, render_template
from rich.console import Console
from objects.decorators import *
from objects import mysql

db = mysql.DB()
pickban = Blueprint('pickban', __name__)
console = Console()
    
@pickban.route('/<id>')
@login_required
def index(id):
    print(id)
    return render_template('pickban/pickban.html', data=db.get_match_ban_pick())