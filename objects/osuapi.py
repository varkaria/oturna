import requests
from config import Config

CLIENT_ID = Config.OSU_CLIENT_ID
CLIENT_SCERET = Config.OSU_CLIENT_SCERET
REDIRECT_URL = Config.BASE_URL + '/login'
API_KEY = Config.OSU_API_KEY

def todata(value):
    try:
        return eval(value)
    except:
        return value

class V1Path:
    get_beatmaps = 'get_beatmaps'
    get_user = 'get_user'
    get_user_best = 'get_user_best'
    get_user_recent = 'get_user_recent'
    get_scores = 'get_scores'
    get_match = 'get_match'
    get_replay = 'get_replay'

def authorize(state, scope, goto):
    return f"https://osu.ppy.sh/oauth/authorize?response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URL}&state={state}->{goto}&scope={scope}"

def toen_isactive(Token):
    url = 'https://osu.ppy.sh/api/v2/me'
    headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {Token}'}
    
    req = requests.get(url, headers=headers)
    if req.status_code == 200:
        return True
    else:
        return False

def get_token(code):
    url = "https://osu.ppy.sh/oauth/token"

    payload = f'grant_type=authorization_code&client_id={CLIENT_ID}&client_secret={CLIENT_SCERET}&redirect_uri={REDIRECT_URL}&code={code}'
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}

    r = requests.post(url, headers=headers, data=payload)
    if r.status_code == 400:
        return None
    return r.json()

def get(path:V1Path, **args):
    args['k'] = API_KEY
    req = requests.get(
        url = 'https://osu.ppy.sh/api/' + path,
        params = args
        )

    return req.json()

def get2(token, **kargs):
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
               
    path = ''
    a = []
    for p in kargs.items():
        for q in p:
            a.append(str(q))
    path = '/'.join(a)
    req = requests.get(f'https://osu.ppy.sh/api/v2/{path}', headers=headers)
    return req.json()
