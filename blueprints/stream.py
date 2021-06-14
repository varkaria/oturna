import os, datetime
from flask import Blueprint, render_template, request, session, current_app, Response, send_file
from objects import mysql

db = mysql.DB()
stream = Blueprint('stream', __name__)

BRACKETS_FOLDER = '.data/brackets'
FILE_EX = {'json'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in FILE_EX

@stream.route('/')
def showlist():
    return render_template('stream/stream_list.html')

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
def greeting_daniel():
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

@stream.route('/json/upload', methods=['GET', 'POST'])
def json_upload():
    if request.method == 'POST':
        file = request.files['file']
        if file.filename == '':
            error = 'No file chosen'
            return render_template('stream/json_upload.html', error=error)
        if file and allowed_file(file.filename):
            try:
                now = datetime.datetime.now()
                id = str(session['user_id'])
                date_time = now.strftime("%d-%m-%Y")
                filename = '[' + id + ']' + ' ' + date_time + '.json'
                file.save(os.path.join(BRACKETS_FOLDER, filename))
                error = 'File upload successfully'
                return render_template('stream/json_upload.html', error=error)
            except KeyError:
                error = 'You need to login to upload this file'
                return render_template('stream/json_upload.html', error=error)
        else:
            error = 'Invalid file type'
            return render_template('stream/json_upload.html', error=error)
    return render_template('stream/json_upload.html')

@stream.route('/json/download/', methods=['GET', 'POST'])
def download_file():
    path = BRACKETS_FOLDER
    list_brackets = {}
    try:
        id = str(session['user_id'])
        if os.listdir(path) != []:
            for filename in os.listdir(path):
                list_brackets[filename] = filename
                print(filename)
            return render_template('stream/json_download.html', filename=filename, list_brackets=list_brackets)
        else:
            error = 'No json uploaded'
            return render_template('stream/json_download.html', error=error)
    except KeyError:
        error = 'You need to login to view the file'
        return render_template('stream/json_download.html', error=error)
    
@stream.route('/json/download/<path:filename>', methods=['GET', 'POST'])
def download(filename):
    file = os.path.join(current_app.root_path, BRACKETS_FOLDER) + '/' +filename
    response = send_file(file, mimetype='application/json',attachment_filename='brackets.json', as_attachment=True)
    response.headers["x-filename"] = 'brackets.json'
    response.headers["Access-Control-Expose-Headers"] = 'x-filename'
    return response
