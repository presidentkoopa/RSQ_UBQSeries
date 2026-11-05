# 0.99a bug list: status (updated 11-04 evening)

Your calls from 11-04 are noted. Extra fixes you asked for in the same pass: Force push returns fireballs (FIXED 08de3d0f4), Brutal Doom's dying bodies drop no bits (FIXED 47687e56c), OVERKILL off by default (FIXED 47687e56c), every holster zone shows the sphere marker (FIXED 48e344e39).

| # | Item | Status |
|---|---|---|
| 1 | SlowMo: Lean Out of Bullets row ignored with Gun Bonsai VR | In progress: the row will always be able to turn it off; the upgrade still decides turning it on. |
| 2 | SlowMo: gauge stuck full during Deeper / shootdodge | In progress: gauge measures against the real depth. |
| 3 | SlowMo: CREDITS missing coldcite's bar art | In progress: credits added. |
| 4 | Score: sound origins missing from CREDITS | FIXED (383b26123): origins recorded. |
| 5 | Score: fonts credit contradicts itself | FIXED (383b26123): your call, the fonts ship with credit. |
| 6 | Score: settings with no menu row | Menu pass (you said: fix them now). |
| 7 | Score: stale Headshot comment | FIXED (383b26123). |
| 8 | Laser Sight REAL BUG: Target Lock can never turn on (GBOVR without the Rig) | In progress: falls back to the menu switches when the upgrade path isn't there. |
| 9 | Gun Cards: JFO font licence | FIXED (1c5d2405b): your call, ships with credit. |
| 10 | Gun Cards: status card missing with Draw in the World | FIXED (1c5d2405b): your call, it shows in both modes. |
| 11 | Gun Cards: Inspect Gesture label | Menu pass. |
| 12 | Wheel: Fold Warning default off its slider scale | FIXED (76f23fe4f). |
| 13 | Wheel: stale comments | FIXED (76f23fe4f). |
| 14 | Distance Grab: bind rows need Button Fallback | Menu pass (label). |
| 15 | Distance Grab: main-hand walk-up grab with secondary button mapping | Engine limit (main grip is only a shift with secondary mappings on). Main-hand grab works on Use (bindable); the controls pass ships "PresidentKoopa Controls". |
| 16 | Distance Grab: comment and missing rows | Menu pass. |
| 17 | Distance Grab: dead Gun Bonsai grab-tree code | FIXED (8340a48a5): removed, behaviour identical. |
| 18 | Grapple: silent until learned in Gun Bonsai VR | FIXED (8340a48a5): "Grapple: learn it in Gun Bonsai", at most every 3 s. |
| 19 | Grapple: rope-only options don't say so | Menu pass. |
| 20 | Grapple: missing rows, dev note in CREDITS | Menu pass (rows). |
| 21 | Gestures: dead Thrust and Pull Events switch | FIXED (8340a48a5): your call, removed. |
| 22 | Gestures: shows nothing alone | Your call: left as is. |
| 23 | Gestures: old README in pk3 | FIXED (bccb472dd). |
| 24 | Gun Bonsai VR: Gestures-only upgrades offered without Gestures | FIXED (15fb2dbfa). |
| 25 | Gun Bonsai VR: Force hand XP vs Force upgrades | FIXED (15fb2dbfa): your call, Force gets 50% of saber XP plus its own; one shared pool. |
| 26 | Gun Bonsai VR: binding warning at every start | FIXED (15fb2dbfa): no mode breaks per-hand XP, warning removed. |
| 27 | Gun Bonsai VR: dead Tuning rows | Menu pass. |
| 28 | Gun Bonsai VR: HUD settings with no rows | Menu pass. |
| 29 | Gun Bonsai VR: skins vs left-handed | FIXED (15fb2dbfa): skins mirror like Gun Bonsai's gauges. |
| 30 | Gun Bonsai VR: COPYING mid-sentence, old readme.txt, comment | FIXED (15fb2dbfa). |
| 31 | Gun Bonsai VR: uncapped upgrades | FIXED (15fb2dbfa): capped at 5. |
| 32 | VisualRewards: JFO font licence | FIXED (32a06526c): ships with credit. |
| 33 | VisualRewards: CRIT word unused | No change: waits for Critical Shots after 2.0. |
| 34 | VisualRewards: stale comments | FIXED (32a06526c). |
| 35 | VisualRewards: bits don't come to you | FIXED (47687e56c): 2 m pull by default. |
| 36 | Repo: shared-checkout pulls racing | FIXED: commit helper, no pulls in the shared folder. |
| 37 | Accessibility: Menus: Simple uses a stale list | FIXED (26fbeacae): covers all 20 mods. |
| 38 | Menu order: Melee sorted as unknown | FIXED (26fbeacae): mods listed by group. |
| 39 | Miniboss: stale comment | FIXED (0bb9489d5). |
| 40 | ShieldSaw: no CREDITS.txt | FIXED (9a1f611b3): the README's history (id Software, Ermac's Rusted Legacy) shipped as CREDITS.txt. |
| 41 | ShieldSaw: stale comments | FIXED (9a1f611b3). |
| 42 | ShieldSaw: old README in pk3 | FIXED (bccb472dd). |
| 43 | Rig: cigarette slow-mo filed as automatic | In progress: tagged by name. |
| 44 | Rig: other packs' guns not drawn on the body | FIXED (c54b220c0): vanilla's eight guns drawn with BD's meshes, no BD needed. |
| 45 | Rig: menu leftovers | FIXED in part (9d687a780); rest in progress. |
| 46 | Rig: stale cig.zs label | In progress. |
| 47 | FnF: flares after death | NOT A BUG: dying restarts the map and refills; a netplay refill was added. |
| 48 | FnF: chest pocket has no marker | Your call: always show flare, flashlight, whip, sabers, saw, each with a Show toggle in its own mod (menu pass). |
| 49 | FnF: stale comment, grip key row | FIXED (9d687a780) comment; row in menu pass. |
| 50 | Grenade: co-op, anyone can shoot any grenade | Your call: kept, shooter gets the kill (being documented). |
| 51 | Grenade: off-hand grenade untested | In progress: rig test, fix what fails. |
| 52 | Melee: no fists by default | FIXED (8a7082db0): punch with any fists. |
| 53 | Melee: settings with no rows | Menu pass. |
| 54 | Grenade: either hand's ray can set off a grenade | In progress: only the hand that fired. |
| 55 | Saber: Lightning Beam row needs Gun Bonsai VR | Menu pass (label). |
| 56 | Saber: model/sound authors unrecorded | FIXED (2a5a7a2eb): your call, ships with the credits you gave. |
| 57 | Glow: Miniboss's Own colour always red | FIXED (0bb9489d5): Miniboss reports each boss's colour. |
| 58 | Glow: level-up wave needed Gun Bonsai VR | FIXED (0bb9489d5): listens to plain Gun Bonsai too. |
| 59 | Glow: debug not in Reset All | NOT A BUG: it already was. |
| 60 | Whip: no Controls page | Menu pass. |
| 61 | Whip: debug comment vs menu | FIXED (9d687a780). |
