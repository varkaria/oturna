from objects import mysql, osuapi
import requests, json

db = mysql.DB()

def conv(x):
    def c(d):
        try:
            return eval(d)
        except Exception:
            return d

d = db.query_all("SELECT * FROM player")
for a in d:
    print(f"Changing STD to Mania {a['username']}")
    args = {'k': 'd90477d1564b8fe36393dfb20ea9b402fb07e8b1', 'u': a['user_id'], 'm': 3}
    player_info = requests.get('https://osu.ppy.sh/api/get_user', args).json()[0]
    player_bp1 = requests.get('https://osu.ppy.sh/api/get_user_best', args).json()[0]
    print(player_info)
    db.query(f"UPDATE `tourney`.`player` SET `info`=%s WHERE `user_id`={a['user_id']};", (json.dumps(player_info)))
    db.query(f"UPDATE `tourney`.`player` SET `bp1`=%s WHERE `user_id`={a['user_id']};", (json.dumps(player_bp1)))
    
print('finished!')