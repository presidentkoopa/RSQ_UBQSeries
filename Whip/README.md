# RSQ Whip

A real bullwhip in your hand: a simulated leather thong that cracks when you snap your wrist, wraps round monsters,
pulls them to you, and catches a beam so you can swing across the room.

Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes.

## Standout feature: a whip that is actually a whip

Nothing here is animated. The thong is 25 links of simulated leather, 1.8 m long, built on the numbers of a research
whip from MIT's Newman Lab: its bend stiffness, damping, link length and weight, node for node. It hangs from your
hand under gravity and follows whatever your hand does. A lazy swing just swings. Lift and snap your forearm, or
flick your wrist, and the loop runs down the thong until the tip breaks the speed of a crack, right where it arrives.

What the crack meets, it hits: harder the faster the tip, knocking a monster into its pain so its attack breaks off.
It throws a switch it lands on and flicks a loose pickup to you. If the tip catches an edge above your hand, a beam,
a lintel, a ledge, it wraps round it and becomes a rope: swing on it, reel yourself up, climb it hand over hand, and
let go at the top with all your speed.

## Features

**The whip weapon** (slot 1, in either hand)
- Always out while it is in your hand: swing it and it cracks.
- Hold the trigger and point: a mark shows the target, switches, keys and powerups nearby first. Crack, and the whip
  flies out to it. Alt fire moves the mark to the next target. Lift the hand for the crack and the mark stays.
- Wrapped round a monster, it swings with your arm at the rope's length and smashes the monster into others (keep the
  trigger held). Pull back hard and you yank it: light monsters fly to you, heavier ones stagger, and past a certain
  weight the yank swings you to them instead.
- The lasso: close your other hand on the thong and whirl it as fast as that hand drives it. Let go and it flies out
  and ropes the monster nearest that way.
- Hand on the Handle: Brutal Doom 22 VR Reloaded's hand wraps the handle.
- Never targets Kill Rewards' little bits.

**Aimed swing**
- Hold the other hand's alt fire (or, with the whip in your main hand and the off hand empty, its fire) to cast a
  dotted aim ray with a diamond: gold where the whip can anchor (a wall or a ceiling within reach), red where it
  cannot. Crack, and the whip flies to that spot and latches. The beam wins over any monster mark.
- Reach is 9 m by default, adjustable from 3 to 60 m.
- Start the swing by closing your off hand on the whip or by jumping: the jump lifts you and pushes you on where you
  face.

**On the rope**
- A real pendulum: lean it with the stick, pump it by hauling down on the whip, reel in with the trigger (a climbing
  pace, about 3 m/s), let go with alt fire.
- Climb hand over hand with a free hand on Grab Whip.
- Reel up to a ledge lip, or lay a free hand on it, and you mantle up and over.
- Your speed carries on when you land.

**The binds whip** (two binds, one per hand)
- Real style: hold a Whip bind and the whip uncoils from that hand; let go and it rolls up. Assist style: a press
  throws a lash for you.
- Aim: Free (the crack hits what the tip touches), Assist (what is nearest the tip), or Lock (point with the other
  hand, hold alt fire, and the crack flies there; with the bind held, a locked crack on a monster leashes it and pulls
  it in).

**Options, off by default**
- Crack fireballs out of the air (explode them where they are cracked, or knock them away to explode there).
- A crack that does not kill knocks the monster about.
- Hit-stop: a crack freezes the monster for a beat.
- Yank grace: no yank in the first third of a second after a wrap.

## How To Play

1. Add RSQ_Whip.pk3 to your load order and play in VR. You carry the whip in slot 1.
2. Select it. Let it hang, then lift your forearm and snap it down. Listen for the crack.
3. Find an imp. Hold the trigger, point at it until the mark shows, then crack: the whip flies out to it.
4. Crack round a zombie and keep the trigger held. Swing your arm to smash it into its friends, then pull back hard.
5. Find a high wall. Hold your off hand's fire to cast the ray, put the diamond on it (gold), and crack. Jump to
   start the swing, hold the trigger to reel up, and press alt fire to let go.
