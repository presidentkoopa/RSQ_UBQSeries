# RESULTS_LDH: the LegenDoom HUD, direction D (2026-11-11, one rig run)

The owner's decision of 11-11 15:30 (`design/mockups/legendoom_hud/README.md`): no word over a legendary until it rises,
then LEGENDARY; the pickup card V3 (SOTN shimmer title) for about 3 s; then the card folds into option 1, the row under
the gun hand's Gun Bonsai VR gauge. Built in RSQ Gun Bonsai VR (`rsq/ui/legendoom.zs`: the card and the row) and RSQ
VisualRewards (`zscript/rsqvr/ldword.zs` and the SOTN look in `words.zs`: the word).

**Run LDH1** (`/home/claude/scratch/rig1110/LDH1`, script `evidence/LDH_script.txt`): the owner's order with LegenDoom 3.0
right after doom2 (doom2, LegenDoom_3.0, brutal22test6, BD_VoxelPack, BD22 VR 2.0.4h, LOB, Champions, Gun Bonsai 0.10.6,
the RSQ pk3s), MAP01, 480 px per eye, plus a test probe (scratch `ldhud/probe`) that spawns a zombie, makes it legendary with
LegenDoom's own LDMonsterInit, hurts it to below half, and hands over legendary drops through BD22 VR LD mode's own
pickup (RSLD_LegendaryPickup.Touch). A first launch stopped at startup on the probe's own compile error (a method named
State); no game ran. The probe was fixed and LDH1 ran once.

Script errors: only BD_VoxelPack's 4 known voxeldef errors. None from the series packs.

| Check | What was shown | Evidence |
|---|---|---|
| A legendary at full health: no word | Shown. The zombie carries LegenDoom's token at 300% (60/20), not transformed; nothing over it | `evidence/LDH_1_legendary_full_health_no_word.jpg`, `LDH_log.txt` t116 |
| The same one risen: LEGENDARY | Shown. Hurt to 28 at t146; LegenDoom refilled it to 60 and transformed it; the held word LEGENDARY (SOTN look) is up from t150, two-tone gold on a dark box, over it, with LegenDoom's pentagram on the floor | `LDH_2_risen_LEGENDARY.jpg`, `LDH_log.txt` t146-156 |
| The pickup card mid-shimmer | Shown. Epic Murderous: the orange card, MURDEROUS in look 1 (orange) at t245 and look 2 (light) at t257, "EPIC  RIFLE", LegenDoom's description, its icon in the box | `LDH_3_card_look1.jpg`, `LDH_3_card_look2.jpg` |
| LegenDoom's own pickup screen hidden while the card is up | Shown: none of it (title, chaingun sprite, icon, description) in any card frame. With LegenDoom: Pickup Card off, the same pickup path shows it (last row) | `LDH_3_card_*.jpg` |
| The card folds away | Shown at t324 (the card shrinking toward the row) | `LDH_4_fold.jpg` |
| The folded gauge row | Shown: MURDEROUS under the main (Rifle) gauge; with the Murderous buff, X3 and a drain line that is shorter later | `LDH_5_row_X3_drain.jpg`, `LDH_5_row_drain_later.jpg` |
| No HUD over a menu | Shown: with the RSQ Gun Bonsai VR page open, no card, row or gauge; the page has the two new rows | `LDH_6_menu_rows_no_hud.jpg` |
| Pickup Card off brings LegenDoom's screen back | Shown: a Common Determined shotgun-slot drop with LegenDoom: Pickup Card off: LegenDoom's green title, its sprite, its description | `LDH_7_card_off_legendoom_screen.jpg` |

## Found in the frames, fixed after the run (code only, not shown)
The card, the row and the rarity tick were placed through `Screen.VirtualToRealCoords` with its aspect handling on. That
letterboxes as if the canvas were 4:3, but the gauge's own `DTA_KeepRatio` draw scales plainly. Measured on the frames:
the drawn y was about 0.70 x the gauge's y plus an offset. The row sat about 12 px too low (at 480 px), the tick landed on
the octagon's lower corner instead of its upper one, and the card was 0.75 of its size. `Box()` now uses the plain
mapping (width / fbw, height / fbh), the one Gun Bonsai's own DrawProgressBar uses. Load-checked clean, not run again
(one run allowed).

## Open
- **LegenDoom's buff row cannot be hidden from ZScript.** LDPlayerLoop draws its boxes as HudMessages with id 0. The status bar
  can only detach messages by id, and id 0 would take every other mod's id-less messages with it. The row of D shows the
  same buff (X3 and its drain) below the gauge; LegenDoom's boxes stay at the top.
- **The row's room.** The mockup's HUD plane was an estimate with room to the right of the main gauge. On the rig the main
  gauge sits at the HUD's right edge, so the row slides back in under the gauge. At its corrected height it may meet RSQ
  Score's line. Needs one look (frame) before the owner's headset.
- Not built: Direction D's "Drop: EPIC and the power's name over the glowing drop" (left out of the build brief). The X3
  word is Murderous only (LegenDoom's 3x); other timed buffs show the drain line alone.
