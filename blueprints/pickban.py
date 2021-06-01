from flask import Blueprint, render_template

pickban = Blueprint('pickban', __name__)

@pickban.route('/')
def index():
    return render_template('pickban/pickban.html')