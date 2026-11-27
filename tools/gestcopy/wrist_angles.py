#!/usr/bin/env python3
"""wrist_angles.py -- the numbers behind the wrist check's angles (gestcopy_template.zs, THE WRIST CHECK, 2026-11-27).
Prints how many degrees off square the back or the inside of a wrist is to the eyes in a watch check, a pulse check and
with a gun held out to aim, by the same formula as the template's FaceOff. Arithmetic only: nothing here was measured on
a rig or a headset.    python3 tools/gestcopy/wrist_angles.py"""
import math, itertools
def back(y,p,r,left):
    y=math.radians(y);p=math.radians(p);r=math.radians(r)
    f=(math.cos(p)*math.cos(y),math.cos(p)*math.sin(y),math.sin(p))
    r0=(math.sin(y),-math.cos(y),0)
    u0=(r0[1]*f[2]-r0[2]*f[1], r0[2]*f[0]-r0[0]*f[2], r0[0]*f[1]-r0[1]*f[0])
    # controller right = r0 cos r - u0 sin r ; back of right hand = right, of left hand = -right
    s=-1 if left else 1
    return tuple(s*(r0[i]*math.cos(r)-u0[i]*math.sin(r)) for i in range(3))
def dot(n,hand):
    to=tuple(-c for c in hand); d=math.sqrt(sum(c*c for c in to))
    return sum(n[i]*to[i] for i in range(3))/d
def off(x): return math.degrees(math.acos(max(-1,min(1,x))))
print("RIGHT watch: yaw(fwd=0, left=90) pitch tilt(b=-roll) hand(x fwd, y left, z up) -> degrees off square of the BACK")
for hand in [(0.35,0.0,-0.30),(0.40,-0.10,-0.20),(0.30,0.05,-0.40),(0.45,0,-0.10)]:
  for y in (40,70,90):
    for p in (0,25):
      print(hand,y,p,[round(off(dot(back(y,p,-b,False),hand))) for b in (30,45,60,80,90)])
print("AIM right hand, gun upright roll 0, forward: back / inside off-square")
for hand in [(0.5,-0.15,-0.15),(0.6,-0.05,-0.08),(0.45,-0.25,-0.25),(0.3,-0.2,-0.5),(0.55,0,-0.1)]:
  for r in (0,-20,20):
    d=dot(back(0,0,r,False),hand); print(hand,r,round(off(d)),round(off(-d)))
print("LEFT (off) pulse: forearm up/ across, palm to face; roll for left: back=+90 -> inside up = -90")
for hand in [(0.35,0.10,-0.25),(0.30,0.15,-0.10),(0.40,0.05,-0.35)]:
  for y in (0,-40,-80):
    for p in (0,30,60):
      print(hand,y,p,[round(off(-dot(back(y,p,r,True),hand))) for r in (0,-30,-45,-60,-90)])
