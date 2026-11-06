# Ideas: death, bones and the flashlight (agent B: combat, VR feel, horror)

For a design talk with the owner, 2026-11-06. Nothing here is built, tested or committed. Facts in section 1 were
read from the code (LOB_v1.05.pk3, Ermac's VR-Flashlight repo, this repo); none of it was run.

Rules kept: no new mods, every mod still loads alone, stock Doom/BD sounds only, netplay matters, no screen shake or
roll.

---

## 1. Facts that matter

### Legion of Bones (LOB_v1.05.pk3, DECORATE plus one tiny ZScript class)

- **Two modes, chosen by skill.**
  - **Normal skills:** every monster is replaced by its undead form **from the start** (RandomSpawners on
    ZombieMan, ShotgunGuy, ChaingunGuy, DoomImp, Demon, Spectre, LostSoul, HellKnight, Baron, Caco, PainElemental,
    Revenant, Fatso, Arachnotron, Archvile, SpiderMastermind, WolfensteinSS). No rising.
  - **"Double Death" Easy / Normal / Hard** (its own skills; ammo x1.5, auto-use health): monsters start alive
    and **rise as undead from their corpse**. 13 types do this: zombieman, shotgunner, chaingunner, imp, demon,
    spectre, caco, hell knight, baron, revenant, mancubus, arachnotron, arch-vile. Lost souls, pain elementals,
    the mastermind and the cyberdemon do not rise in this mode.
- **Timing** (menu: Respawn Delay, `LOB_Respawn`, server cvar): after the normal death animation (about 0.7 s), the
  corpse waits **Instant / 5 s / 10 s (default) / 15 s / 20 s**. Both normal and gibbed deaths rise.
- **How they rise:** a burst of fire on the corpse (Add-style flame, A_Fire), Doom's teleport sound, and the undead
  plays its own death frames backwards (about 0.7 s) while facing the player. It keeps the killer as its target.
- **Something standing on the corpse stops it.** When the wait ends, the corpse turns solid and checks if it is
  blocked. If anything stands there (a player, a monster), the **whole wait starts again**. (Side effect read from
  the code: after one blocked try the corpse stays solid.)
- **The rise is a named state, `Respawn`,** in every LoB "living" class (LOBZombieMan ... LOBArchvile). Another mod
  can start it early (`SetStateLabel("Respawn")`) or delay it (put something solid on the corpse) **without editing
  LoB**.
- **Undead die for good.** They burst into 4 bouncing bone pieces (lie 10 s, then fade) with LoB's bone sounds. They
  have Raise states, so an arch-vile (or LoB's Reaper) can bring them back again.
- **Special undead:** Ghost Spectre (half see-through, ice-blue, glowing); Phantom Revenant (its death lets out a
  see-through ghost with 100 HP that fights on); Balrog (its fire buff makes nearby monsters painless and stops
  them fighting each other, menu: Hellfire Effect); Reaper (arch-vile: raises the dead).
- **Health of the risen:** skull zombie 20, skull shotgunner 30, skull chaingunner 70, skeleton imp 50, skeleton
  demon 150, ghost spectre 150, caco lich 350, slayer knight 400, phantom revenant 250, abhorrent 580, arachnobone
  500, balrog 1000, reaper 700, conqueror 2500.
- **Fire resistance:** balrog and dragon soul take 25% fire damage, slayer knight 50%, reaper 70%, skeleton imp 80%.
  The flare's burn is weak on them.
- **Damage types it already favours:** most risen humanoids, imps, demons, cacos and knights take x2 from
  "Purifying" (Final Doomer); zombies, shotgunners, chaingunners and the retro skeleton also x3 from "Exorcist"
  (LegenDoom). Not on every undead, so a class-name list is the safe way to tell "undead".
- **The big one for us: LoB's undead are vanilla monsters, not BD22's.** LoB's classes inherit Doom's ZombieMan etc.
  Loaded after brutal22test6, its replacements (normal skills) or its skill ReplaceActor lines (Double Death)
  should push BD22's monsters out. Expected from the code, **not run**. So "skeletons rising from *our* BD
  corpses" does not happen by itself; it needs a small bridge (see questions).
- LoB plays its own sounds (bone, balrog, etc.). Our side would still only play stock Doom / BD sounds.

### Ermac's flashlight battery (iAmErmac/VR-Flashlight, zscript/flashlight.txt)

- Capacity in minutes (`vr_flashlight_batt_cap`, default **3**, 0 = no battery, up to 60).
- **Drains 1 tic per tic while on; recharges 1 tic per tic while off** (also while put away). Full recharge takes as
  long as a full drain.
- Empty: it switches itself off with a click.
- 10-step LED on the flashlight model; the last step blinks.
- Under 50%: the light dips briefly about once a second. Under 30%: dimmer. Under 20%: dimmer still, the cone
  narrows and it flickers fast.
- Separate option: the beam "agitates" monsters (an invisible puff where the beam lands wakes monsters near it).
- Ours today (FnF README): no battery at all; the beam already traces to the first wall or monster (every 2nd tic on
  Quest).

---

## 2. Ideas

Cost: S = a day or two, M = about a week, L = more. "Bones" means LoB's undead, found by class name.

### 1. Bone Light (flashlight vs bones)
- **Pitch:** the beam burns the risen dead.
- **Hands:** off hand sweeps the light onto a skeleton, it smokes and staggers; main hand finishes it.
- **Touches:** FnF (beam trace it already has), LoB by name.
- **Cost:** S.
- **Worries:** damage must come from the play-side trace, never from the drawn beam (netplay). Small numbers (a few
  HP per half second) so it helps guns rather than replacing them. Give it its own damage type, not BD's Fire:
  fire-resistant undead (balrog, slayer knight) would shrug Fire off.

### 2. Grave Glint (flashlight vs bones, horror)
- **Pitch:** only the beam shows which corpses are about to rise: a faint green glint in the eye sockets in the
  last 2 seconds.
- **Hands:** after a fight you sweep the light over the bodies, like checking a crime scene. Glint = shoot it now
  or stand on it.
- **Touches:** FnF; LoB by name (we count the wait ourselves from the death and `LOB_Respawn`).
- **Cost:** S.
- **Worries:** our count can drift from LoB's (a blocked try restarts its wait); re-arm the glint each time the
  corpse is seen still lying there. Answers item 12's "what can the flashlight show us".

### 3. Hold the Grave (flashlight vs bones)
- **Pitch:** keep the light on a corpse and it cannot rise; look away and the clock runs again.
- **Hands:** you hold the beam on the big one (a dead baron) while fighting with the other hand. You can't light
  every body: choose.
- **Touches:** FnF, LoB (an invisible solid marker on the corpse uses LoB's own "something is standing here" rule).
- **Cost:** S-M.
- **Worries:** the marker must never block players or shots; remove it when the light leaves. Note LoB restarts the
  whole wait, not pauses it: maybe that is the price of looking away.

### 4. Ghost Catcher (flashlight vs bones)
- **Pitch:** ghost spectres and phantom revenant souls are hard to see; in the beam they turn solid and readable.
- **Hands:** a faint shimmer in the dark, light swings onto it, it snaps visible, you shoot.
- **Touches:** FnF, LoB by name (change the ghost's alpha while lit).
- **Cost:** S.
- **Worries:** co-op: one player's light shows the ghost to everyone (alpha is world state). Fine, but say so.

### 5. Lion Tamer (flashlight vs bones)
- **Pitch:** the undead fear the light: a lit skeleton backs off for a beat (Doom's "frightened" flag).
- **Hands:** you sweep the beam across a pack to hold it at bay while the gun hand thins it out.
- **Touches:** FnF, LoB by name. An alternative to Bone Light (burn or repel), or both at once.
- **Cost:** S.
- **Worries:** chain-holding a pack forever: give each monster a short immunity after it is repelled.

### 6. Strobe Burst (flashlight vs bones, battery cost)
- **Pitch:** double-tap the trigger: a bright burst that stuns every undead in the cone and shatters weak skeletons
  (20 HP zombies), at a big battery cost (25%).
- **Hands:** panic button. Thumb twice, beam flares.
- **Touches:** FnF, LoB, Accessibility (Photosensitive Mode: a single steady brightening, no flashing).
- **Cost:** S-M.
- **Worries:** photosensitivity first. No screen flash at all; only the world light changes.

### 7. Crank It (battery)
- **Pitch:** shake the flashlight to charge it. Shaking is loud: it wakes monsters near you.
- **Hands:** a quick back-and-forth of the off hand, the LED climbs a step per shake burst.
- **Touches:** FnF (hand speed it already reads for flare strikes), a stock sound per step.
- **Cost:** S.
- **Worries:** an arm workout if the battery is short; pair with slow passive recharge so cranking is a choice, not a
  chore. Seated / one-hand players: Accessibility option to charge by button.

### 8. Cell Swap (battery)
- **Pitch:** the flashlight runs on Doom's energy cells. A dead light means: spend plasma/BFG ammo, or sit in the dark.
- **Hands:** twist the tail cap off with the main hand, the spent cell drops, take a cell from the Rig's ammo pouch,
  push it in. A reload like the guns.
- **Touches:** FnF, Tactical Rig (ammo pouch), stock Cell ammo.
- **Cost:** M (the hand reload is the work).
- **Worries:** one Cell gives a lot of light (say 1 min) or it is a tax. Without the Rig, a grip at the clip
  swaps.

### 9. Bone Battery (battery)
- **Pitch:** an undead that dies in your beam gives the battery a chunk back. The dead fuel the light that fights the
  dead.
- **Hands:** keep the light on your target as it dies; the LED ticks up with a soft stock click.
- **Touches:** FnF, LoB.
- **Cost:** S.
- **Worries:** with Bone Light on, a loop that could be endless: cap gain per minute.

### 10. Grave Candle (battery, Graveyard)
- **Pitch:** your own tombstones' candles recharge the flashlight while you stand near them. Where you died before
  is now a small safe light.
- **Hands:** nothing new: you walk to a grave, hold the light near the candle.
- **Touches:** FnF, Graveyard (its stones already have a candle light).
- **Cost:** S.
- **Worries:** graves come from each player's own saved history but spawn in everyone's game by network event, so
  it works in co-op; keep the charge done in play code only.

### 11. Cremate (flare vs bones)
- **Pitch:** a burning flare left on a corpse for 3 seconds burns it to ash: it will never rise.
- **Hands:** pull a flare, strike it, drop or throw it on the pile of bodies. One flare can do a whole pile if they
  lie close.
- **Touches:** FnF (lying flares), LoB by name, Distance Grab (pull a lit flare and lob it onto the next pile).
- **Cost:** S-M.
- **Worries:** flares become very valuable on Double Death maps; maybe more boxes when LoB is loaded. The ash uses
  BD's or Doom's stock fire, no new sounds.

### 12. Smash the Bones (melee vs bones)
- **Pitch:** skeletons hate blunt hits: punches, gun-butt shoves and shield bashes do extra to the undead, and a
  corpse you stomp or pound (Ground Pound) breaks and won't rise.
- **Hands:** a hook to a skull zombie's jaw and it comes apart in bouncing bones; punch down onto a body to finish it.
- **Touches:** Melee, ShieldSaw, LoB by name.
- **Cost:** M.
- **Worries:** balance; one multiplier row, off by default.

### 13. Night of the Living Dead (Second Wind + bones)
- **Pitch:** when Second Wind holds you at 1 HP in slow motion, the corpses near you all rise **now**: the kills you
  need to get back up come crawling out of the floor around you.
- **Hands:** you're on 1 HP, the world slows, the light flickers out to its last step, and skeletons climb up in a
  ring. Shoot your way back to your feet.
- **Touches:** SlowMo (Second Wind lives there), FnF (flicker), LoB (`Respawn` state started early), GITD (deep red).
- **Cost:** M (after Second Wind exists).
- **Worries:** too many risers at once: cap it (say the nearest 4, weakest first). Without LoB: nothing changes.

### 14. Your Own Bones (Graveyard + bones, horror)
- **Pitch:** sometimes, on a map where you died before, a skeleton marine climbs out of your grave. Kill it and it
  drops what you'd like back: a flare, a full battery.
- **Hands:** a candle you remember, then the grave stone shudders.
- **Touches:** Graveyard, LoB (spawn its retro skeleton by name), FnF.
- **Cost:** S-M.
- **Worries:** must use network-shared grave data (it is: graves spawn by network event). An option, and never on a
  grave closer than a set distance to where you stand when the map starts.

### 15. Cold Breath (GITD + bones, horror)
- **Pitch:** a second before a corpse rises, the room's glow near it dips cold blue for a moment, then comes back.
- **Hands:** none. You feel it before you see it: the room tells you to turn around.
- **Touches:** Glow In The Dark (one more reaction), LoB.
- **Cost:** S.
- **Worries:** many corpses = many dips; merge dips within a second. Photosensitive Mode: a slower fade. Uses only
  light, no screen effect.

---

## 3. My top 3

1. **Bone Light + Bone Battery (1 and 9).** It answers the owner's question directly: the flashlight is a weapon
   against the dead, so its battery is ammo you manage, and killing the dead in the light refills it. Small, uses
   the trace FnF already has, and makes the off hand busy in every fight.
2. **Cremate (11), with Hold the Grave (3).** It turns LoB's rising from "monsters come back" into a choice in
   your hands: light the big corpse, burn the pile, or kill it twice. Flare and flashlight both matter, and it uses
   LoB's own rules, so no LoB edit.
3. **Night of the Living Dead (13).** The best horror moment on the list and it makes Second Wind fair: the kills
   you need show up. One state call on LoB's corpses, all the rest is already planned.

Runner-up: **Cell Swap (8)**, the most VR battery idea (a reload by hand), if he wants batteries to cost something
real.

---

## 4. Open questions for the owner

1. **LoB under BD22: where do the bones come from?** (LoB alone swaps BD22's monsters for vanilla ones.)
   a) LoB's own Double Death skills as they are (vanilla living monsters, no BD gore).
   b) A small bridge in an existing RSQ mod: BD22 monsters die as BD22 monsters, LoB's undead rise from their corpses.
   c) LoB normal skills: all undead from the start, no rising.
   d) Don't play LoB with BD22.
2. **If (b): which mod hosts the bridge?** a) FnF (it already detects LoB for the light) b) Graveyard (death and
   graves) c) Miniboss (it already spawns monsters) d) Gun Bonsai VR (as an upgrade/mode).
3. **What does the light do to the dead?** a) burns (Bone Light) b) repels (Lion Tamer) c) only reveals (Glint,
   Ghost Catcher) d) burns and reveals.
4. **Battery model?** a) Ermac's as-is (3 min, drains and recharges at the same speed) b) slow recharge + Crank It
   c) Cell Swap d) recharge + Bone Battery.
5. **Can the player stop a corpse rising?** a) no, LoB as is b) light holds it c) flare cremates it d) b, c and Smash.
6. **Second Wind + LoB:** a) no link b) nearby corpses rise now (Night of the Living Dead) c) risen kills count
   double toward getting up.
7. **Strobe Burst:** a) build it, off under Photosensitive Mode b) build it, off by default c) don't build it.
8. **Graves that rise (Your Own Bones):** a) never b) an option, off c) only during a Miniboss Bossfight.
9. **Co-op: one player's light shows ghosts and glints to everyone?** a) yes, simplest b) the reveal only for the
   holder, damage for all c) don't care, co-op is rare.
