# VisualRewards renders (mockups, never shipped)

## Arrival beams (2026-11-09)

The effect monsters use when they teleport into the fight (the owner: "this death pillar thing is how I want enemies
teleporting in"; "pillar only arrival, no beam out"; it lives in VisualRewards). Pixel art in four flat bands, coloured
by the arriving monster's tier on the 13-colour ladder. `*_full.gif` is game speed (35 tics/s), `*_half.gif` half
speed. Nothing here goes into the pk3 (build_all.sh packs VisualRewards from its `pk3/` folder).

| Variant | What it is |
|---|---|
| V1 | End of Starchild's death-pillar motion (reference only, none of its art) with our own beam; v2 reveals the monster from inside the beam, rings drop down it |
| V2 | Arcade: floor ring flash, the beam slams down, rings ride up it, the monster white silhouette then tier colour then real |
| V3 | The owner's Z-Fighter picks: a blue dome and splash, a column that hides the monster completely, then narrows away |
| V4 | Boss: six beams spiral in, merge, a skull pillar, the monster arrives |

- `arrival_beams/v1/`: first pass, with `beam_tiers_contact.png` (the beam in all 13 tiers).
- `arrival_beams/v2/`: more frames, V1's reveal and rings, V3 with more life. Owner: all four greenlit; V3 to come in an
  indoor (hits the ceiling) and an outdoor (climbs out of sight) version.
- `arrival_beams/v3/`: V3 indoor (the column is cut at the real ceiling, the splash hangs from it, sparks drop) and
  outdoor (no cap; a stepped taper climbs out of sight into the sky). In game: sky or a ceiling above the column's reach
  (~166 units) picks outdoor, otherwise indoor at that ceiling's height. 34 tics each. Owner, 2026-11-09: greenlit.

Sources: our own art drawn in code; V3 and V4 use frames cut from the Z-Fighter effects sheet (a rip; it asks for credit),
posterized to our bands — credit or redraw before release. Monster sprites are the project's.

Built into the pk3 on 11-09 (V1 v2, V2 v2, V3 v3 indoor + outdoor, V4 v2): `tools/gen_beams.py` exports the art from these
mockups (copied to `tools/beam_spec/`), `pk3/zscript/rsqvr/beams.zs` plays them (RSQVR_Service "beam").
