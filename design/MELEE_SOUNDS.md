# Melee sounds and the Boss klaxon (owner, 2026-11-16 04:25-05:20)

The owner's punch sounds (uploads punch1-punch11; punch8 = punch1 and punch4 = punch2, so 9 unique) and the klaxon,
judged on rig preview clips (`/mnt/user-data/outputs/melee_preview/`, real QuestZDoom 17.3 footage on his order). His
verdict (05:20): "have the kick sound also be our uppercut sound, and i'm happy with them. new klaxon sound in folder, we
can use it."

## The mapping (approved)

All sounds as mono 44.1 kHz copies (stereo does not place in 3D). Each impact's loudest point lands on the hit.

| Move (mod) | Sound | Treatment |
|---|---|---|
| Swing whoosh, fist and boot moves (RSQ Melee punches, the kick) | punch10's first 108 ms (its lead-in, before its own impact) | on the first tic the fist / boot is seen moving |
| Quick jab (RSQ Melee) | punch9, punch6, punch1 | one per hit, rotating, ±5% pitch |
| Hard punch / hook (RSQ Melee) | punch11 (right), punch5 (left) | as is |
| **Uppercut** (RSQ Melee) | **the kick's sound** | as the kick (owner 05:20) |
| Pistol whip (RSQ Melee; the weapon sets' basics where they have one) | punch11 + a small clank | clank: the first 55 ms of `Monsters/sounds/combatfx/casings/DSRIFLC2.ogg` at 0.3 gain |
| Gun-butt shove (RSQ Melee) | punch3 + thud | punch3's first 14 ms trimmed, −15% pitch; thud: `Melee/sounds/rsqml/fx/thud2.ogg` at 0.4 |
| Kick (RSQ Grapple's arrival kick) | punch7 + thud | punch7 −20% pitch, **its soft start trimmed so the thump (its peak, ~70 ms in) lands on contact**; thud2 −15% pitch at 0.55. The heaviest of the set |
| BOSS INCOMING! (the banner) | **the Series' own klaxon** | **twice only**: on the banner's pop and at FIGHT IN 1.00 (~1.9 s apart; owner: three were too close together) |

## The klaxon

Made for the Series from scratch (a synthesized ship-horn "ah-OOO": a quick rising growl into a held, slightly falling
tone, two voices beating plus a sub-octave growl, a little drive; 0.85 s). Nothing to credit or license. The Star Trek
red alert (TrekCore) is not used.

## Credits

- punch1-punch11: the owner's; **source to be found** (owner 04:39: "i'm sure i'll find the punch source in time").
- klaxon: original, made for the Series.
- thud2 (RSQ Melee) and DSRIFLC2 (RSQ Monsters): already credited in their mods.

## Built / not built (2026-11-16)

| Part | State |
|---|---|
| RSQ Melee: whoosh, jab, hook, uppercut, pistol whip, butt shove | Not built |
| RSQ Grapple: the kick | Not built |
| The klaxon on BOSS INCOMING! | Not built |
