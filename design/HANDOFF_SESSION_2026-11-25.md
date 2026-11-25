# Handoff, 2026-11-25 (evening pause)

Owner's stopping point: "full steam ahead on the bosses ... that will be our pausing point". "no rig checks just
confirm it loads".

## State
- **All 18 Big Bosses are kits from their own code** (Miniboss/zscript/rsqmb/bigkit.zs, bk/bk_*.zs). Code only:
  none has been run in a fight. Loads: owner's order (fullorder_y, gate16) and Miniboss / VisualRewards / Monsters
  each alone, no script errors.
- Kit = card name/kind, weak points per act, its own opener state (+ optional frame letter), its own spawns only
  (none: no GUARD), OnAct (body swaps: Knight, White Hot, Noctis, Terror), Step/Due cues (Player X's jam, 45 s
  fallback; Backstabber's GETTO), Watch (Vengeful Soul hatchlings, Terror's splits), Epilogue (CYBERTRON ends on its
  Romero head, 15 s timeout).
- MISS = its own state runs; nothing of ours fires. The old invented parts (rings, beams, blobs, squires, ghost
  guns, red-tier summons, BACKFIRE) are dead code behind `pers` (BB_NONE whenever a kit exists); remove later.
- Owner's names: SHOCKMASTER, MACROSS MISSILE SWARM, WARFACE, NOCTIS, PURIFIER, CYBERTRON; #18 WHITE SPIDER OF
  TERROR; Benellus' kind GOD OF SHOTGUNS. Boss bar, card and VisualRewards banner (service "bigname") use them.
- Lag (angrier Benellus): BD22 VR 2.0.5y caps bullet holes (RSQ_HoleCap, 192); RS_SparkFireBen sparks every 2nd
  tic. Rig: 4,500 -> peak 1,500 actors. In PK3TEST. Rig only, not headset-confirmed.

## Open (from the kit agents' reports)
- First rig round of the 18 fights (when the owner wants it).
- Bog: RS_ShadowBeast_Ballex2 / Ballex3 are fired by Weave1/2 but no class defines them (fire nothing).
- Point size boosts (Warlord / Bog 1.35x) gone with the kits.
- Untracked spawns that outlive a fight: CYBERTRON's barons (Phase2/FatalBarons), Spidey's Sentinels and Orb summons.
- Noctis act 3 and White Hot act 3: the extra Voids / thirds hold every GUARD until dead or the 20 s cap.
- Shockmaster: spike spread via user_angle unproven; GUARD wave 7 ignores rsqmb_big_summon_max.
- Macross Miss8 opens on its own A_Jump: half its misses in acts 2-3 are Miss1-4.
- Comeback toast "+50% DAMAGE 10 S" has a "%" (owner dislikes %).
- Old BD22 VR pk3s (2.0.5g..x) still in PK3TEST.
