from PIL import Image, ImageFont, ImageDraw

bg = Image.open("images/match_background.png")
draw = ImageDraw.Draw(bg)
title = ImageFont.truetype("fonts/med.ttf", 24)

draw.text((38,65), "Regular Season Phase I | Week 2", font=title)

def match_component():
    im = Image.open("images/match_compoment.png")
    draw = ImageDraw.Draw(im)

    player_title = ImageFont.truetype("fonts/med.ttf", 18)
    team_title = ImageFont.truetype("fonts/black.ttf", 36)
    clock = ImageFont.truetype("fonts/black.ttf", 24)
    score = ImageFont.truetype("fonts/black.ttf", 48)

    # Making Team Picture
    sample = Image.open("images/team_sample.png") # Team 1
    sample2 = Image.open("images/team_sample.png") # Team 2
    sample = sample.resize((88,88), Image.ANTIALIAS)
    sample2 = sample.resize((88,88), Image.ANTIALIAS)
    mask = Image.open("images/team_mask.png").resize(sample.size).convert('L')
    im.paste(sample, (72,60), mask=mask)
    im.paste(sample2, (665,60), mask=mask)

    for i in range(3):
        i = i + 1
        margin = 52
        sets = Image.open(f"images/sets-block/set-blank-{i}.png")
        im.paste(sets, (288+(margin*i),115), sets)
        draw.text((308+(margin*i),150), "1 - 0", font=player_title, anchor='ms')

    # Drawing some text
    draw.text((379,9), "1", font=team_title) # Match of
    draw.text((520,28), "18", font=clock, anchor='ms') # Clock 1
    draw.text((520,46), "00", font=clock, anchor='ms') # Clock 2
    draw.text((179,60), "SimpGura", font=team_title) # Team title | Team 1
    draw.text((179,104), "- Yudachi", font=player_title) # Player 1 | Team 1
    draw.text((179,126), "Iambossize", font=player_title) # Player 1 | Team 1

    draw.text((646,82), "Tomyam", font=team_title, anchor='rm') # Team title | Team 1
    draw.text((646,115), "- Yudachi", font=player_title, anchor='rm') # Player 1 | Team 1
    draw.text((646,137), "Iambossize", font=player_title, anchor='rm') # Player 1 | Team 1

    draw.text((413,106), "0 - 0", font=score, anchor='ms') # Score

    return im

for i in range(3):
    margin = 229
    match = match_component()
    bg.paste(match, (87,180+(margin*i)), match)
    
bg.show()