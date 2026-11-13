# GNRC_Reloaded handoff

## 2026-11-13 0.1.0 delivered
- Ten GNRC weapons in ZScript on the WoS_Reloaded base (PLAN.md). Rig suite PASSED on tree 6b527a4ee133370f, all ten
  weapons; pk3 out/GNRC_Reloaded_0.1.0.pk3 (40 MB, not committed: out/ is ignored).
- Owner decisions (00:33-00:37): primary / alt / reload / options menu; fists' triggers free (RSQ Melee); pistol
  5-6 shots a second (6 tics, 5.83 measured); rifle alt toggles full auto / 3-round burst; no rocket alt; a quick kick key.
- Taken without asking (tell the owner if he asks): shotgun alt = BD22 VR's slug (rsa_sg_slug), as WoS_Reloaded;
  GNRC's A_Recoil pushes (SSG, BFG) dropped with the other screen effects; the rifle prints "3-round burst" /
  "Full auto" when switched; the chainsaw's on/off alt is gone (the trigger runs it).
- Not shown by the rig (headset): sounds (the rig is muted), the ammo box in hand, the voxel pickups' look.

## Next
- Owner tests in the headset, then behaviour tweaks.

## 2026-11-13 basics (owner 01:41)
- The basics both weapon sets carry (tools/lib/basics.py, identical in both; owner: "the mods themselves will have basic
  pistol whip, jab hook uppercut, lift doors, uppercut barrels, quick grenade"):
  - Grenade: RSQ Grenade's own code (Grenade/zscript/rsqgn weapon, hand, thrown, upg, scatter) as RSQB_GN_, slot 0, the
    frag only (no kinds, no alt fire), Doom's explosion (MISL), barrels take each blast part twice. Pin by the other
    hand's ring or the teeth, arm throw, cook, Quick Grenade key ("Grenade" key section). Stands down for RSQ_Grenade.pk3.
  - Punches: BD22 VR's fists.zs, reading jab / hook / uppercut by direction; an uppercut into a barrel kicks it up and
    away with no damage (RSQ Melee's numbers). Own switch rsqb_punch (on; menu "Punches"). Stand down for RSQ Melee.
  - Pistol whip: BD22 VR's melee.zs PISTOL kind on the pistols (BrutalPistol rows), main and off hand.
  - Doors: Distance Grab's door.zs (palm against a manual door, Use, lift). Stands down for Distance Grab.
- RSQ Grenade no longer stands down for the weapon sets: BD22 VR's grenade placeholder is RSQB_GrenadeLink now.
- RSQ Melee's shove stands down only with Brutal Doom loaded (shove.zs BD22QLoaded checks BrutalWeapon); pk3 rebuilt.
- Suite: two more runs, BASICS alone and BASICS_WITH_SERIES (RSQ Grenade, Melee, Distance Grab).
