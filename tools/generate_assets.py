"""Rebuild original placeholder pixel art and synth SFX (Pillow, stdlib)."""
from pathlib import Path
from PIL import Image, ImageDraw
import math, wave, struct

ROOT = Path(__file__).resolve().parents[1]
for folder in ('characters', 'office', 'items', 'ui', 'audio'):
    (ROOT / 'assets' / folder).mkdir(parents=True, exist_ok=True)

def save(im, name):
    im.save(ROOT / 'assets' / name)

# The office is drawn at half the game's internal resolution.
im = Image.new('RGBA', (480, 270), '#172735')
d = ImageDraw.Draw(im)
d.rectangle((0, 35, 479, 145), fill='#829d9c')
d.rectangle((0, 35, 479, 40), fill='#a7bbb0')
d.rectangle((0, 135, 479, 141), fill='#45616a')
d.rectangle((0, 142, 479, 269), fill='#647873')
for y in range(145, 270, 21):
    d.line((0, y, 480, y), fill='#71857c')
    for x in range(-100, 560, 50):
        off = ((y - 145)//21 % 2) * 25
        d.line((x+off, y, x+off-12, y+21), fill='#546d6b')
# Window, sunset skyline and blinds.
d.rectangle((34, 49, 218, 116), fill='#344e61')
d.rectangle((38, 53, 214, 110), fill='#e3b884')
d.rectangle((38, 79, 214, 110), fill='#ad9388')
for x, h in [(40,17),(55,26),(76,21),(94,35),(122,23),(146,30),(175,18),(194,39)]:
    d.rectangle((x,110-h,x+15,110), fill='#74848b')
    for yy in range(113-h,107,7):
        d.rectangle((x+4,yy,x+6,yy+2), fill='#d8bc92')
for y in range(55, 107, 10): d.line((38,y,214,y), fill='#b9c2ad', width=2)
for x in (38, 123, 212): d.rectangle((x,51,x+3,114), fill='#49646c')
d.rectangle((31,115,222,120), fill='#c5c9aa')
# Pinboard.
d.rectangle((244,52,327,104), fill='#354d58')
d.rectangle((248,56,323,100), fill='#a38c71')
for x,y,c in [(253,61,'#dce1c4'),(277,64,'#e8c978'),(299,59,'#d1d9c4'),(286,84,'#b9c9bb')]:
    d.rectangle((x,y,x+17,y+13),fill=c)
    d.rectangle((x+7,y,x+9,y+2),fill='#b05d53')
    d.line((x+3,y+6,x+13,y+6),fill='#86958c')
# Filing cabinets.
d.rectangle((369,66,446,136), fill='#3c5762')
for y in (70,91,112):
    for x in (374,411):
        d.rectangle((x,y,x+30,y+18),fill='#99aaa0')
        d.rectangle((x+10,y+6,x+20,y+9),fill='#49656a')
# Wall clock.
d.rectangle((343,47,359,64),fill='#273f50')
d.rectangle((345,49,357,62),fill='#e8e4c4')
d.line((351,51,351,56,355,58),fill='#50666b',width=1)
# Plant and bin.
d.rectangle((15,132,28,152),fill='#b78065')
d.rectangle((13,130,30,134),fill='#d1a07c')
d.line((22,132,22,106),fill='#344e4b',width=2)
for b in [(9,110,21,116),(23,103,32,111),(11,119,22,124),(22,115,34,121)]: d.rectangle(b,fill='#3c745f')
d.rectangle((450,166,463,187),fill='#3c565f')
d.line((451,166,462,166),fill='#8b9e95',width=2)
# Desk shadows and chairs.
for cx in (122,238,354):
    d.rectangle((cx-43,182,cx+51,213),fill='#4b625f')
    d.rectangle((cx-13,127,cx+14,156),fill='#263d50')
    d.rectangle((cx-11,128,cx+11,143),fill='#496573')
    d.rectangle((cx-2,178,cx+2,209),fill='#263d50')
    d.line((cx-16,210,cx+16,210),fill='#263d50',width=3)
save(im,'office/background.png')

fg = Image.new('RGBA',(480,270))
d = ImageDraw.Draw(fg)
for cx in (122,238,354):
    d.polygon([(cx-49,156),(cx+41,156),(cx+53,181),(cx-38,181)],fill='#d5bb8d')
    d.line((cx-48,157,cx+40,157,cx+51,180), fill='#efe0b1',width=2)
    d.rectangle((cx-38,182,cx+53,187), fill='#9e795d')
    for x in (cx-34,cx+45): d.rectangle((x,188,x+4,214),fill='#344d54')
    d.rectangle((cx+15,189,cx+42,206),fill='#9b8b70')
    d.rectangle((cx+25,193,cx+33,195),fill='#4b6260')
    # monitor backs, keyboards, mugs
    d.rectangle((cx-26,147,cx+1,167),fill='#253e50')
    d.rectangle((cx-24,149,cx-1,163),fill='#476778')
    d.rectangle((cx-23,149,cx-2,151),fill='#658992')
    d.rectangle((cx-16,166,cx-10,171),fill='#314957')
    d.rectangle((cx-22,171,cx-5,173),fill='#415d66')
    d.polygon([(cx+3,169),(cx+23,169),(cx+27,175),(cx+7,175)],fill='#6a7d79')
    for yy in (170,172): d.line((cx+6,yy,cx+21,yy),fill='#a9b6a0')
    d.rectangle((cx-33,171,cx-28,176),fill='#dce4c6')
    d.rectangle((cx-35,172,cx-33,174),fill='#dce4c6')
save(fg,'office/desks.png')

def person(shirt, pose):
    im = Image.new('RGBA',(48,64)); d=ImageDraw.Draw(im)
    ink='#23384b'; skin='#e7b58e'; shadow='#c08b70'; hair='#303d4c'
    d.rectangle((15,43,22,61),fill=ink);d.rectangle((27,43,34,61),fill=ink)
    d.rectangle((12,60,22,63),fill=ink);d.rectangle((27,60,37,63),fill=ink)
    d.rectangle((12,27,36,47),fill=ink);d.rectangle((14,28,34,46),fill=shirt)
    d.rectangle((23,29,25,42),fill='#cf735e')
    d.rectangle((21,23,28,29),fill=shadow)
    x=3 if pose in ('phone','talk') else (-3 if pose=='caught' else 0)
    y=3 if pose=='sad' else 0
    d.rectangle((15+x,7+y,32+x,23+y),fill=skin)
    d.rectangle((12+x,12+y,15+x,19+y),fill=shadow)
    d.rectangle((14+x,5+y,32+x,10+y),fill=hair)
    d.rectangle((12+x,8+y,17+x,14+y),fill=hair)
    d.rectangle((28+x,9+y,32+x,13+y),fill=hair)
    if pose in ('phone','talk'):
        d.rectangle((29+x,14+y,30+x,16+y),fill=ink)
        d.rectangle((32+x,17+y,35+x,20+y),fill=skin)
    elif pose=='happy':
        d.line((18,15,21,14),fill=ink);d.line((26,14,29,15),fill=ink)
        d.rectangle((21,20,27,21),fill='#9d514b')
    elif pose=='sad':
        d.line((18,15+y,21,14+y),fill=ink)
        d.line((26,14+y,29,15+y),fill=ink)
        d.line((18,18+y,21,19+y),fill=ink)
        d.line((26,19+y,29,18+y),fill=ink)
        d.line((21,23+y,23,22+y,25,22+y,27,23+y),fill='#9d655d')
        d.rectangle((29,20+y,30,23+y),fill='#9fc3d2')
    else:
        d.rectangle((18+x,15+y,19+x,17+y),fill=ink)
        d.rectangle((27+x,15+y,28+x,17+y),fill=ink)
        d.line((21+x,21+y,26+x,21+y),fill='#9d655d')
    if pose=='steal':
        d.rectangle((32,31,47,36),fill=shirt);d.rectangle((43,32,47,36),fill=skin)
    elif pose=='happy':
        d.rectangle((7,18,12,33),fill=shirt);d.rectangle((7,14,12,19),fill=skin)
        d.rectangle((36,18,41,33),fill=shirt);d.rectangle((36,14,41,19),fill=skin)
    elif pose=='phone':
        d.rectangle((34,19,39,35),fill=shirt);d.rectangle((34,15,39,22),fill=skin)
        d.rectangle((36,11,40,22),fill='#213447')
    elif pose=='talk':
        d.rectangle((34,29,44,33),fill=shirt);d.rectangle((41,25,45,30),fill=skin)
    else:
        d.rectangle((10,30,14,42),fill=shirt);d.rectangle((34,30,38,42),fill=shirt)
        d.rectangle((10,41,14,45),fill=skin);d.rectangle((34,41,38,45),fill=skin)
    return im

for who,col in [('sawano','#d9b76b'),('target','#9fc3c2'),('coworker','#c58d83')]:
    for pose in ('working','phone','talk','caught','steal','happy','sad'):
        save(person(col,pose),f'characters/{who}_{pose}.png')
banana=Image.new('RGBA',(24,20));d=ImageDraw.Draw(banana)
d.polygon([(3,4),(6,10),(11,13),(17,12),(21,6),(21,13),(17,17),(9,18),(4,15),(1,9)],fill='#b78a35')
d.polygon([(3,3),(6,9),(11,12),(17,11),(21,5),(20,12),(16,15),(9,16),(4,13),(2,8)],fill='#f4cd55')
d.line((4,5,7,11,12,14,17,13),fill='#fff0a0',width=2)
d.rectangle((19,2,21,5),fill='#627658');save(banana,'items/banana.png')
paper=Image.new('RGBA',(24,20));d=ImageDraw.Draw(paper)
d.rectangle((3,5,21,18),fill='#a2ae9e');d.rectangle((1,1,19,15),fill='#f0e9c7')
for y in (5,8,11):d.line((4,y,15,y),fill='#809b99')
save(paper,'items/task.png')
phone=Image.new('RGBA',(24,20));d=ImageDraw.Draw(phone)
d.rectangle((3,8,21,17),fill='#334c5c');d.rectangle((1,4,23,9),fill='#223647')
for x in (8,12,16):
    for y in (11,14): d.point((x,y),fill='#b6c8b3')
save(phone,'items/phone.png')
# Short, original synthesized sound effects. Replace WAV files freely.
for name, notes in {
    'phone_ring':[(740,.09),(980,.09),(0,.08),(740,.09),(980,.09)],
    'steal_success':[(520,.065),(780,.065),(1040,.13)],
    'banana_get':[(659,.065),(880,.065),(1108,.09),(1320,.20)],
    'caught':[(185,.11),(155,.13),(110,.22)],
    'game_over':[(330,.15),(294,.15),(247,.15),(165,.35)]
}.items():
    data=[]
    for hz,seconds in notes:
        for i in range(int(22050*seconds)):
            t=i/22050; env=min(1,t/.008)*max(0,1-t/seconds)**1.4
            s=(1 if math.sin(2*math.pi*hz*t)>0 else -1) if hz else 0
            data.append(struct.pack('<h',int(4200*s*env)))
    with wave.open(str(ROOT/'assets'/'audio'/f'{name}.wav'),'wb') as w:
        w.setparams((1,2,22050,0,'NONE','not compressed'));w.writeframes(b''.join(data))
print('Original pixel PNGs and five WAV effects generated.')
