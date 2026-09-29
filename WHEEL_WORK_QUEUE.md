# Weapon wheel: queued work

**Marked by the owner, 2026-09-18.** Nothing here is started. Nothing here is urgent. This file exists so
none of it gets rediscovered or re-argued later.

---

## 1. REMOVE the inventory wheel

**Owner:** "i will remove the inventory wheel, i never really liked it anyway."

Straight removal, not a rework. It also happens to delete a netplay defect for free, which is why it is
first in this file rather than last:

> **H7, engine netplay audit 2026-09-18.** `hw_vrwheel.cpp:1286-1298` -- the Inventory branch sends
> `SendItemUse` (which correctly becomes `DEM_INVUSE` and replicates) and ALSO writes
> `player->mo->InvSel` and `player->inventorytics` locally, on one machine, from a handler that runs
> off the game tick. `InvSel` is read by the `invuse`/`invnext`/`invprev` path, so it is a live
> divergence in co-op, not a cosmetic one. The WEAPON branch directly above gets this right and says
> why in a comment: it queues everything through `DEM_ZSC_CMD` so the change is never seen half
> applied.

That hazard was left unfixed in commit `8ca055a6a0` specifically because verifying a fix needs a hand on
a controller. Removing the branch removes the question. **When this is done, strike H7 off the netplay
list -- do not "fix" it as well.**

---

## 2. REDESIGN, slight: the star chart and the hex

**Owner:** "mark star chart and hex for slight redesign."

SLIGHT. Not a rebuild. Detail to come from the owner -- do not guess at what is wrong with them and do
not start until they say what they want changed. Ask when it comes up.

---

## 3. RETEXTURE and RE-FONT the wheel itself

**Owner:** "mark wheel itself for a retexturing and a font change. we will texture with the sbarinfo,
and use the doomfont with colored text so the whole thing looks less AI generated, which yes it is."

Two changes, one goal, and the goal is the part that matters: **it should stop looking generated.**

- **Texture from SBARINFO.** Use the status bar's own graphics as the wheel's material rather than
  flat generated panels. The point is that the wheel then shares a visual vocabulary with the rest of
  the game instead of looking like a UI kit dropped on top of it.
- **DoomFont, with coloured text.** Not a clean geometric face. The engine's own font, in colour,
  because that is what everything else in this game is set in.

**Design note for whoever picks this up:** the owner has named the failure mode themselves, so take it
literally. The look to avoid is the one a generator reaches for by default -- even, evenly-spaced,
evenly-rounded, one accent colour, a neutral sans face. The wheel should look like it belongs to
*this* game: id's font, the status bar's own plates and bevels, colour used the way Doom uses colour
(ammo, health, keys -- meaning, not decoration).

---

## Order

None of this blocks anything and none of it is scheduled. The engine queue ahead of it, in the owner's
own order: lanes finish their current work, then the respawn / level-transition crash, then the
TwoHanded design pass. See `C:\Users\Command\.claude\projects\E--DOOMWork\memory\next-big-jobs-after-lanes.md`.
