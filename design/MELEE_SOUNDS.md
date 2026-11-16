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
| BOSS INCOMING! (the banner) | **his siren** (Pixabay "Siren Alarm", freesound_community) | **exactly as the file is**, from its own start, played once on the banner's pop and stopped after its second whoop (4.2 s of the file, a 50 ms fade at the stop); nothing cut out or re-timed (owner 05:26-05:27: "why did you cut it at all?" / "good, approved") |

## The klaxon (replaced by the siren, 05:27)

Made for the Series from scratch (a synthesized ship-horn "ah-OOO": a quick rising growl into a held, slightly falling
tone, two voices beating plus a sub-octave growl, a little drive; 0.85 s). Nothing to credit or license. The Star Trek
red alert (TrekCore) is not used.

## Credits

- punch1-punch11: the owner's; **source to be found** (owner 04:39: "i'm sure i'll find the punch source in time").
- the siren: Pixabay "Siren Alarm" by freesound_community (Pixabay Content License: free use, no credit required; credited anyway).
- the klaxon (original, made for the Series): not used.
- thud2 (RSQ Melee) and DSRIFLC2 (RSQ Monsters): already credited in their mods.

## Built / not built (2026-11-16)

Every sound is one baked file (trim, pitch, layers, gains and fades in it; the preview's overall gain x1.0584 kept, so the
levels are what he heard). The recipe and its record: `Melee/tools/meleesounds.py` (sources: the owner's uploads, not in
the repo). The jab's +/-5% is drawn at play time. Rig evidence: the owner's load order (BD22 VR Reloaded 2.0.4x) plus a
probe that logs, every tic, which sounds the player has started (IsActorPlayingSound).

| Part | State |
|---|---|
| RSQ Melee: jab (`rsqml/jab1-3`: punch9, punch6, punch1, in turn, pitch 0.95-1.05 at play) | **Built, rig only, not headset-confirmed.** Hits t150 / t184 / t218 / (t247 missed): jab1 1.020, jab2 0.954, jab3 1.003, each on its hit tic |
| RSQ Melee: hooks (`rsqml/hookr` punch11, `rsqml/hookl` punch5, by the physical hand: a left-handed player's main hand is the left) | **Built, rig only.** Right hook t342 hookr, left hook t381 hookl, on their hit tics |
| RSQ Melee: uppercut (`rsqml/uppercut` = the kick's file) | **Built, rig only.** Brutal Doom's fists into a Baron t140; an uppercut into a barrel (Barrel Launch) t203 |
| RSQ Melee: the swing whoosh (`rsqml/swing`, punch10's 108 ms lead-in x0.8) | **Built, rig only.** On the tic a fist's swing arms (0.15 m at punch speed), hit or miss, only when the swing goes out (forward or rising): jab whoosh t148 / hit t150, as on the preview (149 / 151 visible). The return stroke makes none (rig: it did, before the outward check) |
| RSQ Melee: pistol whip (`rsqml/whip`, punch11 + DSRIFLC2 first 55 ms x0.3) | **Built, rig only.** club.zs (BD22 VR's guns): t171 and t204, on the hit tic. BD22's MeleeStrikeNormal under it is muted (its channel 3 stopped as it bursts): Melee/Flesh 0 on ours, 1 on an unmuted control launched the same way |
| RSQ Melee: gun-butt shove (`rsqml/buttshove`, punch3 14 ms cut -15% + thud2 x0.4) | **Built, rig only.** club.zs butt strike t163 (KickAttack muted, Kick/flesh 0); shove.zs without BD22 VR t163; a barrel launched by the shove plays it too |
| RSQ Grapple: the kick (`rsqgr/kick`: punch7 -20%, its soft start cut so its thump is 9 ms in, + thud2 -15% x0.55 with its onset on the thump) and its whoosh (`rsqgr/whoosh`) | **Built, rig only.** Whoosh t104 (85 units, 4 tics out), kick t108 on arrival: the preview's 105 / 109 visible. Replaces jpalomo's meat hit and Melee's thud on the kick. (The file's loudest 5 ms is the thud's body, 20-25 ms in) |
| The siren on BOSS INCOMING! (`rsqvr/siren`, RVQSIREN.wav) | **Built, rig only.** Started once, in the tic whose frame first draws the banner (t66, t0 67); nothing at FIGHT IN 1.00 (t137). Heard by the banner's player (the console player's machine), unattenuated; not with Banners off |
| The weapon sets' basics pistol whip (`weaponsets/GNRC_Reloaded`, `weaponsets/WoS_Reloaded`) | **Not built: follow-up.** Two other builders were working in those folders on 11-16; the whip there should play the same punch11 + clank (copy `Melee/sounds/rsqml/hit/whip.ogg` under the set's own name) |

Kept as they were: the star punch (`rsqml/star`), the Hadouken and bullet swat-back, the open palm's swat and the guard
(the SuperPunchOut punch set stays for those), Brutal Doom's swing sound on the whip and the butt strike.
