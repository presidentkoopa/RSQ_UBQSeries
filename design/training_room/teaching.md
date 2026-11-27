# Training Room: the teaching layer

Design only (2026-11-27). Nothing here is built or has run on the rig. Repo read: /home/claude/wt_fix2 (read only).
`[code]` / `[README]` = grounded, with a path. **IDEA** = proposal, not in the repo.

---

## 0. The core idea

**Teach one verb at a time, in the world, with the feedback the mods already give.** No new text system and no
tutorial voice. The room *points*: the station floor flares (GITD). It *names*, in three words or fewer over the target
(VisualRewards word). It *shows* (Rig ghost hand / mirror, SlowMo). Then it *gets out of the way*. The mod's own sound,
buzz and word (KICK!, the ring, the pin sound) is what tells the player he did it. The room only adds one toast and a
green floor.
Every lesson is a pointer to a README "How to play" row. The row stays the truth, and the lesson is checked against it
by the generator that already builds How To Play.

---

## 1. The interaction grammar (verified) and where it breaks

What a new player can be told in four lines, and how true each line is:

| Rule | Holds for | Breaks (teach these explicitly) |
|---|---|---|
| **BODY = INVENTORY.** Guns hang on you and you reach for them | Rig: 6 holsters, grenade at the buckle, saber/whip/flare spots, shield on the off shoulder `[README TacticalRig:30-60, ShieldSaw "Squeeze the off hand's grip at the shoulder"]`; FnF flare at the chest pocket `[README FlashFlare]` | The Wheel is a second, floating inventory (time freezes) `[README Wheel:16]`; saber and whip also come from weapon slot 1 `[README QuestSaber, Whip]` |
| **GRIP TAKES.** | **Off hand only.** Off grip draws/holsters, takes the buckle grenade, the flare, the shield from the shoulder `[README TacticalRig:44,30; FlashFlare]` | **The main (right) grip is the modifier** under RSQoopaControls: QuestZDoom sends no key for it, so **the main hand takes with A (Use)** at a holster `[README TacticalRig:6,10; ini "THE MODIFIER"]`. Saber/whip from the main-hand hip spot list "main grip: Secondary Button Mappings Off" `[README TacticalRig saber/whip rows]`. **OPEN:** does A work there under RSQoopaControls? Check on the rig. The Wheel reads no grip at all: cards are taken with the trigger `[README Wheel:205]` |
| **TRIGGER USES.** Each trigger is its own hand `[ini Shift / RTrigger]` | Guns, ShieldSaw rev and lock-on, saber lock-on, grenade hold `[README ShieldSaw:17, QuestSaber, Grenade]` | Grenade ring pull is the **other** hand's trigger, and a gun in that hand fires `[README Grenade:180]`. Wheel: trigger = take a card, not fire `[README Wheel]`. Grapple's button is on the **right** stick but the claw leaves the **left** hand (Hook Hand: Off Hand default) `[README Grapple:12; ini Enter]` |
| **SWING THROWS.** ("flick" is the wrong word, see right) | ShieldSaw: off arm forward at 2.2 m/s or more, **no button** `[README ShieldSaw:21]`. Saber: let go of the trigger mid-swing `[README QuestSaber]`. Grenade: let go of fire mid-swing at 2.2 m/s or more `[README Grenade]` | Three release rules: none / let go of the trigger / let go of fire. A slow let-go **cooks** the grenade in your hand `[README Grenade]`. "Flick" is taken twice already: the **reload flick** is the barrel down 45° (with shield/saber in the off hand) `[README ShieldSaw, QuestSaber]`, and the **Distance Grab flick** is the wrist up plus a palm roll `[README DistanceGrab]`. Rig gun throw is off by default |
| **WRIST TO EYES = INFO.** | Gun Cards watch check: back of either wrist → ammo / health / keys `[README GunCards:19]` | Two more poses: **inside** of the off wrist = Miniboss pulse check (START FIGHT, then **A** calls it in) `[README Miniboss:18-19]`. Forearm across the chest = Wheel wrist card (off by default). An off hand that steadies the gun does not count `[README GunCards]` |
| **THE MODIFIER: right grip + button = second layer** | Wheel, reload, quick grenade, prev/next weapon, menu, Crisis Dive, offhand alt fire `[ini]` | A **double press** always runs the single press first (571 ms window) `[ini "A DOUBLE PRESS"]`: Y 2x is next item, then the map; stick click 2x is the hook (or SlowMo), then the taunt |

