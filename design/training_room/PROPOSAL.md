# RSQ Training Room: the proposal (design only, 2026-11-27)

Three design passes, merged: `architecture.md` (the room), `teaching.md` (how it speaks), `challenges.md` (what you do in
it). Nothing is built. Every claim in those files cites code or is marked as an idea.

## The room
One fixed hub pad that never moves, facing a 16 x 8 grid arena of 64-unit cells. Every cell is a real sector whose floor
the engine's own mover raises or lowers, so one room becomes a grapple course, a saw range, a saber duel floor or a
holster bench. A lesson is data: a heightmap for the grid, a spawn list (exact classes, no XMVE replacement), and pass
checks that ask the mods' existing services by name. No mod has to change to be taught. A lesson whose mod isn't loaded
stays shut. One generator writes both the map (UDMF) and the lesson table, with a --check so a renamed request can't
break it silently. The rig drives the same room in one launch, and the owner uses it as a 5-minute headset smoke test.

## How it speaks
One verb at a time, in the world. Glow In The Dark flares the station floor (where). A Visual Rewards word of three
words or fewer stands over the target (what). One HUD line of six words or fewer gives the button (how). The Rig's
ghost hand, the mirror or slow motion shows the move. The mod's own feedback is the confirm (aim dot, lock rings, pin
sound, KICK!); the room only adds a green floor, a toast and the Score Glossary name. Lesson text points at README "How
to play" rows and is checked by gen_howtoplay.py, so it can't drift. The same lessons return in normal maps as hints you
pull with a watch check, never mid-fight.

## The challenges, in order
C1 recenter and watch check; C2 holster and draw; C3 Wheel loadout and holster assignment; C4 Distance Grab; C5 punch
combos; C6 Headlock; C7 grenade kinds; C8 Whip; C9 Saber (its training remote); C10 ShieldSaw (off-hand trigger locks
on, flick throws: rig-proved 2026-11-27, LOCKON_OFF3); C11 Grapple; C12 SlowMo and Crisis Dive; C13 Be Quick or Be Dead;
C14 Score rows; C15 the Boss call, fight and kiosk. Then a final exam, the "Arcade Run".

## The owner's decisions (2026-11-27 18:2x)
1. The room lives in RSQ_Controls.pk3, beside How To Play.
2. Entry: its own New Game episode (a clean run), plus a row in How To Play.
3. Normal game always: Miniboss, Monsters and SlowMo run as in a real map (no "quiet" request).
4. Grenade: a slow let-go keeps cooking it in the hand; the room teaches it (slow let-go lights it, press fire to throw).
5. Saber and whip at the main hand's hip: the main hand takes them with Use (A), as it holsters (code: rig.zs:2791,
   pressNow = grip or Use for the main hand at any spot). Not a break: teaching.md was wrong, and Tactical Rig's README
   rows now say it (How To Play regenerated). Not yet shown on the rig for the saber and whip spots.

## Gaps the build needs (signals a mod doesn't report yet)
Crisis Dive and near misses; the watch card being read (the check is pose-only); the ShieldSaw's ring count (debug line
only); the Saber remote's rounds and streak; Score's rows for a kill (debug line only: a read-only "kill.rows" query).
The series uses no engine inventory bar, so "inventory" means the Wheel and holsters. Monster health and mass in
challenges.md are defaults, not measured: measure on the rig before setting pass thresholds.

## Biggest risks
Floors moving under Grapple ledges and Glow In The Dark's wall glow, and VR comfort of moving floors: unproven on 17.3
in rig and headset. The grammar is inconsistent (main hand takes with A, off hand with its grip; three throw-release
rules; the grapple button on the right stick for a left-hand claw): every exception costs words.
