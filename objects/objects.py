def check_team_win(scores):
    # fetch only team 1 2 and score
    scr = list(map(lambda x: {'team': int(x['team']), 'score': int(x['score'])}, scores))
    # get team that has max score
    team_win = max(scr, key=lambda s: s['score'])
    x = team_win['team'] - 1
    if x == 0: return 1
    if x == 1: return 0