from config import Config
from objects.flag import Staff
from flask.json import JSONEncoder
from flask import Flask, send_from_directory
from datetime import datetime
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

sql = mysql.DB()
app = Flask(__name__, instance_relative_config=True)
app.config.from_object(Config)

from blueprints.stream import stream
app.register_blueprint(stream, url_prefix='/stream')
from blueprints.backend import backend
app.register_blueprint(backend, url_prefix='/manager')
from blueprints.api import api
app.register_blueprint(api, url_prefix='/api')
from blueprints.frontend import frontend
app.register_blueprint(frontend, url_prefix='/')

app.json_encoder = CustomJSONEncoder

@app.route('/favicon.ico')
def faviconico():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'favicon.ico', mimetype='image/vnd.microsoft.icon')

@app.context_processor
def rounds():
    return dict(active_rounds=sql.active_rounds)

@app.context_processor
def current_round():
    return dict(current_round=sql.current_round)

@app.context_processor
def tourney_info():
    return dict(tourney=sql.tourney)

@app.context_processor
def authorize():
    return dict(authorize=osuapi.authorize('login','identify'))
    
@app.template_filter('num')
def num_filter(num):
    if type(num) == int:
        return f'{num:,}'
    remain_amount = '%0.2f' % (num * 100 / 100.0)
    remain_amount_format =re.sub(r"(\d)(?=(\d\d\d)+(?!\d))", r"\1,", remain_amount)
    return remain_amount_format

@app.template_filter('floatfix')
def num_filter(num):
    remain_amount = '%0.2f' % (float(num))
    remain_amount_format =re.sub(r"(\d)(?=(\d\d\d)+(?!\d))", r"\1,", remain_amount)
    return remain_amount_format

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
    if flag_name:
        flag_name = flag_name.split('.')
        if flag_name[0] == 'avatar':
            return f'https://a.ppy.sh/{flag_name[1]}'
        elif flag_name[0] == 'local':
            return f'/team_flag/{flag_name[1]}'
        elif flag_name[0] == 'url':
            return flag_name[1]
        elif flag_name[0] == 'none':
            return ''
    else:
        return ''

@app.template_filter('privilege')
def privilege(num):
    return str(Staff(num))[6:].replace('|', ', ')

@app.errorhandler(404)
def page_not_foubd(error):
    return error

if __name__ == '__main__':
    app.run(
        host='127.0.0.1',
        port=int(os.environ.get('PORT', 5000))
    )
