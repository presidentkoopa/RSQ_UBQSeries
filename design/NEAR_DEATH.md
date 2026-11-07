# Near-death mode v2: DOWN -> REVENGE -> REVIVE -> RAGE (owner-approved 2026-11-06 19:51)

Replaces v1 (3 kills to get up, kill-drop medkits). Built v1 code (commit a2ba3cde) is reworked into this.
Home: RSQ SlowMo owns the mode and its options; others join by name and every mod still loads alone.

1. **DOWN (trigger):** a hit that would kill you holds you at 1 HP (any source), before any Score life is spent.
   For the first 1 s no hit can finish you.
2. **DOWN (body):** you are forced into a crouch (the engine's own crouch: view eased down to about half height over
   ~0.5 s, hitbox shrinks with it; 60% lower if the engine allows it safely, otherwise 50%) and you move at crawl
   speed (about a third). Both controllers keep working exactly as normal: no hand is disabled. The world goes to
   SlowMo's deepest speed. Glow In The Dark drains the map to red; a heartbeat (stock/BD sound). Comfort option
   "Lower View When Down" (on): off = no view drop (crawl speed stays).
3. **REVENGE (the mark):** the monster that downed you is marked. If it is already dead or gone (barrel, splash,
   telefrag), the nearest strongest living monster takes the mark.
   - With LegenDoom AND Champions loaded: the marked monster instantly becomes a boosted legendary champion (their
     own hooks, by name).
   - Otherwise, our own boost: a coloured dynamic light on it, full-bright and tinted DOWN red, kept lit while the
     map drains (Glow In The Dark), a skull marker over its HP bar (VisualRewards), slightly larger, +50% health.
4. **Dynamic clock:** the DOWN window starts at 6 s; every hit you LAND on any monster adds time (0.5 s a hit, cap
   12 s left). A countdown bar under the SlowMo bars, cause line "DOWN" (then "REVENGE" once the mark is killed).
5. **The crate:** killing the marked monster drops the white medkit crate (BD Berserk voxel recoloured white with
   a red cross). You crawl to it, or pull it with Distance Grab (when loaded). It does not fly to you. Touching it
   = REVIVE.
6. **REVIVE:** the REVIVE word flies past (VisualRewards, JFO font), time returns to normal, the view rises back,
   health 50 (or kept if higher), magazines filled from reserve, +1 cigarette, +1 grenade.