**Teach it as the first thing a player hears:** *"Your body is your inventory. Your wrist is your HUD. Right grip is
SHIFT."* Three lines, once, in minute 1. Then teach each break at the station where it bites, never as a list.

---

## 2. Channels: which one says what

| Channel (existing API) | Use it for | Never for |
|---|---|---|
| **World word over a target**: `RSQVR_Service` "word.hold" / "word.clear", colour + size, stays over the actor until cleared `[code VisualRewards/pk3/zscript/rsqvr/service.zs:37-40]` | **The WHAT**: 1 to 3 words over the dummy, ledge or pedestal: "HOOK THE LEDGE". Changing colour in place = progress (re-ask with the same text) | Buttons, sentences, anything not over a thing |
| **World sign**: "worldword" `"TEXT\|at:x,y,z\|id:<name>\|label"`; an id replaces its own sign `[service.zs:44-58]` | The station's name over the station ("GRAPPLE"), and the payoff word ("TEETH!") | Instructions. It has a life, it fades |
| **HUD chip (the HOW)**: IDEA: `RSQVR_Service "toast.hold"/"toast.clear"`. Today a toast lasts about 1.5 s, at most 3 at once `[service.zs:84; README VisualRewards:240]`: too short to read while trying | **One** line: the button, or the gesture in 2 to 6 words: "HOLD R GRIP + CLICK R STICK" | Two lines. Combat |
| **Toast** (as is) `"up\|..."` | The CONFIRM: "GRAPPLE: GOT IT" | Instruction |
| **GITD floor flare / tint / wave**: `RSQGD_Service` "event.flare" (sector, colour), "event.tint", "event.wave" `[code GlowInTheDark/zscript/rsqgd/service.zs:18-23]` | Flare the **live station's floor** (WHERE). A green flare on success. A gold wave from the player when a lesson block is done (the level-up language GITD already speaks) `[README GITD:155]`. The room's switches are amber and exits green already `[README GITD]`: use them as they are | Explaining anything. It is the "look here" channel |
| **SlowMo by name**: `RSQSM_Service` "start" (name, ms, speed) `[README SlowMo:252-262]`; "arrow.add" = a HUD edge arrow at an actor `[README SlowMo:269]` | **Timing** lessons: perfect block, saber deflect, skeet. Projectiles slow down, you do not `[README SlowMo]`. The arrow points to the next station when it is behind you | Watching your own thrown disc/saber/grenade: the series' own hand-held things (RSQ/UBQS/SSQ classes) are **never slowed** `[README SlowMo:295]` |
| **Show Me ghost hand**: `RSQTR_RigService` GetStringUI "ghost.demo" `<move>` → a net event `[code TacticalRig/zscript/rsqtr/hooks.zs:255-274]`. Moves: holster, draw, offdraw, nade, cig, mouth, recenter, saber, offsaber, whip, flare, keyring, watch, pulse, shield `[ghost.zs:50]` | **WHERE ON THE BODY** (any hand → place path). `mouth` (hand to lips) is exactly the teeth-pin path | Gestures: no swing, cross or flick demo exists. IDEA: add `wristcross`, `swing`, `airspike` paths to DEMO_NAMES |
| **Show On My Body mirror**: "mirror.show" `<place>`, the mirror plus lit rings for 10 s `[ghost.zs:59; hooks.zs:261]` | "Which holster is that?": the holster lesson, the shield shoulder mount | Anything off the body |
| **The mod's own feedback**: aim dot (cyan/gold), lock rings, pin sound, KICK!, holster ring colour, buzz vocabulary (one pulse = done, double pulse = refused) `[code rig.zs:957-962]` | **The real CONFIRM.** The room adds nothing louder | — |
| **Score row name**: `glossary_data.zs` Add(family, name, text, bonus, needs) `[code Score/zscript/rsscore/glossary_data.zs]` | The **graduation line**: "TEETH SCORES +9" (the name and bonus come from the Glossary). It shows the player why he would do it in a real map | — |