6. With RSQ Tactical Rig, put the whip away at its own holster on your main-hand hip, where it hangs coiled.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Crack | Snap the forearm or flick the wrist | The tip must pass the crack speed |
| Mark a target | Hold the whip hand's trigger and point | Switches, keys and powerups within 8 m first |
| Next target | Whip hand's alt fire | |
| Send the whip to the mark | Crack while marked | |
| Swing a wrapped monster | Keep the trigger held and swing your arm | |
| Yank | Pull back hard while it is wrapped | Light monsters fly to you; heavy ones pull you to them |
| Lasso | Close the off hand on the handle or thong (grip within 0.30 m, or SteamVR's two-hand grip), whirl, let go | |
| Aim the swing | Other hand's alt fire held, or off-hand fire held (whip in main hand, off hand empty) | Gold diamond: can anchor |
| Start a swing | Off-hand grip on the whip, or jump | |
| Reel in / let go | Trigger held / alt fire | On a rope |
| Climb | Grab Whip bind with a free hand on the rope, pull down | Push up to lower yourself |
| Whip (Main) / Whip (Off) | Bindable keys | The binds whip, per hand |
| Grab Whip (Main) / Grab Whip (Off) | Bindable keys | Take hold of the rope to climb |

- Bind the keys in Customize Controls → RSQ Whip. There are no default binds.
- Whip In picks which hand holds the weapon; in the off hand it reads the off-hand trigger and alt fire.
- The off-hand grip is read from the keys the engine sends for it (443, or 436 while the main grip is held).

## Menu

Options → Radiant Silvergun Options → RSQ Whip

| Row | Default | What it does |
|---|---|---|
| Whip | On | The binds whip |
| Whip Weapon in Slot 1 | On | Every player carries the whip weapon |
| Whip In | Main Hand | Which hand holds it |
| Hand on the Handle | On | The hand round the handle |
| Whip Style | Real | Real (hold, crack it yourself) or Assist (press, it cracks for you) |
| Whip Aim | Assist | Free, Assist, or Lock |
| Catch Edges (snag) | On | A lash that catches an edge becomes a rope |
| Aimed Swing | On | The other hand's alt fire aims an anchor |
| Whip Swing Reach (m) | 9 | How far the aimed swing can anchor (3-60) |
| Aim With Off-Hand Fire | On | An empty off hand's fire aims too |
| Beam Wins Over Lock-On | On | The aim beam beats any mark |
| Off Hand Free While Snagged | On | A gun into the off hand never lets go of the rope |
| Off-Hand Grip Starts Swing | On | Grip the whip to start swinging |
| Jump Starts Swing | On | Jump to start swinging |
| Jump Lift / Jump Push | 10 / 8 | The jump start's lift and push |
| Throws Switches | On | A crack uses a switch it lands on |
| Fetches Pickups | On | A crack flicks a pickup to you |
| Leash (Lock) | On | A locked crack catches and pulls a monster |
| Stun | On | A crack breaks off a monster's attack |
| Lasso (off-hand grip) | On | Whirl and throw it as a lasso |
| Crack Knocks Enemies Back | Off | A crack knocks the monster about |
| Swing a Wrapped Monster (flail) | On | A wrapped monster swings with your arm |
| Keep the Mark When You Lift | On | The mark survives the lift before a crack |
| Yank Grace | Off | No yank right after a wrap |
| Crack Fireballs Out of the Air | Off | Cracks explode missiles |
| Cracked Fireballs and Rockets | Explode where cracked | Or knocked away to explode there |
| Hit-Stop | Off | A crack freezes it for a beat |
| Mantle Over Ledges | On | Up and over a ledge |
| Keep Momentum on Landing | On | Your swing's speed carries on |
| Rope Climbing | On | Hand over hand |

**Tuning and Debug**: Crack Speed (20), Damage (12 at the hardest crack), Hardest Crack Speed (43), Lasso Grip Reach
(0.30 m), Aim Reach (40), Switch/Key/Powerup Mark Range (256), Pulled Off Feet Up To (mass 400), Can't Be Pulled From
(mass 1000), Thickness (1.0), Leather Stiffness and Damping (1.0 x the reference), Whip Air Drag (1.0), Hand
Smoothing (0.8 tics), Reel Speed (3), Shortest Rope (32), Top Speed (30), Swing Lean (0.25), Arm Pump (0.12), Air Drag
(0.002), Rope Friction (0.025), Ledge Hop (6), Free Hand Only (On), Grips From Grab (On), Grab Reach (16), Climb Speed
Cap (8), Heaviest Leashed (1000), Leash Pull (10), Snag Edge Height (16), Rope Meets Body (0.6), Rope Draw Pieces
(12), Leash Stops At (16), Let-Go Return Speed (64), Debug Log (Off), Reset All.

## Works with

Runs alone. It finds the others by name:
- **RSQ Tactical Rig**: a whip holster on your main-hand hip, with the whip hanging coiled there whenever it is out
  of your hand. It never goes into a gun holster.
- **Brutal Doom 22 VR Reloaded**: the hand round the handle is its hand; its empty hands and fists count as free
  hands for climbing, the lasso and off-hand aiming.
- **RSQ Distance Grab**: its grab binds take hold of the rope too.
- **RSQ Saber, RSQ Melee**: their bare Force hand and gloves count as an empty off hand for aiming.
- **RSQ SlowMo**: a leashed monster comes at the slowed world's pace; your rope stays in real time.
- **RSQ VisualRewards**: the whip never targets its Kill Rewards bits.
- **RSQ Accessibility**: Hold to Toggle and Steady Hands apply.

## Credits and licence

- **presidentkoopa** (project owner): the code, written for this series. The rope (swing, reel, pump, climb, let go,
  the monster slide) is RSQ Grapple's core, forked.
- **Moses C. Nah, MIT Newman Lab**: "Whip Project - Targeting with a Whip" (BSD 3-Clause, Copyright (c) 2020 Moses C.
  Nah + MIT Newman Lab). Its whip model's stiffness, damping, link length and node mass are used node for node; its
  code is not included.
- **runevision** (Rune Skovbo Johansen): the first version followed his Eye of the Temple devlog, "Trials and
  triumphs of whips and levers". Verlet rope references: dylnli/rope (after Sebastian Lague) and
  chrischristakis/RopePhysics.
- The thong and handle skins are generated here, on RSQ Grapple's rope tube.
- **Pixabay** (Pixabay Content License): "crack_heavy", "crack_light" and "three_whip_swishes", trimmed and converted.
  The hit is stock Doom's punch.
- **BD22 VR Reloaded** (the owner's mod): the hand on the handle (its FBX hand in the magazine hold). The FBX's
  original author and licence are not recorded.
- **QuestZDoom** (Emawind and Team Beef): the engine.