7. **RAGE:** right after REVIVE, 5 s of rage: x2 damage and no ammo used (magazines don't drain). The word RAGE
   with it.
8. **Scar:** each DOWN (passed or failed) costs 10 max health until the next map. No tombstone for DOWN (owner
   correction 19:58): tombstones are for player death only, and an RSQ Score life being used counts as a player death,
   so when a Score life is spent (after a failed DOWN or otherwise) Graveyard (when loaded) places a tombstone there,
   through its own spawning. Two kinds (owner 19:59): a real death (no Score life left) is today's grey stone with its
   warm flickering candle; a Score life spent is the same stone tinted gold, with a steadier gold light and a slightly
   larger light radius. Graveyard records the kind in its storage (old stored stones load as kind 1); Score tells
   Graveyard by name; without Score every stone is kind 1. Graveyard option "Living Stones" (off; owner 20:06): every
   stone's light colour and tint breathe like Score's label (Uniform / Wave / Chaos), gold stones within their gold
   range; held still in RSQ Accessibility's Photosensitive Mode.
9. **Failing:** the clock runs out, or a killing hit after the first second: you die (or a Score life catches it).
10. **Repeat:** 60 s cooldown after DOWN ends; "Repeat Without Limit" option (off) removes it.
11. **Score:** "Revenge" for killing the marked monster (1x that kill's base) and "Revive" for the crate (3x the
    marked kill's base). Score's readout look is unchanged.
12. **Damage numbers (VisualRewards):** time added per hit shown as "+0.5s" in a DOWN colour; REVENGE / REVIVE /
    RAGE words in the JFO font, each its own standout colour.
13. **Options (RSQ SlowMo page, Reset All):** DOWN on/off, Window (6 s), Time per Hit (0.5 s), Max Window (12 s),
    Rage Length (5 s), Scar (on, 10), Cooldown (60 s), Repeat Without Limit (off), Red Map (on), Lower View When
    Down (on).
14. Gun Bonsai VR upgrades: in the GBOVR pass. Netplay: each player's own DOWN; world slow-down per SlowMo's rule.

## v3 presentation and tiers (owner, 2026-11-07 04:20-04:55; agreed from in-chat mockups, not built yet)

**The plate (drawn the Wheel way: a canvas painted every frame on a quad in the world, low in view)**
- Big line "DOWN!". Job line under it naming the target ("Revenge: <monster>").
- Right-hand tab: small "DEATH IN:" above a seven-segment readout (SS:hh, unlit segments faintly visible,
  blinking colon). The readout is the total time left; at zero a Score life is spent (or you die).
- The bar is the reward gauge, not a second clock. It drains smoothly (no segments), faster than the clock,
  in three fixed-second steps of different heights (tall at the end that drains first, then normal, then thin).
  Each step breaks off and falls when it runs out (shake, clunk, rumble). Extra clock time for a far mark goes
  to the clock only; the steps do not stretch. No tier labels under the bar.
- Bar colour = the target's colour, a moving gradient with variety but mostly that colour: a Champion's colour,
  a LegenDoom legendary's own glow colour (LD without Champions), or red for our own mark.
- A target icon (owner's own art, to come) on our bar and on the target's health bar; the target's health bar
  is drawn even if you never hit it.

**Who is the target**
- The monster that downed you, if it is in your fight.
- Downed from range by a monster outside your fight: a boosted copy of the killer's type spawns in view, at
  range: a boosted legendary Champion when Champions x LD is loaded (GBOVR or Miniboss), otherwise our own
  boosted enemy (red).
- Barrel set off by a monster: the monster is credited (DOWN, it is the target).
- Barrel nobody set off, crusher, fall: no DOWN; Score handles it as a normal death.

**Getting up: the word is REVIVE every time; its size, life and animation scale with the tier**
| Tier (step when you kill) | Health / armour | Score fire burst | Slow-mo |
|---|---|---|---|
| Top (tall step) | 100% / 100% | yes | 3 s |
| Middle | 66% / 66% | no | 1.5 s |
| Bottom (thin step, or bar empty) | 33% / 33% | no | 5 s |
No revive spends a Score life (only failing does).

**Open:** the icon art (owner sending).

## v3 repeats (owner, 2026-11-07 05:14-05:20)
- The clock starts at 9 s and never goes above 9 s. (Correction 05:20: the earlier note here said a flat clock
  replaced the dynamic clock; that came from my wrong description of the dynamic clock. The owner chose: hits
  still add time to the clock only, see "v3 clock and bank" below.)
- The bar steps are 3 s / 3 s / 3 s, so the bar and the clock end together: the bottom tier is the last 3 s,
  and the bar empty means death (a Score life spent).
- Each time you go down you owe one more kill: 1, then 2, then 3... with no cap. The first target is the
  monster that downed you (or its spawned copy); every extra target is a fresh boosted spawn in view (LD
  Champion / LD / Champion / our own, by what is loaded). One icon per kill owed on the plate, each cracked or
  filled as it dies. The tier is judged at the last kill.
- The count goes back to 1 when a Score life is spent.

## v3 clock and bank (owner, 2026-11-07 05:20-05:35)
- Damage you deal (to the mark too) adds time to the DEATH IN clock only; the reward bar keeps draining 3/3/3.
  Damage is counted as a share of the monster's spawn health, so modded guns cannot cheese it. A whole
  monster's worth buys: 1 s for humanoids, Imps and Pinkies; 2 s for anything above them; 10 s for the
  Cyberdemon and the Spider Mastermind. Time bought can never exceed 9 s left, and at best the clock still
  drains at quarter speed.
- Bits bank: kills while DOWN still drop VisualRewards bits; they fly into the plate and bank instead of
  healing, and the bank is paid as health and armour on revive. Health on revive comes only from the bank.
- The bar step when you get up gives invulnerability 5 / 3 / 1 s, plus the top tier's Score fire burst and the
  slow-mo 3 / 1.5 / 5 s. (Supersedes the 100/66/33 health split above.)

## v3 getting up, and the life crate (owner, 2026-11-07 05:35-05:50)
- Time per monster: Lost Souls 0.5 s. Modded monsters (BD, XMVE...) count as what they replace.
- Killing the last marked target gets you up at once (no crate step). RAGE is dropped: getting up gives the bar
  step's invulnerability / burst / slow-mo, the bits bank as health and armour, and both held guns reloaded
  for free (not taken from reserve).
- Scar and Cooldown are dropped (the growing kill count is the cost).
- The white crate becomes a Score life pickup (lives in RSQ Score; other mods only spawn it when Score is
  loaded). Look: gold, in Score's colours, with a beam of light into the sky.
- A Bossfight win no longer adds the extra life outright: the miniboss drops the life crate where it died. It
  lasts 10 s; in its last 5 s it breathes and fades red, faster and faster. It stays where it fell, reachable
  or not (Distance Grab can pull it).
- Owner-noted risk (05:45, my objection, his call): a crate over a pit or ledge is lost.

## v3 while down (owner, 2026-11-07 05:38-05:41)
- Hits cannot kill you while DOWN: only the clock ends it (then Score is asked for a life, or you die).
- The world may be slowed as deep as SlowMo goes, but DEATH IN counts 9 real seconds, and your own shots fly
  at normal speed (SlowMo's "your own rockets slow too" forced off while DOWN).
- No bits bank (VisualRewards not loaded or Kill Rewards off): you get up with the tier split 100/66/33 of
  health and armour. The bank pays up to max health and 250 armour.

## v3 last answers (owner, 2026-11-07 05:45)
- +1 cigarette and +1 grenade on revive: top tier only.
- Score's "Revive" award is dropped ("Revenge" stays). Score's readout is untouched.
- You get up only once every target is dead, so none are left. Failing with a Score life: the spawned targets
  despawn (teleport fog). The map's own monster that downed you loses its mark and boost and stays (my reading:
  removing a map monster would break the map's kill count). Failing with no life: you are dead.
- The top tier's fire burst is Score's Revival Fire.
- DOWN stays off by default; tonight's numbers get option rows on the RSQ SlowMo page with these values as
  defaults (Reset All).

## v3 target icons (owner, 2026-11-07 05:51)
- TEN original crosshair icons (our own art, simple line reticles; SlowMo/tools/plate/gen_plate_art.py): 1 ring + 4 inward
  triangles + dot; 2 dashed outer ring + ring + gapped cross + dot; 3 corner brackets + ticked cross + small circle; 4 four
  thick broken arcs + dot; 5 ring with 4 notches + ticked cross; 6 small corner brackets + 4 outward-pointing small triangles
  + dot; 7 dashed ring + 4 small cardinal circles + gapped cross + dot; 8 ring + 4 outer ticks + small circle with an X;
  9 three rings (middle dashed) + 4 ticks + dot; 10 dashed ring + 4 diagonal inward arrows + dot.
- Each target owed in one DOWN gets a different icon, random, never repeated within that DOWN. The same icon sits on its
  slot on the plate and over its monster's health bar, and cracks on the plate when that target dies.
- When a target is marked its icon ASSEMBLES over the monster in about 0.4 s: the ring spins / scales in, ticks and
  brackets slide in from outside, arrows shoot inward, the dot pops last, then a small flash ring as it locks. Tinted the
  target's colour.

## v3 off-view turn markers (owner, 2026-11-07 05:53, 05:56, 05:58)
- Any target outside your view shows its own icon on a ring around your gaze at the edge of comfortable view (world space,
  no flat screen edge), placed in the direction to turn, with a marker pointing that way. Directly behind: at the bottom
  of the ring, pointing down/back. As you turn toward it the icon slides inward; when the monster comes into view the icon
  flies onto it and plays the lock-on assembly there. No distance readout, no sound. Target's colour, its own icon.
- The marker: pixel art, nearest-neighbour; a 3-band grey stepped bevel frame (light #d4d8e0 inner, mid #8d93a0, dark
  #3b404b outer) that stays grey; the fill in the target's colour with diagonal stripes and a light band sweeping across
  (shimmer). MOMENTUM, a ~0.85 s loop: wind-up (back ~2 px, ~0.92 wide) -> fast push (accelerating ~9 px, ~1.22 wide, the
  fill flaring) -> overshoot / recoil -> settle. Option row "Turn Marker" (DOWN options), four styles, default C:
  A Framed Triangle; B Framed Fat Arrow; C Triple Chevron (three in a row, each a beat ~0.09 s after the one behind, so a
  wave rolls forward); D Triangle With Afterimages (A's motion plus 4 fading ghosts only during the push). Frames from a
  committed tool (SlowMo/tools/plate/gen_chevron.py); the motion is done at run time.

## v3 as built (2026-11-07): the readings made while building (owner 06:25: from now on an uncovered question stops the build
and goes to him; no more readings)
- The plate is drawn the RSQ Wheel's way on 17.3, composed model quads + glyph strips, NOT a canvas texture: the Wheel's
  own code records a canvas drawn in a VR mode on 17.3 as black (measured on the 17.3 rig), so its cards are quads.
- "In your fight": alive and within 1024 units (~30 m), or in sight within 2048 (~60 m): OWNER CONFIRMED 06:23 (as built).
  A dead killer: a copy of its type spawns.
- Extra targets are copies of the first target's type. A spawn with no room in view within 2 s SPAWNS OUT OF VIEW NEARBY
  instead (the turn marker points to it); no kill is ever dropped: OWNER 06:23.
- A target removed without dying (another mod) is replaced by a fresh spawn.
- A monster that is none of Doom's and replaces none: small (1 s) up to 150 spawn health, else big (2 s); a BOSS of
  3000+ is the Cyberdemon's 10 s. Bought time pours in through a pool, so the clock never drains slower than a quarter.
- No DOWN without a monster to blame: also your own shot or barrel (OWNER 06:23: stays a normal death), a hazard floor, no
  source at all.
- Bits banked: kills by the downed player; health and armour bank; an ammo bit is effective IMMEDIATELY while down (OWNER
  06:23, as built: it gives its ammo as it arrives, not banked).
- No-bank split: health % of max health, armour % of a green armour's 100; never lowers what you have.
- Free reload: the held guns' magazines (BD22 VR's Ammo2 magazines); a gun without a magazine has nothing to reload.
- More than ten targets in one DOWN: the ten icons are dealt again.
- LegenDoom without Champions: the legendary's glow colour is read at run time from a stencil-drawn actor bound to it; gold
  until found. Champions: a colour token given by name (Yellow / White / Dark Green / Cyan, as RSQ Miniboss gives them).
- The v2 DOWN bar under the SlowMo bars is removed (the plate replaces it).
