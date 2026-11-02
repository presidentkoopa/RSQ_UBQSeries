# fistsprobe (TEST ONLY, never ships)

The probe that gated the Fists tree headless on 2026-11-02 (GBOVR_TREES.md 4.1, "BUILT" notes). It grants Gun Bonsai
VR nodes as a level-up would, prints which nodes each glove (or the player) would be offered, lands punches through RSQ
Melee's own `Deliver` / `Swat` / `ReturnFire` (public for probes), drives the hands through Melee's `RSQML_Sim`, presses
the Headlock grip with Melee's `rsqml_hgrip`, and sends RSQ Gestures' `rsqg_pair` as Gestures would. It cannot prove
anything a real hand or Gestures' own reading does, or how anything looks.

Pack it (a pk3 of `zscript.txt` and `MAPINFO.txt`), then run it last, with `tools/qzd_hidden_run.ps1` from the repo
root (PowerShell):

```
$P='E:\DOOMWork\RSQ_UBQSeries\pk3'; $GB='<Gun Bonsai 0.10.6 pk3>'
& tools\qzd_hidden_run.ps1 -Files "$P\RSQ_Melee.pk3","$P\RSQ_Gestures.pk3",$GB,"$P\RSQ_GunBonsaiVR.pk3",'<fistsprobe.pk3>' -Map MAP01 -WaitTics 105 -Commands @('rsqml_debug 1','netevent fp_hp','netevent fp_tree 0') -Tag fists
```

It names the saber's classes (UBQS_SaberBase, UBQS_Thrown), so load RSQ_Saber.pk3 too. Saber events: `fp_sab` (0 give, 1 offers and levels, 2 grant), `fp_sabthrow` (two marks and the saber's own Throw), `fp_sabhit` (a hit paid to the saber). Every line it prints starts `FP `; Melee's own lines with `rsqml_debug 1` start `RSQML`.

| Event | Args | What it does |
|---|---|---|
| `fp_tree` | stage | prints each glove's nodes and what it would be offered |
| `fp_ptree` | stage | the Guard family's player offers |
| `fp_grant` | node, levels, hands (0 both, 1 main, 2 off) | adds levels to the gloves (index into `NODES`) |
| `fp_pgrant` | node, levels | adds levels to the player |
| `fp_punch` / `fp_hit` / `fp_again` / `fp_again2` | kind / hand, monster / hand, head | a punch on a new or the last monster |
| `fp_seq` | kinds as digits (112), 1 = a Baron, health | alternating-hand punches every 6 tics |
| `fp_juggle`, `fp_meteor`, `fp_pound`, `fp_clear`, `fp_cluster` | | Power and Elemental set-ups |
| `fp_guard` | 1 up, 2 push, 0 down | the Guard through `RSQML_Sim` |
| `fp_soak`, `fp_fire`, `fp_release` | | the Guard's soak, a fireball at you (1 swat, 2 punch back), the release |
| `fp_grab`, `fp_offmove`, `fp_letgo`, `fp_held`, `fp_shieldhit`, `fp_heldpunch`, `fp_target` | | the Headlock |
| `fp_levels`, `fp_armor`, `fp_gun`, `fp_shove`, `fp_windup`, `fp_taunt` | | Berserk, Gun hand, Critical Hits, Taunt |
| `fp_hp`, `fp_clean` | | 5000 health; remove every monster |
