# proftool: per-hook script timing (TEST ONLY, never ships) — and the performance handoff (2026-11-27)

## For the local agent: what to do next

The owner asked for the series to make better use of the limited QuestZDoom engine ("anything from performance
optimizations to dynamic lights"). A cloud session did the CPU (ZScript) side on the Linux QZD 17.3 rig; the parts that
need the owner's real hardware are yours.

**Scope (owner):** RSQ mods (this repo) and BD22 VR Reloaded (RSQ_BD_VR_Reloaded) are ours to change; RSQ_Monsters is
ours. brutal22test6, XMVE and the other third-party mods are not (measure them for context only). The coloured
RSQ_BDXMTiers pk3s are not our concern. **Ping the owner before CUTTING anything** (removing a feature, lowering a look);
optimizations that keep behaviour identical are fine, but prove them identical (below).

**The owner's setup:** engine `E:\DOOMWork\qzdoom-17-3-Windows-64bit\qzdoom.exe` (QuestZDoom 17.3, PC VR / SteamVR);
load order `D:\SteamLibrary\steamapps\Common\DooM VR\__CurrentRotationDONOTDELETE` (numbered third-party pk3s first,
then the RSQ_*.pk3 alphabetically; the RSQ pk3s there are this repo's `pk3/` builds as of 2026-11-27). The Windows
headless rig is `TestRig/README.md` + `tools/qzd_hidden_run.ps1` (`-Pose` fakes the headset and controllers).

### Done (measured on the Linux rig, full load order, a fight: god, idkfa, 20 summoned monsters, holster draws, firing)

| What | Before | After | How |
|---|---|---|---|
| Tactical Rig WorldTick | 4.3 ms/tic | 1.9 ms/tic | ClutterPass re-runs HandActs only when ClutterSig changes (+ every 35 tics); verified 0 mismatches against the full answers every tic |
| Distance Grab RSQDG_Hold spawn hook | 0.72 ms/tic | gone from the top 40 | missile list pruned once a tic, not once a missile spawn |
| SlowMo, Grenade (2), Wheel stats, Melee Slappers spawn hooks | 0.07-0.18 each | gone from the top 40 | settings read once a tic; CeilWatch's name test cached per class; class tested before settings |

Script time in the fight: about 13.4 -> 11.1 ms/tic (the rig renders in software on 2 cores: absolute numbers are
inflated, the ranking is what counts). Commits: "Tactical Rig: the clutter pass ..." and "Performance: spawn hooks ...".

### Still open, ranked (fight, after the fixes above)

| ms/tic | Hook | Notes |
|---|---|---|
| 2.1 | RSQTR_Rig.WorldTick | what is left: DrawMarkers' per-place drawing (~1 ms), the hand loop (~0.45). Settings are read by name per place per tic (Flag/Num/Opt): cache them once a tic |
| 0.78 | RSQTR_MirrorBody.WorldTick | the mirror's body copy: check whether it does its work while no mirror is open / in view |
| 0.60 | RSQDG_LockOn.WorldTick | Distance Grab has six per-tic handlers (LockOn, Near, Aim, Laser, Grab, Door: ~1.6 ms together): look for shared work (each finds the hands / targets again) |
| 0.42 | RSQLS_Sight.WorldTick | Laser Sight |
| 0.31 | RSQFF_Shown.WorldTick | FnF; also RSQFF_Handler 0.21 |
| 0.29 | RSQ_Counters.WorldTick | BD22 VR Reloaded (ours) |
| 0.25 | RSQGC_GunCard.WorldTick | Gun Cards |
| 0.23 | SSQ_Handler.WorldTick | ShieldSaw |
| 0.22 | RSQTHP_DnDriver.Tick | VisualRewards' HP bars |
| 0.20 | RSQ_PlayerRound.Tick | BD22 VR Reloaded's rounds (per actor) |
| 0.19 | RSQG_Handler.WorldTick | Accessibility's gestures |
| 0.20 | item.WorldThingSpawned | third party (UA Ambient Decorations): not ours |

General pattern across the series (counted in the source): ~685 CVar lookups by name, ~273 ServiceIterator.Find by
name, 58 ThinkerIterators, 90 per-tic WorldTicks. Caching a CVar / Service pointer once per tic or per level is the
cheap, identical-behaviour fix wherever one sits in a per-tic or per-place loop.

### Yours (needs the real hardware)

1. **Confirm in the headset / on PC** that the fights feel the same and frame time dropped (the engine's `stat fps`,
   `stat events` if present, and the timing below on the Windows rig).
2. **GPU and dynamic lights** (not measurable on the Linux rig): 37 `A_AttachLight` sites. Measure a fight with lights on
   and off (`gl_lights 0/1`) on Quest and PC. Candidates: a cap on live FX lights (e.g. 4, newest wins), lights that are
   not re-attached every glow step (Grenade's flipbook `flip.zs`), GLDEFS-bound lights over script-attached ones.
3. **Draw calls:** Gun Cards' and Miniboss's wrist cards are many PSprite tiles each; the Rig's mirror draws a second
   copy of every stored model.
4. **Load time** of the full load order on Quest (BD22 VR Reloaded's LZMA-packed models).
5. Continue the CPU list above, one item at a time, each proven identical.

## The tool

`instrument.py in.pk3 out.pk3` wraps every `override void <Hook>(...)` (WorldTick, WorldThingSpawned, WorldThingDied,
WorldThingDamaged, NetworkProcess, PlayerEntered, and actor `Tick`) in every ZScript class with `MSTimeF()` timing:
the original becomes `RSQPROF_<Hook>_<Class>` and a wrapper override calls it. It reports to `RSQProf`, a static
handler (probe_zscript.txt + probe_MAPINFO.txt, zip them as `00_RSQProf.pk3`), which prints a ranked table every 350
tics: `RSQPROF <rank> <ms total> <ms/tic> <calls> <Class.Hook>`. **Load the probe FIRST** (before every instrumented
pk3: a class must exist before the code that names it compiles). Python: `python3 -I instrument.py ...`.

- Instrument every pk3 of the load order except brutal22test6 and the voxel pack; keep the originals.
- `netevent rsqprof_reset` clears the counts (do it after setup, so only the scene is measured). The `rsqprof_dump`
  event does NOT print (a static handler's NetworkProcess is not called): run past a multiple of 350 tics.
- A nested Super call in an instrumented parent counts twice (the child's time includes the parent's).
- To time inside a function, wrap statements by hand in a copy: `{ double t = MSTimeF(); X; RSQProf.Add("Name", MSTimeF() - t); }`.
- To prove a cache identical: in a copy, recompute the full answer every tic, compare with the cached one, log mismatches
  (how the Rig's ClutterPass was proven: 0 mismatches through draws, off-hand draws, holsters, pickups, an unassign).
- Linux rig trap: the intermission needs the grip key (`qz_rgrip 1; wait 3; qz_rgrip 0`); a run with the head posed
  looking down at the body renders much slower.
