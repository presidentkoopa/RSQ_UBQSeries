# READMEs from code, and what the in-game How To Play needs from them: STATUS

Started 2026-11-27 (owner). Come back to this file first. Branch: `readme-from-code`.

## Why this exists

1. Owner: "all readmes are stale. each mod needs a new readme made from reading the code. possible bugs need to be
   presented to me as questions with selectable fixes."
2. The in-game How To Play (handoff of 2026-11-27: one menu, a tab per loaded mod, Score's Glossary as Score's tab,
   Show Me with the Tactical Rig's ghost hand) is GENERATED from each README's How to play table. So the READMEs come
   first, and their shape is fixed so a generator can read them.
3. Owner: "we should ship an optional default control profile", and "my current ini needs to be dissected to establish
   controls for doom itself, brutal doom vr weapons, and RSQ mods loaded."

## How it is done

- `design/README_FROM_CODE.md`: the brief every reader follows. One reader per mod reads ALL the mod's code, then writes
  `<Mod>/README.md` (fixed template), `<Mod>/docs/README_SOURCES.md` (file:line for every claim) and
  `<Mod>/docs/FINDINGS_2026-11-27.md` (possible bugs as questions, each with candidate fixes).
- `tools/readme/gen_readme_tables.py <Mod>`: fills the README's Keys and Options tables from KEYCONF, MENUDEF ("// tip:"
  comments) and CVARINFO. `--check` fails when a README's tables are stale. Run it after any menu or setting change.
- The owner answers the findings as selectable questions, one mod at a time, most visible first. His answer is written
  into the findings file under the finding ("OWNER <date>: ..."). Fixes are separate commits from the READMEs.
- OWNER RULE (11-27): NOTHING IS PARKED. Every finding ends as a fix or as "intended". Do not offer "park it".
- OWNER RULE (11-27): CONTROLS means everything the player physically does that makes the game respond: every button,
  trigger, grip and stick on both controllers, and every hand or body move, with what it does in Doom itself, in his
  BD22 VR weapons (repo RSQ_BD_VR_Reloaded: his; base Brutal Doom is not his and is only a reference), and in each RSQ mod.

## What the How To Play generator will take from each README

- The table under `<a name="how-to-play">`: columns `Do this | What happens | Needs`. One row = one list entry in the
  mod's tab; "Needs" names the option (with its default) or the other mod. Rows that need a non-default option come last.