Text constraint for all of it: **upper case, ASCII 32 to 96** (RSQ Score's fonts) `[code gen_howtoplay.py:22]`. World
words are upper-cased anyway `[worldwords.zs:119]`.

---

## 3. The lesson pattern: CUE → SHOW → TRY → CONFIRM

1. **CUE** (≤1 s, before anything spawns): the station floor flares in GITD, the station sign stands up, and the WHAT
   word goes over the target.
2. **SHOW** (≤2 s, automatic, once): body-place moves get the ghost hand. Holster moves get the mirror. Aimed moves need
   no demo, because the mod's own aim aid is the demo (grapple dot, lock ring, laser dot). Gesture moves get a 2-second
   SlowMo window on the incoming threat.
3. **TRY**: the HUD chip shows the HOW (one line). Nothing else changes until the player acts. No timer.
4. **CONFIRM**, read from the mod's own service, never guessed:
   the chip clears → the station floor flares green → toast "X: GOT IT" → the Score row line (if any) → the next CUE.

**Retry ladder** (per lesson, IDEA): miss 1: nothing (the mod's own refusal buzz says it). Miss 2: replay SHOW.
Miss 3: swap the chip for the **one** fix line written for this lesson ("LEFT HAND AIMS"). Miss 5: offer "SKIP? PRESS
A" and mark the lesson *seen, not learned*, so it comes back as a hint later (§6).

**Confirm sources that already exist:**
- Grapple: `RSQGR_Service` "g2.*" events by name `[README Grapple:96]`
- ShieldSaw: "locked" (per monster), "thrown.leg", "perfect" `[code ShieldSaw/zscript/ssq/score.zs:33-66]`
- Grenade: "teeth" / "skeet" / "cooked" on the thrown grenade `[code Grenade/zscript/rsqgn/upg.zs:169-190]`
- Rig: "rig.holster" `<class>` → region, "rig.regionname", "rig.drawtic" `[code hooks.zs:15-28]`
- SlowMo: "active", "adrenaline" `[README SlowMo]`

---

## 4. The message budget (hard rules)

- **One instruction on screen.** One WHAT word (≤3 words) plus one HOW chip (≤6 words, the button words count). Never
  two chips.
- **No numbers in lesson text.** No "2.2 m/s", no "12 tics". Say "SWING HARDER". Numbers live in the README, and text
  that quotes them drifts.
- **One verb per lesson step.** "Ring all three" and "throw" are two steps.
- **Never in combat.** No new chip while: a monster that is awake has the player as its target, the player took damage
  in the last 3 s, SlowMo is running (unless that lesson is the SlowMo one), he is DOWN, or the Wheel is open. In normal
  maps, add: Miniboss's director intensity ≥ 0.15 (it already has that idea of "little is happening") `[README
  Miniboss:17]`. The training room's combat drills show the chip **before** the platform raises, then hide it.
- **The chip stays until done** (no reading race). The toast is the only timed text.
- **Text drawn as a paragraph** exists only in How To Play (the reference). The room links there for "MORE" and never
  copies it.

---

## 5. Showing buttons that don't exist in the world

The player cannot see his controllers. QuestZDoom draws the weapon in the hand, not the controller.
- **Fixed words, generated**: the button words come from `make_controls_table.py` WORD/LEFT/RIGHT plus the ini, as How
  To Play's CONTROLS tab already does `[code gen_howtoplay.py:16-18]`. The form is always: `[HOLD R GRIP +] <VERB>
  <HAND> <BUTTON> [2X]`. Examples: "CLICK R STICK", "HOLD R GRIP + CLICK R STICK", "Y 2X". So the modifier is
  **"HOLD R GRIP +"** at the front and a double press is **"2X"** at the end. Nothing else.
- **Handedness**: lessons are written MAIN/OFF and drawn RIGHT/LEFT (or swapped) at runtime, the same as How To Play's
  left-handed panel `[README Controls:20]`.
- **A buzz on the hand that owns the button** (IDEA): when the chip appears, one light pulse in that hand. It uses the
  Rig's buzz vocabulary (`RSQTR_Buzzer.Start`), and must never be the double pulse, which means *refused* `[rig.zs:957-962]`.
- **Chip icon** (IDEA): a small controller sprite with the button lit, rendered from the same ini by
  `design/readme_art/make_controls_quest2.py`. It can't drift because it is drawn from the binds.
- **Double press**: teach it only where the first press is harmless (Y = next item, then the map). Taunt (stick click
  2x) is a bonus card, not a lesson.

---

## 6. Order: minute 1, 5, 30

| When | Station | Why now |
|---|---|---|
| **0:00** (spawn pad) | "STAND TALL": the Rig measures height after 2 s of standing still `[README TacticalRig:50]`, then "HANDS ON CHEST" to recenter (ghost `recenter`) `[:45]` | Everything on the body is placed wrong until this is done |
| **0:30** | The three-line grammar (§1), one line per beat. Then: shoot (each trigger its own hand), **A** at the amber switch (GITD) | Walk, turn, shoot, use |
| **1:00** | **Holster + draw** (off grip / main A; ghosts `holster`, `draw`, `offdraw`). **Watch check** `[GunCards:19]`. **Reload** (HOLD R GRIP + STICK DOWN) | Body = inventory, wrist = HUD, Shift. Done |
| **5:00** | Wheel take, buckle grenade + Quick Grenade (HOLD R GRIP + STICK UP), kick (STICK DOWN), grapple to a wall, then a ledge | Getting around and the first fight |
| **15:00** | ShieldSaw draw/block/throw, saber (cut, block), SlowMo (wrist cross, CLICK L STICK; needs 25 adrenaline, so the room grants it with "adrenaline.add") `[README SlowMo:14,262]` | The signature weapons |
| **30:00+**, opt-in challenge stations | Holster assignment, teeth/cook/skeet, perfect block in SlowMo, saber lock-throw + Training Remote (`ubqs_remote_toggle` already exists as a drill) `[README QuestSaber:53; MENUDEF:154]`, grapple kick chain + air spike, Force, Distance Grab, whip, pulse check → Boss | Each one ends on a Score row ("KICK", "TEETH", "QUICK DRAW", "BUZZSAW") |

The first five minutes are **mandatory and linear**. Everything after is **stations the player picks** (the switches on
the room's hub light up amber when ready).

---

## 7. The same lessons as moment-of-need hints in normal maps

Already in the series (the model to copy): the Rig's ghost holster tip (2 s holding a gun until the first holster, then
gone for good: `rsqtr_tip_holster`) `[README TacticalRig:54; ghost.zs:1-8]`. "Holsters in the wrong place?" once ever
`[:55]`. A fumbled holster ring lights up `[:56]`. The Controls new-game line `[README Controls:24]`.

**IDEA, one rule set:** each lesson has a `learned` bit (archived cvar, like `rsqtr_tip_holster`), set by doing the move
**anywhere**, not only in the room. A hint fires only if: not learned + its **trigger** + calm (§4) + fewer than 3 shows
ever + at most 1 hint per 3 minutes. Triggers, all readable today:
- RELOAD on the card for 5 s → "HOLD R GRIP + STICK DOWN" `[GunCards "Empty the magazine"]`
- Grenade in hand 4 s, pin in → "BITE THE PIN" + ghost `mouth`
- Shield drawn 3 times, never thrown → "SWING LEFT ARM TO THROW"
- Adrenaline full, SlowMo never used, **after** the fight ends → "NEXT TIME: CROSS WRISTS" (an after-action hint,
  never mid-fight)
- Boss meter full for the first time → "CHECK YOUR PULSE" + ghost `pulse`

**Where hints show** (IDEA): on the **wrist**. A tip waiting = the Gun Cards small card blinks once. The player pulls
the tip with a watch check, and the line shows in the watch card (a new Gun Cards request, e.g. "tip"). Wrist = HUD, and
nothing is pushed into his face.

---

## 8. Single source: the lesson text can't drift from the README

The generator already reads every README's How to play table, and refuses keys that match no row (`DEMOS`,
`PLACE_FIX`, `--check`) `[code gen_howtoplay.py:80-97, 4-6]`. **IDEA:** one more file, `design/training/lessons.txt`,
read by the same `gen_howtoplay.py`:

```
lesson   grapple.ledge
mod      Grapple
row      Press Fire Hook (you bind it          # start of the README "Do this": --check fails if no row matches
key      +rsqgr_hook                           # button words drawn from the ini; --check fails if unbound
what     HOOK THE LEDGE                        # <=3 words, ASCII 32-96, length-checked
how      AIM OFF HAND · {key}                  # <=6 words with the key; MAIN/OFF resolved at runtime
show     dot                                   # dot | ghost:<demo> | mirror:<place> | slowmo:<ms>,<pct>
fix      LEFT HAND AIMS                        # the miss-3 line
done     RSQGR_Service g2.lift                 # a confirm the mod answers (event name to be checked)
score    Kick                                  # Glossary name; --check fails if missing
hint     -                                     # trigger for normal maps
```

- When a README row changes, its lesson fails `--check` until someone looks at it. When the owner rebinds a button, the
  chip follows.
- Score's row line is baked from `glossary_data.zs`, as the SCORE tab already is.
- How To Play gains a **TRY IT** row beside **SHOW ME** when the training map is loaded (IDEA).
- The generated data lives in RSQ Controls, which already owns How To Play and asks Rig and VisualRewards by name
  `[README Controls "Works with"]`.

---

## 9. Four lessons, exactly as the player sees them

Legend: **[W]** world word over the target · **[S]** station sign · **[C]** HUD chip · **[T]** toast · **[G]** GITD ·
**[R]** Rig ghost/mirror · **[M]** SlowMo. Right-handed shown.

### 9.1 Grapple (minute 5): ledge, then monster
| Beat | Shown |
|---|---|
| CUE | [G] the floor under a 3 m ledge flares cyan · [S] `GRAPPLE` · [W] over the ledge: `HOOK THE LEDGE` |
| SHOW | No ghost. The cyan aim dot **is** the demo `[README Grapple:14]` |
| TRY | [C] `AIM LEFT HAND · CLICK R STICK` |
| miss 3 | [C] `LEFT HAND AIMS. NOT RIGHT.` |
| CONFIRM | The player is lifted onto the ledge (Grapple's own lift `[README Grapple]`) · [G] the ledge floor flares green · [T] `GRAPPLE: GOT IT` |
| step 2 | A platform raises one imp, held still · [W] over it, gold: `HOOK IT` · [C] `SAME BUTTON` → he flies in, Grapple's own `KICK!` `[README Grapple "Works with" VisualRewards]` · [T] `KICK SCORES +18` (Glossary "Kick") |

### 9.2 ShieldSaw lock-on + throw (minute 15)
| Beat | Shown |
|---|---|
| CUE | [S] `SHIELDSAW` · [W] over the pedestal: `TAKE THE SHIELD` · [C] `PRESS X` → the shield comes up (its own sound and buzz) `[README ShieldSaw first row]` |
| CUE 2 | 3 imps rise on platforms, held still · [W] over the middle one: `RING ALL 3` |
| TRY | [C] `HOLD L TRIGGER · SWEEP` · each ring lands (the mod's tick in the left hand) → that imp's word becomes `1`, `2`, `3` in gold, in **ring order**, which is the order the disc visits `[README ShieldSaw:17,21]` (confirm: "locked") |
| CUE 3 | [W] middle: `THROW` · [C] `SWING LEFT ARM FORWARD` (no button: tell him so with the absence) |
| miss 3 | [C] `SWING HARDER` |
| CONFIRM | The disc visits 1-2-3 · [W] over the player's left hand: `CATCH` · [C] `LEFT HAND OUT` → caught with a strong buzz `[README ShieldSaw:27]` · [G] green · [T] `SHIELDSAW: GOT IT` |
| note | With Gun Bonsai VR loaded, a throw rings **one** monster until Lockstep `[README ShieldSaw:200]`: the station must read that and raise **one** imp (`RING IT`) |

### 9.3 Holster assignment with the Wheel (minute 30, challenge)
| Beat | Shown |
|---|---|
| CUE | A shotgun is put in the right hand · [S] `ASSIGN A HOLSTER` · [C] `HOLD R GRIP + CLICK R STICK` (time stops; all text goes up **before** this) `[README Wheel:12,16]` |
| TRY 1 | [W] over the shotgun's card: `POINT HERE` (the beam is drawn by the Wheel) |
| TRY 2 | [C] `HOLD R GRIP + R TRIGGER` → the holster web opens, Web View: Mirror shows you `[README Wheel:180]` |
| TRY 3 | [C] `R TRIGGER ON A RING` |
| CONFIRM | "rig.holster" for the shotgun ≥ 0 → [T] `SHOTGUN: LEFT HIP` (name from "rig.regionname") `[hooks.zs:26-28]` · [R] mirror.show on that place, 10 s |
| TRY 4 | [W] over a raised imp: `DRAW IT` · [R] ghost `draw` · [C] `R HAND THERE · PRESS A` (or `L HAND THERE · SQUEEZE GRIP`) |
| CONFIRM | The draw pulse plus "rig.drawtic" · [T] `QUICK DRAW SCORES +21` (Glossary "Quick Draw": a kill within 1.2 s of the draw) |

### 9.4 Grenade pin with your teeth (minute 30, challenge)
| Beat | Shown |
|---|---|
| CUE | [S] `GRENADE: TEETH` · [G] a row of barrels on a raised platform, floor amber |
| TRY 1 | [W] over the buckle (anchored at "region.x/y/z" of the belt `[hooks.zs:30]`): `TAKE ONE` · [R] ghost `nade` · [C] `HAND TO BUCKLE · PRESS A` `[README TacticalRig:30]` |
| TRY 2 | [W] `BITE THE PIN` · [R] ghost `mouth` · [C] `HOLD R TRIGGER AT MOUTH` → the pin sound plus a buzz `[README Grenade:22]` |
| TRY 3 | [C] `KEEP HOLDING · SWING · LET GO` |
| miss: cooked | The mod's own red flashing tick · [C] at once: `COOKING! THROW NOW` (the one exception to "no new chip"; this is safety) → then fix line `LET GO MID-SWING` |
| CONFIRM | The thrown grenade answers "teeth" = 1 `[upg.zs:175-188]` · barrel chain (SlowMo's own Chain Reaction slow) · [S] at the blast: `TEETH!` · [T] `TEETH SCORES +9` (Glossary "Teeth") |
| why teeth first | One hand. The ring pull uses the other hand's trigger, and a gun in that hand fires `[README Grenade:180]` |

---

## 10. Open, and the biggest risk

- **OPEN:** under RSQoopaControls, does the main hand draw the saber/whip at its hip spot with **A**? The README lists
  only the main grip (which is the modifier). If it doesn't, the grammar has a hole at minute 15.
- **OPEN:** while the Wheel is open "time stops" `[README Wheel:16]`. Do world words, the chip and the confirm logic keep
  ticking? Test on the rig before the holster lesson is written for real.
- **OPEN:** progression gates in a training room. Gun Bonsai VR limits grenade types, ShieldSaw locks and maybe Teeth
  `[README Grenade:163; ShieldSaw:200]`. Should the room grant temporarily, or teach the base kit only?
- **New API needed (small):** VisualRewards "toast.hold/clear"; Gun Cards "tip"; optionally new Rig ghost paths for
  gestures. Everything else is asked by name today.
- **BIGGEST RISK:** the grammar is not consistent. The main hand takes with A and the off hand with the grip; there are
  three throw-release rules; the grapple is the right button but the left hand. A training room can only teach rules
  that hold. If those breaks stay, every lesson spends its word budget on exceptions. Fixing the 2 or 3 worst breaks
  costs less than teaching around them. Candidates: grenade release vs cook, and saber/whip draw with A.
