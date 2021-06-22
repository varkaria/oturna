from PIL import Image, ImageFont, ImageDraw, ImageOps

im = Image.open("images/background.png")
draw = ImageDraw.Draw(im)

default = ImageFont.truetype("fonts/med.ttf", 48)
bold = ImageFont.truetype("fonts/black.ttf", 48)

margin = 110
teams = 6

for i in range(teams):
    sample = Image.open("images/team_sample.png")
    sample = sample.resize((201,201), Image.ANTIALIAS)
    sample = ImageOps.crop(sample, (0,72,0,65))
    mask = Image.open("images/team_mask.png").resize(sample.size).convert('L')
    im.paste(sample, (334,258+(margin*i)), mask=mask)
    
    # Drawing some text
    draw.text((562, 262+(margin*i)), "Varkaria", font=default)
    draw.text((1360, 302+(margin*i)), "21", font=default, anchor='ms')
    draw.text((1503, 302+(margin*i)), "2 - 8", font=default, anchor='ms')
    draw.text((1645, 302+(margin*i)), "51", font=bold, anchor='ms')

im.show()
im.save('wtf.png')