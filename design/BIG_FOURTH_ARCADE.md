# Big Fourth: the in-world arcade language (owner, 2026-11-08 17:49) — thinking, not a plan

The owner's words, condensed:
- "I enjoy aspects of all of these" (design/mockups/arcade_language/, eight panels). Designing this is a Big Fourth task
  (after Score pruning, GBOVR pruning, Monster Assembly).
- Panels 1-2 (lock-on ring, danger flash) may not suit Doom VR, where you move and aim freely; they may fit contextual
  situations and set fights.
- Question: how do we tell what a "room" is in a Doom map? Can we discern rooms from lines and sectors?
- Time attack is awesome for maps people know well (the classics and a few others); we may need movement mechanics to
  get the most from it, maybe movement mechanics that support the whole system.
- Plan later how to use agents to design a few gameplay paths. Keep it DOOM-flavoured, not generic.

## Rooms: what the map gives us (my notes; to verify in the engine before relying on them)
Doom has no rooms, only sectors and lines. Candidate ways to find "rooms" at map load, all from data the engine exposes:
- **Areas split by doors:** flood-fill sectors across two-sided lines, stopping at door sectors (sectors whose lines
  carry door specials) and lifts. Each fill is one area. Most classic maps read as rooms this way. [inference]
- **Sound zones:** lines marked "block sound" split maps into the zones monsters hear across; mappers placed them by
  hand, often at room edges. [inference]
- **The mapper's own fights:** trap rooms and arenas are trigger lines that open closets or raise walls; monster groups
  that wake together. "Room clear" could mean "every monster that woke with this fight is dead" instead of a geometric
  room. [inference]
- Needs a prototype that colours each found area on a few classic maps (E1M1, MAP01, MAP07) to see whether it matches
  what a player calls a room.

## Doom's own flavour to build on (not generic arcade)
- Doom already keeps score: KILLS / ITEMS / SECRET / TIME / PAR on its intermission screen. Par time is id's own time attack.
- Doom's demo culture already has named categories: UV-Speed, UV-Max, Pacifist, Tyson (fist and pistol), Nightmare,
  NoMo. These are Doom's own "modes".
- Doom's own words and sounds: "You got the...", the secret-found sound, the item-pickup flash, the berserk red, the
  invulnerability inverse, the Doomguy face.
