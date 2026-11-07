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

**Open:** the icon art (owner sending); what happens after you are up, RAGE included (to be talked through);
bar step lengths in seconds.
