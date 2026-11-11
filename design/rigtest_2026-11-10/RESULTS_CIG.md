# RESULTS_CIG: the cigarette's slow motion (owner 2026-11-11 13:54)

The owner's words: "Cigarettes: default 15, switching weapons does not end slowmo, holstering does not end slomo. plz make
adjustments, i don't want anything ending cig slmo except Quick/Dead (which might come with it's own, so good) or Death."

Everything below is **rig only, not headset-confirmed**. Logs: rsqtr_messages 1 (T_CIG lines), rsqsm_debug 1 (RSQ_SlowMo
lines), `netevent rsm_state` readouts. Owner's load order, MAP01/MAP02 of doom2, RES 120, no frames.

| Check | What the rig showed | Evidence |
|---|---|---|
| Default reads 15 | `"rsqtr_cig_secs" is "15" (default: "15")`, cfgver 9 | CIG_run1_log.txt |
| Old saved 6 moves to 15 | `set rsqtr_cig_secs 6; set rsqtr_cfgver 8`, then a new map: reads 15, cfgver 9 | CIG_run1_log.txt (CIG_D_MIGRATED_READ) |
| Weapon switch mid-smoke | t211 `use Rifle` during the 2 s smoke: "flicked (lit): smoked, the slow motion starts"; main Rifle, off RSQ_Off_Rifle; `rsm_pulse 15000 25`; smoke kept until t738 (525 tics) | CIG_run1_log.txt (CIG_A_*) |
| Switch while it runs | `use BrutalPistol` 40 tics in: pulse still 486 tics (smoke), not ended | CIG_run1_log.txt (CIG_B_*) |
| Held key on top of it | the slow-motion key on: SlowMo held ON (as before, the key outranks a pulse); key off: "the smoke takes the slow motion back ... until t738", the countdown bar refilled at 12.0 s. Before this change the smoke was lost here | CIG_run1_log.txt (CIG_C_*) |
| Holster grab mid-smoke (real grip, hand at the right hip) | t212 "the main hand's grip at a holster -> flicked (lit): smoked, the slow motion starts"; main BrutalPistol -> Melee_Attacks (the pistol went in the holster), off rsq_hands; smoke 525 tics | CIG_run3_log.txt (CIG_E_*) |
| Level change (`changemap MAP02`, a real exit through the intermission) | "level ends: ... 471 tics left, carried"; on MAP02 t0 "carries 471 tics", t1 "resumed ... kept until t473 (472 tics) at 25%, he moves at full speed"; 400 tics left at the next readout | CIG_run5_log.txt |
| Death ends it | `kill` on MAP02: "smoke slow motion ENDS: death (327 tics were left)"; the world eases back (0.82 -> 1.00) | CIG_run5_log.txt (CIG_F_DEATH) |
| Load check | `bash /tmp/lc.sh TacticalRig SlowMo`: no script error or warning from RSQ_TacticalRig or RSQ_SlowMo (the 4 errors are BD_VoxelPack's voxeldef; the warnings are RSQ_Monsters', both from before this change) | CIG_loadcheck.txt |

Not shown:
- **DOWN ending it.** It is coded (SlowMo clock.zs SmokeKeep: his DOWN calls SmokeEnd), but not run: DOWN needs a monster's
  killing blow, which would mean another scene. DOWN's own slow takes the world to its depth either way.
- **A miniboss window on top of it.** Coded through the same keep (the window's own cut can no longer shorten the smoke),
  not run (no miniboss on the rig maps).
- `map MAP02` (as first asked) is a NEW GAME, not a level exit: nothing is carried across it, and nothing should be. The
  real exit was tested with `changemap`. Rig trap: the intermission only moves on with the grip key (`qz_rgrip 1/0` with
  `vr_secondary_button_mappings 0`); typed +use / +attack and wi_autoadvance did not move it.
