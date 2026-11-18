"""Generate the four original study sprites and a soft wooden click."""
from PIL import Image, ImageDraw
import math, random, struct, wave
from pathlib import Path
root=Path(__file__).resolve().parents[1]/'assets'
rim='#745237'; ivory='#f0d4a1'; glint='#fff0c5'
def sprite(name,size,draw):
    im=Image.new('RGBA', size)
    d=ImageDraw.Draw(im)
    def joint(x,y,r):
        d.ellipse((x-r,y-r,x+r,y+r),fill=ivory,outline=rim,width=2)
    def bone(points,w):
        d.line(points,fill=rim,width=w+4,joint='curve')
        d.line(points,fill=ivory,width=w,joint='curve')
        joint(*points[0],max(3,w//2));joint(*points[-1],max(3,w//2))
    draw(d,bone,joint)
    im.save(root/'images'/f'{name}.png')
def skull(d,b,j):
    d.polygon([(5,27),(18,9),(46,5),(66,17),(99,21),(125,34),(123,48),(96,49),(75,45),(54,48),(33,54),(12,46)],fill=ivory,outline=rim,width=3)
    for x,y,r in [(40,23,9),(64,31,7),(109,33,3)]:
        d.ellipse((x-r,y-r,x+r,y+r),fill=(0,0,0,0),outline=rim,width=2)
    for x in range(58,119,9):
        d.polygon([(x,45),(x+6,46),(x+2,54)],fill=glint,outline=rim)
    b([(19,46),(47,62),(82,61),(117,54)],5)
def torso(d,b,j):
    b([(6,45),(45,30),(86,28),(119,25),(148,10)],9)
    for i in range(8):
        x=27+i*12;y=31-int(i*.7);l=int(35*math.sin((i+1)*.34))+12
        b([(x,y),(x+7,y+9),(x+5,y+l//2),(x-6,y+l)],4)
    for i in range(9): j(12+i*12,40-min(i*2,15),5)
    b([(111,44),(117,56),(130,56)],3)
def tail(d,b,j):
    for i in range(16):
        x=5+8*i;y=int(12+34*math.sin(i*.11))
        b([(x,y),(x+8,int(12+34*math.sin((i+1)*.11)))],2+i//3)
        if i>5:b([(x,y),(x-2,y+7)],2)
def legs(d,b,j):
    for dx,dy in [(20,-2),(0,4)]:
        p=[(24+dx,9+dy),(41+dx,35+dy),(19+dx,64+dy),(30+dx,87+dy)]
        for a,c,w in zip(p,p[1:],[10,7,5]):b([a,c],w)
        for off in [0,5,10]: b([p[-1],(40+dx+off,91+dy-off//3)],3)
    b([(8,10),(28,5),(52,9)],9)
sprite('skull',(130,68),skull);sprite('torso',(156,94),torso)
sprite('tail',(138,60),tail);sprite('legs',(82,102),legs)
rng=random.Random(23)
with wave.open(str(root/'audio'/'snap.wav'),'wb') as f:
    f.setparams((1,2,22050,0,'NONE','not compressed'))
    for i in range(3308):
        t=i/22050
        a=(math.sin(t*2*math.pi*490)*.35+rng.uniform(-.2,.2))*math.exp(-48*t)
        f.writeframesraw(struct.pack('<h',int(a*28000)))