- A row whose "Do this" is a body move is a Show Me candidate (names the place on the body).
- The Keys table (GEN:keys): the command for each key, so a page can print the button it is bound to now
  (as `DistanceGrab/zscript/rsqdg/menurows.zs` and Gun Bonsai's menu already read binds), or NOT BOUND.
- Still to decide with the owner (from the handoff): which moves get Show Me first; a first-run "How To Play: F1" prompt.
- Score's font is capitals only, ASCII 32-96: the generator must upper-case and strip anything else.

## How To Play mockups (owner 07:37: "send mock up of how to play using an original idea and presentation, and another in the style of RSQ Score Glossary")

Two artboards on one design canvas, "RSQ How To Play: two mockups": https://claude.ai/artifact/E1RoWfJuQCKPSrnFfuXfpe
- A, original: THE BODY MAP. A figure of your body with a button at each place (mouth, shoulders, chest, belt, hips,
  each hand, both hands). Pick a place: the moves done there are listed, whatever mod they belong to, each with DO /
  GET and a SHOW ME button (the Rig's ghost hand). A strip at the foot shows your keys as bound now, or NOT BOUND.
- B, Glossary style: Score's page as it is drawn (640 x 400 virtual, near black, gold title, a row of tabs in the
  family colours, the list at the left with its value in white, the detail at the right with gold labels), with a tab
  per loaded mod, the list = that mod's moves with the button as the value, the detail = DO / GET / NEEDS and SHOW ME.
HIS PICK (07:4x): "b with a body tab. what does the body tab look like? does it bring up a 3d mirror of the torso,
helmet, hands, and weapons? currently not everything is a world-item. i am open to making everything a world item but
that would be real work. maybe for later. but is it even possible?"
ANSWERED: the Rig already has a mirror (TacticalRig mirror.zs: a copy of you in front of you with the torso, helmet,
every holster's ring and what it holds, your hands as small green spheres). A menu page is flat and the world stands
still behind it, so a 3D body cannot be inside the menu: the body tab is a flat figure in the menu, and a row on it
("Show On My Body") closes the menu and stands the Rig's mirror up with the place lit, the same way Show Me closes the
menu for the ghost hand. Nothing needs to become a world item for that. (07:49, he liked the mockups: "your
mockups are great. maybe when we port to REMA we will have our engine show model in menu." So a 3D model INSIDE the menu
is for the REMA port, where the engine is ours; on QuestZDoom 17.3 it stays the flat figure plus the mirror.) Not in the mirror today: hand models and the
weapons in the hands. Without the Tactical Rig loaded: the flat figure only. Sources for them: Score/zscript/rsscore/glossary.zs, Score's TEXTCOLO.

## Per mod

| Mod | README from code | Sources | Findings | Owner's answers |
|---|---|---|---|---|
| Wheel | done, tables generated, brought up to his changes | done | 19 + 7 small, plus N1 and N2 from him | F1 to F6, F12 and N2 answered; F7 to F19, N1 (no beam) and the small ones still open |
| ShieldSaw | done (44 rows), tables generated | done | 8 + 10 small | none yet |
| SlowMo | done (36 rows; it has an extra section "For other mods": the service), tables generated | done (186 rows) | 11 + 13 small | none yet |
| Tactical Rig | done (70 rows; a second table lists what the rig answers when asked by name), tables generated | done | 11 + 11 small | none yet |
| Distance Grab | done (51 rows), tables generated | done (168 rows) | 10 + 6 small | none yet |
| Grenade | done (43 rows), tables generated | done (495 cites) | 11 + 9 small | none yet |
| Grapple | done (25 rows), tables generated | done | 10 + 4 small | none yet |
| Whip | REBUILT 07:3x to 07:5x as two moves (his words); README and sources rewritten for it | done | the 21 findings are overtaken, see the note at the top of its findings file | his redesign |
| Melee | done (52 rows), tables generated | done (153 rows) | 13 + 4 small | none yet |
| Flashlight & Flare (the menu calls it RSQ FnF (Flash and Flare)) | done (43 rows), tables generated | done (116 rows) | 11 + 7 small | none yet |
| LaserSight | done (43 rows), tables generated | done | 9 + 5 small (F1 already answered through the Wheel) | F1 |
| Saber | done (56 rows), tables generated | done | 13 + 3 small | none yet |
| Score | done (268 rows + 242 combos), tables generated | done | 13 + 5 small | none yet |
| Gun Cards | done (40 rows), tables generated | done | 11 + 6 small | F1, F4 built; F3 became the wrist cards order (below); F5 open with Accessibility |
| Accessibility | done (51 rows), tables generated | done | 13 + 4 small | none yet; owner 08:1x: "accessability is kind of on its way out unless you convicne me to keep it" |
| Gun Bonsai VR | done (38 rows) | done | 12 + 8 small | none yet. Its upgrade trees are GONE from code (owner 11-25); about 130 upgrade names are still read by the other mods and always answer 0 (its F6) |
| Miniboss | done (43 rows), tables generated | done | 11 + 8 small | F1 only the Start Fight card calls a fight (watch check + Use off); F2 a life costs the row; F3 no LUCKY where it cannot rise; F4 no thrall drops guns; NEW one weapon per kiosk; NEW ammo burst when the Boss steps up: builder running. F5-F11, small ones open |
| Graveyard | done (27 rows), tables generated | done | 4 + 4 small | none yet |
| Glow In The Dark | done (33 rows), tables generated | done | 4 + 5 small | none yet |
| PlayLog | done (12 rows), tables generated | done | 4 + 2 small | none yet |
| VisualRewards | done (25 rows), tables generated | done | 10 + 8 small | F1 skip gold roll; F2-F6 remove dead upgrades; F8 keep gold as code has it; F10: world signs stay AND each of LEVEL UP!, REVIVE! (with what it gave), REVENGE!, 1UP! also shows as a toast low in the view, like Score's gold toasts (owner 08:5x); builder running for F1, F2-F6, F8, F10. Small ones open |
| all others | not started | | | |

Order after these: Melee, Flashlight & Flare, Saber, Gun Cards, Gun Bonsai VR,
LaserSight, Score, Accessibility, Miniboss, Monsters, MonsterRecolour, Graveyard, Glow In The Dark, VisualRewards, PlayLog.

## The owner's answers so far

### Wheel (asked 2026-11-27 06:2x)

- The Wheel's controls, in his words: "it is primary fire on either hand to choose and close, offhand secondary fire to
  choose and keep open, and mainhand secondary fire to open rig assignment." Use takes no card. The Open Wheel key opens
  and closes; it is not how a gun is chosen ("why would anyone select a weapon by pressing 'open wheel'?").
- F1 (a gun inside a slot is not reachable by the key alone): intended.
- F2 (Slow Time dead while Freeze Time on): fixed. One row, Time While Open: Normal / Slow / Frozen (`wr_time`).
  He read "Mo" too many times: keep "SlowMo" out of labels; the mod's name appears once, in the tip.
- F3 (Use): Use with the hand in a card no longer takes it. Open: Use from a distance still reaches the game; Use still
  opens a fan on the When Crowded layout.
- F4 (a press on the data sheet does nothing): intended.

Second round (06:4x):
- Use and grenades: "when the wheel is open i don't want to be opening doors or throwing grenades." Done: the Wheel takes
  Use, Toss Grenade (+user1) and Quick Grenade while it is up.
- "i've never known what hold, point, release ever meant so remove it": done. The key is "Open Wheel": it opens and closes.
- "the whole stick lights a card thing is stupid, get that out": done.
- Next / prev and the gold light: new row Skip Holstered Guns (default Off; On: holstered guns are skipped and the
  cards next / prev reaches wear the light).
- The data sheet: he says it already shows the pointing hand's gun; the code now uses the pointing hand's copy too.
- HE REPORTED (N1): sabers, whip, hands, chainsaw, axe, maybe the ShieldSaw cast NO BEAM in the wheel.
  LIKELY CAUSE (found by the Whip's reader, 11-27): every one of those is a melee weapon. RSQ LaserSight draws no
  beam for a melee weapon (LaserSight sight.zs:519), so the hand gets only the Wheel's own ribbon, and that is 0.12
  units wide (Wheel wr_q_shim.zs drawBeam: `b.scale = (len, 0.12)`): about 3.5 mm. A gun's hand shows LaserSight's
  beam instead. CONFIRMED by LaserSight's reader (its findings F1): MELEEWEAPON or CHEATNOTWEAPON gets no beam, and no
  setting gives one. Also: any gun not in LaserSight's measured table (plain Doom's guns) has a dot and no beam (F2).
- N2: reach in, pull a card out, throw a gun back: "Remove both", "Remove it". Done.
- So the Wheel's whole control set is now: the Open Wheel key (opens, closes; twice quickly swaps back to the last gun);
  point a beam; primary fire on either hand chooses and closes; the off hand's secondary fire chooses and keeps it open;
  the main hand's secondary fire opens the holster assignment; next / prev weapon keys. Nothing else acts on a card.

### Third and fourth cards (07:10 to 07:16)
- Grenade type kept across maps: "Keep my pick". Done.
- SlowMo running dry: "Same sound and rumble". Done.
- Rig, Saber on Hip: "Remove the row". Done.
- Rig, Body Turn Angle / Delay: "Drive the real torso follow". Done.
- Rig, cigarette pocket: "find a place ... which does not overlap but is still on the left side ... maybe above the
  grenades? or above and to the left of it so you can reach with your mainhand". Moved to 5 cm left of centre, 30 cm
  under the eyes (2 cm clear of the left shoulder and left chest holsters). Above the grenades has no room.
- Grenade, the pin: INTENDED. "the whole reason you can pull with your teeth is because of this."
  LESSON: before asking about a "bug", check whether the mod already has the other way to do it and say so.
- Distance Grab, full ammo: "Say AMMO FULL, drop it". Done.
- Grapple, the air spike: he wanted it explained, then: "Bring it back" (while flying to a monster in the air, or
  right after the kick, both hands down hard spikes it; the pull-to-you, Scorpion Pull and Yank Picks stay gone and
  their unused code is deleted). A builder does it.
- Wheel, the missing beam (N1): "Make the Wheel's beam thick". Done: 0.12 to 0.4 units wide. Needs a headset look.
- RULE FOR EVERY AGENT PROMPT FROM NOW ON: never run `git stash`, `git checkout`, `git reset` or any git command that
  changes the working tree or the index. At 07:20 an agent stashed the whole tree for half a minute; every other
  agent's uncommitted work vanished for that time. Read old versions with `git show <ref>:<path>` only.

### Fifth card (07:3x)
- WHIP, HIS WORDS: "the whip is been conceptually cool but a huge pain in the ass. what i want is to do a big wide
  swing and damage + knockback + slomo in a nearly 120 arc on front of me, and if i crack down to the ground the impact
  sends out a shockwave and sends enemies airborne with contextual slowmo. does this seem reasonable? i just want to
  throw my hands up with this thing i hate it so much", and on the crack's strength: "see previous answer. i want to
  tone this thing down". So the Whip's findings F1 and F2 are overtaken: the Whip is to be cut down to those two moves.
  Proposed back to him in chat; NOT built until he says which of the rest goes.
- MELEE, HIS WORDS: "throwing barrels is still all wrong, i do not have a hand pose for slapping, so i never thought to
  use it, what do you recommend for this? can triggers do targeting for barrel throwing or barrel punching, and can
  fists just smack away missiles". Recommended back to him in chat; NOT built until he answers.
- Rig, free a holster by holding an empty hand in it: "Remove the hold". Done.
- 07:31 he asked what is being done about his answers on the Whip and Melee: both are being BUILT from his words (two builders): the Whip cut to the wide swing and the ground crack; Melee: fists knock shots away with no pose, and the trigger aims a punched or shoved barrel.

- 07:33 BARRELS, HIS WORDS: "i feel like melee should have throwing barrels, they have punching barrels and
  gun-butt-shove barrels and pistol-whip-to-launch-barrels??" AGREED. TO BUILD when the Melee builder is out of Melee's
  files: a barrel thrown from the hand flies as Melee's barrel launch does (same target rule: the trigger's painted
  monster, else the way it was thrown; same speed, blast, slow motion). Distance Grab keeps the grab and the carry (it
  is how a barrel gets into the hand) and hands the throw to Melee by name when Melee is loaded; without Melee its own
  throw stays. WHO_OWNS_WHAT.md gets the row: "sending a barrel at a monster (punch, shove, whip, throw): Melee".

### The saw, BUILT 07:06 to 07:27 (commit "ShieldSaw: the owner's controls"), not compiled, not run
What the builder decided where his words did not, to tell him and to check on the rig:
- A throw needs Throw Speed (2.2 m/s) with or without rings; the old "1 m/s toward the first ring" rule is gone.
  Harder: no bonus at Throw Speed, the full Rev Throw Bonus at twice it. The row keeps its name.
- No throw in the 10 tics after the saw comes into the hand; a shove that lands as a bash is a bash, not a throw
  (the throw fires a tic late to let the bash win). ANY OTHER FAST FORWARD MOVE OF THE OFF ARM THROWS IT.
- Gun Bonsai VR's Shield Dash (a 3 m/s thrust) will probably be thrown instead: the two share one motion.
- Mounted: the off hand's grip at that shoulder draws and puts back; Use does nothing. Disc out: the grip is refused.
- Not caught and not mounted: the disc flies to you and vanishes. Mounted: it goes to the shoulder.
- Shoulder for Shield (Rig) off means no mount. A player who had Take It From: Shoulder is NOT mounted for him.
- A mounted saw's card in the wheel reads as holstered, so Skip Holstered Guns would skip it in next / prev.
- Removed names still typed by rig test tools (not shipped): ssq_recenter, ssq_mount_spot, and a probe that expects a
  stowed plate on the back.

### Sixth card (07:4x)
- Mushroom blast: "Shrink it with the mega". Done.
- Flashlight & Flare: "remember it across maps, and figure a way to get the flashlight beam not lagging with the
  flashlight mesh". A builder does both.
- Saber: "one press. one push, and disable flick for second beam. second beam is a cool idea but it fires constantly
  when we swing it ... and we don't have the buttons for alt-fire deploy second saber, right?" Done: one push a press;
  no wrist twist toggles a second blade. (Right: both sabers' alt fire is the Force.)
- HE ASKED: "are you making changes to each mod's options menu as we are going? keeping the existing style?" YES: every
  change that adds, removes or renames a setting edits that mod's MENUDEF in its own style (short label, a "// tip:"
  line, front page for a player's choices, Test and Debug for the rest, removed settings kept in CVARINFO as RETIRED),
  and the README's options table is regenerated from it. Not yet looked at in the game.
- Melee's fists and trigger paint: BUILT (commit "Melee: fists knock shots away ..."). To tell him: a moving fist now
  also stops bullets (that was the open palm's rule); the paint needs the hand held fairly still (under 1.2 m/s) and
  the trigger held until the blow; a green ring shows over the painted monster.
- Barrels thrown from the hand, and the pistol whip into a barrel: a builder (Melee + Distance Grab).

### ShieldSaw (asked 2026-11-27 06:5x): HE PROPOSED A REDESIGN, to be agreed before any code
- His model: "i have offhand gun, i put shieldsaw in offhand, i throw shieldsaw, while out, previous weapon comes back - i
  can use both weapons to attack while saw is out. if i want to recall shieldsaw, i press the bind for 'shieldsaw'".
  So the disc is NOT recalled by off primary fire (findings F1).
- "there should not be a throw button (maybe for rsq access), there is a 'quicksaw' button": no Throw Button choice
  (which also ends findings F2, the choice undone every map, and F4).
- "lets consider removing it as a holstered thing, and allow it to be assigned a holster from the wheel, but only the
  shoulders ... we can assign it to a shoulder mount in tacrig / wheel menu, right? what do you think about this".
- THEN, HIS SPEC IN HIS WORDS (06:59), which is all there is to work from: "the saw is a weapon we start with available in
  the wheel. it lives in the offhand. it gets there with a button press. we can optionally mount it on the offhand
  shoulder. when doing so, it takes the left shoulder slot ... it does not live anywhere by default".
- DO NOT add to it: no new name for the key (it has one: ShieldSaw), no words of our own.
- 07:00 HE STOPPED ALL SHIELDSAW WORK. The edits made before that were thrown away at 07:03 (they put ringing on the
  off hand's trigger, which is not what he wants). ShieldSaw's code is as committed.
- 07:02 THE SAW'S CONTROLS, IN HIS WORDS. This is the spec. Build exactly this and nothing else, when he says to:
  "ONE BUTTON TO PUT SAW IN OFFHAND OR SWAP FOR PREVIOUS WEAPON. MAINHAND FIRE TO PAINT TARGET, FLICK TO THROW, HARDER
  THROW TO THROW HARDER AND MORE DAMAGE. OFFHAND FIRE REV / UNLOCK TARGET."
  07:03, the rest of it: "SAW CAN BE SELECTED VIA WHEEL BUT ONLY GOES TO OFFHAND. CAN BE ASSIGNED BUT ONLY TO OFFHAND
  SHOULDER."
  07:05: "OFFHAND REVS AND UNLOCKS ... GET THIS DONE". A builder is on it since 07:06 (ShieldSaw, with the matching
  parts of Tactical Rig and the Wheel); its diff is to be reviewed before he is told it is done. Nothing compiled.
  The code today differs: the off hand's trigger revs AND rings, and letting it go with a swing throws; a throw's
  bonus comes from the rev, not from how hard the arm swings; Use at a spot on the back draws it.

## Not verified

- NOTHING HERE HAS BEEN COMPILED OR RUN. The Wheel code changes (wr_time and the settings move, Use and the grenade keys, the release and the stick, Skip Holstered Guns, the sheet's hand) need the rig
  (`tools/rig17`, `runall17.sh`: zero script errors) and a headset look before they ship. `pk3/RSQ_Wheel.pk3` is NOT rebuilt.
- The READMEs' claims are checked against code lines, not against behaviour in the headset.

## Controls map

`design/CONTROLS_MAP.md` (draft). Has: base Brutal Doom's 18 key commands (reference only), the RSQ keys, the five mods
that read raw grip key codes. MISSING: the owner's ini (which button sends which command; `vr_secondary_button_mappings`),
and the read of his BD22 VR weapons code (RSQ_BD_VR_Reloaded, 61,902 lines: every input each weapon takes). The optional
default control profile is drafted only after both.

## Owner answers 2026-11-27, 08:1x to 08:3x (Gun Cards and Score cards)

Verbatim, with what each turned into. Nothing compiled or run.

- Gun Cards KILLS: "GBOVR has a way to credit the correct gun with damage, can we look into that?" Built: the engine's
  off-hand flag on each traced shot stamps the hand (GunCards card.zs WorldHitscanPreFired / WorldRailgunPreFired), as
  Gun Bonsai VR and Gun Cards' own condition code do.
- Gun Cards Inspect question (I asked the wrong thing): "i do not understand. small card shows all the time. when we
  watch check main or offhand, we see rectangle status card. when we offhand pulse check, we see Stat Fight card. both
  watch cards and the pulse start fight card are WILDILY unreliable in when and how they showup, and it makes me LIVID.
  re ask me this question becasue i clearly answered somethign else."
  Re-asked as: how should the wrist cards show? Answer: **"Look at it, it shows"**: no box, no stillness, no hold. Back
  of the wrist turned to your eyes and you looking at it: watch card. Inside of the off wrist the same way: Start Fight
  card. Stays 2 s after. Builder launched (Accessibility gestures.zs, Gun Cards card.zs + gestcopy.zs, Miniboss
  bossfight.zs).
- Bare off hand: "show the status card.  AND i want every weapon in bd22 vr weapons to have a small card and a watch
  card and a pulse monster / start fight card and i want them to be fuckin reliable. maybe melee / fists should not have
  a small card, but otherwise..." Status card built. A reader is going through his BD22 VR Reloaded repo weapon by
  weapon: every input each takes, and what Gun Cards shows for it today and why not
  (design/BD22VR_WEAPONS_INPUTS_AND_CARDS.md when it is in). This is also the missing half of the controls map.
- Accessibility's Watch Check off: "accessability is kind of on its way out unless you convicne me to keep it. i don't
  understand why that is an option in accessability anyway, how does it help a disabled person to not see information?"
  Open. Facts for the case: the watch check and pulse check reader lives in Accessibility today (Gun Cards carries a
  copy); its nine keys are all unbound and dropped unless One Handed is on (default off); other mods read its Steady
  Hands, Rumble Strength, Text Size, Colour Blind, Seated, Photosensitive by name.
- Score lives on a new map: **"Keep lives and total"** (default New Map Keeps becomes Plus Rewards, old settings moved once).
- Score, Grapple and Whip rows: **"New rows for new moves"** (dead rows and combos out of Score and the Glossary; new
  rows for the Grapple's kick and air spike and the Whip's Wide Swing and Ground Crack).
- Score rows no mod can trigger: **"Remove, keep Chain Gang"** (Chain Gang counts thralls killed within 12 s of each
  other on its own; K.O., Shatter, Live Wire, Blast Radius, Scorpion, Ice Breaker, Saberstaff, Zip Kick, Rage Quit,
  Thrall Slow Kill, Revive, Indiana Jones come out).
- Not asked, decided by me so the above can be done, and to be told to him: the Glossary's generator read the OLD Score
  README (Score F7); its input moves to its own file (Score/tools/glossary_source.md) so the Glossary can be re-made.

Builders done since 07:50 (committed, uncompiled): thrown barrels are Melee's launch (fd7cb9122); Flashlight and Flare
keep the off-hand weapon across maps and the beam is led to the hand (0f4bfc47e). Their reports' open points:
Distance Grab's Barrel Lock-On outranks an unpainted throw; painting with a gun hand that carries a barrel fires the
gun at it; butt strike launches at 2.4 m/s (lower than the shove's 3.6); the flashlight's LIGHT still steps at 35 Hz
(now centred, half a tic lead; LIGHT_LEAD 0 restores the old), the cone turns smoothly; zero lag needs an engine beam.

Agents running at 08:4x: wrist cards builder ("look at it, it shows": Accessibility, Gun Cards, Miniboss); Score builder
(lives, new rows, dead rows, Glossary source); BD22 VR Reloaded reader (every weapon's inputs and its cards).

## Accessibility: REMOVE THE MOD (owner 2026-11-27 08:10)

Asked four questions; his answers: what happens to the mod: "Remove the mod"; the nine keys: "remove the whole mod";
Both Palms Out and the punch and shove reader: "Remove both"; the Watch Check switch: "remove accesability".
He chose plain removal over "remove it, keep the settings": the other mods lose Rumble Strength, Text Size, Colour
Blind, Steady Hands, Seated Play, Photosensitive Mode and One Handed and play at their own defaults.

- The wrist check reader ("inspect", "pulse") moves to Gun Cards (RSQGC_GCopyService): the wrist cards builder was
  redirected at 08:11 to build "look at it, it shows" there, and Miniboss asks Gun Cards.
- REMOVAL PASS, to run after the wrist cards and Score builders finish (it touches every mod): delete Accessibility/
  and its pk3 and build entries; every mod's a11y.zs copy and its calls (Ctrl / Swapped, Rumble strength, Text size,
  colour-blind palettes, Seated, Steady, Photo) go to the mod's own default; the hearers of rsqa_alt / rsqa_mod
  (Distance Grab, Saber, ShieldSaw, SlowMo's Accessibility Button) come out; askers of RSQG_Service (Tactical Rig,
  Wheel, PlayLog, Melee's two-hand events "pair") are repointed or removed; WHO_OWNS_WHAT, KEYBINDS_PLAN, the series
  README, tools/series_check and the How To Play plan lose it. Open point to ask him: Melee's two-hand moves hear
  Accessibility's two-hands events (twohand.zs kinds 0, 3, 1): do they move into Melee or go.

## BD22 VR Reloaded: whole-code bug read (owner 2026-11-27 08:12)

His words: "bd22 should ahve bugs aplenty. read the tnriee code. don't miss a fucking thing."
Nine readers started 08:15, every line, brief at design/bd22_read/BRIEF.md, each writes design/bd22_read/PART_<n>.md:
1 weapons A (10 biggest .dec); 2 weapons B (the other 23 .dec); 3 zscript/rsq; 4 zscript/rsld core; 5 rsld ld_* and
ldl_patch; 6 zscript/rsr (manual reloads); 7 rsvr, rsg, nosniper; 8 the off-hand DECORATE lumps, with the full
main-hand / off-hand twin table; 9 lumps, settings, keys, menus, assets (cross-checks by script over all of src/).
A tenth reader (started 08:05) lists every weapon's inputs and what Gun Cards shows for it:
design/BD22VR_WEAPONS_INPUTS_AND_CARDS.md. Findings go to him as question cards, worst first, as each part lands.
The repo already has BUGS_FROM_CODE_READ_2026-11-24.md (with his answers); readers mark what is already there.

## When this goes to main (owner 2026-11-27 08:15)

His words: "we will move to main once all readmes are done being considered and we have solidified our How to Play".
So `readme-from-code` stays a branch until (1) every mod's README has been read from code and its findings answered,
and (2) the How To Play is settled. No merge, no PR to main before both.

## Gun Cards on BD22 VR weapons (owner 2026-11-27 08:3x), TO BUILD after the wrist cards builder leaves GunCards/

From design/BD22VR_WEAPONS_INPUTS_AND_CARDS.md. His answers:
- Chainsaw (Chain_saw) and sword (DSweap): "Watch card with real lines": no small card; the watch card gets the name
  plus KILLS and GRENADES lines like a gun's card.
- Card counts: "Fix all three": Purist copies count the pile the gun spends; the Brutal Revolver's reserve shows rounds
  (Clip1 at 3 per round); the rifle's launcher round gets a line on the rifle's watch card (Rifle, RSQ_Off_Rifle,
  Machinegun).
Still unknown: whether DualPistols / DualRifles / DualPlasmaRifles can reach the off hand (no small card there), and
whether base Brutal Doom's Melee_Attacks has an AmmoType1 (then fists get a small card today).

## MONSTERS: DO NOT READ (owner 2026-11-27 08:24 to 08:27)

His words, in order: "do not read bdxm"; "RSQ ONLY."; "DO NOT READ ANY RSQ MONSTER FILE AND GET THE FUICK BACK TO WORK".
So: no file of RSQ Monsters (folder Monsters) and none of MonsterRecolour / the BDXM art is read, by me or any agent.
Four Monsters readers I had started at 08:27 were stopped by me at 08:28 before they wrote anything. Their READMEs stay
as they are. The remaining readers are Miniboss, VisualRewards, and Graveyard + Glow In The Dark + PlayLog.
Also 08:24: "DON'T TOUCH THAT RIG": the rig from RS_ModelSwapper is not to be used; nothing was changed in that repo.
08:24: "Finish readers and quiestions".

Builds in since 08:20 (committed, pushed): wrist cards "look at it, it shows" (911aa161e; reader lives in Gun Cards,
Miniboss asks it; angles: back of wrist starts under 80 degrees off facing the eyes, inside under 60, gaze under 50;
a left-hand sign error in FaceDot / InnerDot fixed; the tick in the hand and the gesture name are lost with
Accessibility); Score (cc3c2f223: default New Map Keeps = Plus Rewards with cfgver 4; rows Kick +0.3, Air Spike +0.5,
Wide Swing (multi-kill) +0.3 each up to +0.9, Ground Crack +0.3; 27 rows and 71 combos out; Chain Gang by itself;
Glossary regenerated from Score/tools/glossary_source.md, 382 entries). Two compile errors found on the one rig run
before he stopped it were fixed (402571918: Melee field name, Whip velocity read).
BD22 bug read: parts 6 (reloads, 18 findings) and 8 (off-hand twins, 14 findings) are in design/bd22_read/.

## How To Play: build started (owner 2026-11-27 08:4x)

His answers: Show Me: "I HAVE NEVER SEEN OR HEARD OF THIS FUCKING GHOST HAND IS THIS WHY ALL THE PEOPLE WHO HAVE
DOWNLOADING THIS ARE ASKING ME WHAT THE FUCK TO DO" (so: no Show Me in the first build; the builder reports every
condition that keeps the Rig's ghost hand, TacticalRig ghost.zs, from ever showing). First-run prompt: "THINK OF
SOMETHING" (builder decides; F1 is not a key in a headset). Start: "Start now (Recommended)".
Also 08:41: "STAY ON THE FUCKING READMES!!!! WHERE THE FUCK ARE WE ON THE RSQ HOW TO PLAY MENU": the BD22 reload
table reader was stopped; BD22 reload talk waits. Told him again: nothing in BD22 has been changed (edfaf63, clean).
Readers restarted on Opus 5.5 at 08:3x after the Fable usage limit stopped them: Miniboss, VisualRewards,
Graveyard + Glow In The Dark + PlayLog.
08:43, owner: "WHY ARE ALL READMES NOT IN" / "WHAT THE FUCK ARE YOU BUILDING WITHOUT ALL READMES". The How To Play builder
was stopped at once (it had only started reading; it wrote nothing). It restarts only when every README is in.

## The Rig's ghost hand (owner 2026-11-27 08:48)

His words: "no it works, its confusing my players!!!!!! we need to use it for this how to play thing. please get these
readmes in and move on". So: the ghost hand WORKS. It confuses players because it appears unasked (the holster tip,
TacticalRig ghost.zs). It is to be USED by How To Play (Show Me). Earlier note that he had never seen it is withdrawn.
To settle when How To Play is built: the unasked holster tip stays, goes, or only plays from How To Play.

## Held items stay on the weapon (sprite) layer (owner 2026-11-27 08:51)

Asked the risk of moving everything to world actors: 35 Hz stepping and lag behind the hand, guns sinking into walls,
sector light darkening them, BD22's frame-keyed animation to mirror each tic, more cost on Quest. His words: "fkit,
sprite layer it is". So held weapons and items stay on the weapon layer on QuestZDoom. World items drawn every frame
from the controller are for the REMA port.

**08:5x: EVERY README IS IN** (all series mods except RSQ Monsters and MonsterRecolour, which the owner forbade; Accessibility is read but being removed). Next: the How To Play build.

Owner 09:0x on Miniboss and ammo: "the Start Fight card was created because Use on Watch Check was totally unresponsive.
disable use on watch check so we ONLY use on Start Fight (if call it in is on)"; "thralls drop bits, not guns. and i
want a new kind of bit, a different shade of green. current green bits give ammo for weapons in main and offhand.
these new green bits give ammo for other guns in your inventory ... im running out of ammo during bossfights";
picked: the new green bit, and an ammo burst when the Boss steps up; "kiosk should not let a purchase of more than one
weapon. one weapon purchase per kiosk." Builder running (Miniboss + VisualRewards).

## Series main page (owner 2026-11-27 09:20)

His words: "the series' main page will need redone as well, it's the most important one. i know the web graphic
doesn't apply anymore, i don't need a replacement to look as good but sure maybe. the hero image and the grid link
arrangement i want to keep. but the game screenshots i sent you and the existing rig renders from all projects, you are
free to do whatever you want with them to make a nice presentation. the keys layout matters too and it could be spiced
up some". Builder started: hero and grid kept (Accessibility's cell goes), each section from the new READMEs, his 13
screenshots + rig renders, keys rebuilt from code with a graphic, web graphic only if it can be made true.
09:21, owner (showing the Glossary-style How To Play mockup): "depending on how much freedom we are allowed with designing
the github it could look kind of like this, but maybe id want to see a mockup and think about it for awhile so we can
keep what you're doing for now". Main page builder keeps going as briefed. Mockup C added to the design canvas
(artboard GitHub.dc.html, version 1795789344-896f): each mod as a Glossary-style panel PICTURE generated from its
README (GitHub allows no styles or scripts), real text and links under each, a "Your hands" keys picture with the
searchable table under it. Waiting on his decision.
