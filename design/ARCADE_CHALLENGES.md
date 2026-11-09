# Arcade challenges: concept only (owner, 2026-11-08 18:39: "No building yet, let's conceptualize")

Owner: a fun knock-off of the Where's Waldo idea; we have timers and minibosses; each map can be told its arenas; a
**DoorCard**, inspired by Gun Cards, on doors, saying what challenge(s) they offer; time trials, clear room, spawn in
barrels, bit collection. "There's a lot here, and it can be overwhelming if we don't organize, and building now would
be disastrous."

## How to keep it organised
1. **The arena is the unit.** Each map lists its arenas (drawn by the owner in tools/mapview/, exported as JSON).
   Nothing happens outside an arena.
2. **The DoorCard is the menu.** The door into an arena shows a card naming what is on offer. Opening the door is
   saying yes. It reads like a Gun Card, so it is already the series' language.
3. **Every challenge is written up as one challenge sheet (a design note, not an in-game card), same fields**, so ideas can be compared and sorted, not piled up:

| Field | Meaning |
|---|---|
| Name | what the DoorCard says |
| Family | Speed / Hunt / Collect / Skill (below) |
| Goal | one line: what the player must do |
| Clock | none, or seconds, and when it starts |
| Spawns | what appears (teleport-in, barrels, bits, a miniboss), from where |
| Win | what ends it well |
| Fail | what ends it badly; never death by itself |
| Pays | Score rows, bits, an item |
| Stake | what failing costs: a life, a weapon level, or the next challenge harder (printed on the DoorCard) |
| Shows | which mockup panels it uses (1-8, design/ARCADE_LOOP.md) |
| Doom flavour | why it is Doom and not generic |

4. **Families** (so a door offers a mix, not five of the same):
   - **Speed:** time trial, clear the room.
   - **Hunt:** find and kill the marked one among many (the Waldo concept), miniboss.
   - **Collect:** bit collection, barrels spawn in.
   - **Skill:** shot ladder, style.
5. **Sort before building:** each sheet goes to KEEP / LATER / NO by the owner. Only KEEP sheets get built, one at a time.

## First challenge sheets (names only, from the owner's list; fields to be filled together)
Time Trial (Speed) · Clear the Room (Speed) · Find the Marked One (Hunt) · Miniboss (Hunt) · Barrels In (Collect) ·
Bit Rush (Collect)

## DoorCard decisions (owner, 2026-11-08 18:46; mockup: three states, offered / in progress / cleared)
- **Choosing:** the card's rows are shootable, punchable or touchable: hit a row to select that challenge.
- **The keyring** (RSQ Tactical Rig) might be repurposed here. Idea only; how is open.
- **Failing a challenge** could cost a Score life, drop a weapon level (GBOVR), or affect the next challenge.
  **Decided (18:47): each row prints its own stake**, e.g. "Time trial  +400  lose: 1 life" beside "Barrels in  +250
  lose: next challenge harder". The player sees the risk before choosing: push-your-luck at the door.
- **Return visits:** no, for now. A cleared arena does not re-offer its challenges.
