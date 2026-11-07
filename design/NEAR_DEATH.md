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
8. **Scar:** each DOWN (passed or failed) costs 10 max health until the next map; Graveyard (when loaded) marks the
   spot where you went down with a tombstone.
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
