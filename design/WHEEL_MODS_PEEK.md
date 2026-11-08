# Wheel-supported mods: a quick peek for the Big Fourth (2026-11-08)

A first look at each gameplay mod that RSQ Wheel has a compat file for. The question for each one: is it worth
studying further for the Big Fourth (design/BIG_FOURTH_ARCADE.md: contextual challenges, in-world arcade words and
numbers, a conductor, bits as jackpot, time attack) or for the Big Three (design/MONSTER_SETS.md)?

## How to read this
- Every fact about a mod comes from a page I opened (URL given) or from this repo (file:line).
  **[inference]** marks my own reading. Quotes are under 15 words, at most one per source.
- **Pages I could not open:** ModDB (the Doom Infinite page was held for a permission request no one answered, so I
  did not try ModDB again) and the first page of the Lithium forum thread (robots block). The other ZDoom forum
  threads opened, but some opened partway through, so their first posts were missing.
- Nothing here was run in QuestZDoom 17.3.

## Read this first: most Wheel compat reads return nothing on stock QZD 17.3
`Wheel/zscript/wheel/wr_q_shim.zs:873-886`: `wr_Field` is described as "REMA's field reflection, absent on stock QZD".
Every `GetField*` call there returns false. Compat code built on it shows nothing on Quest. Compat code that walks
the player's inventory or checks class names still works. Field-read counts per file (grep of `wr_Field.`):
Lithium 35, Doom Infinite 36, Insurrection 14, Doomablo 12, Pandemonia 12, BorderDoom 7, ModelSwapper 6,
Anarchy 4, Guncaster 2, MetaDoom 2. Combined Arms, Final Doomer, DRLA and LegenDoom have none.
So the Wheel "supporting" a mod does not mean it reads that mod on Quest today. **[inference]** For the Big Fourth,
any read of these mods should use inventory or class checks, or events. Field reflection is not available.

---

## 1. Lithium
- **What it is:** an RPG gameplay mod by Alison Gray Watson (Marrub). Its itch page calls it an
  "FPS-RPG hybrid building on traditional Doom gameplay with leveling and upgrades" (https://marrub.itch.io/lithium).
  The latest GitHub release is 1.7.0 (https://github.com/marrub--/Lithium/releases), and the forum thread title
  reads "Lithium 1.7.0 (Oct. 28, 2025)" (https://forum.zdoom.org/viewtopic.php?p=1228973). Engine: the author wrote
  that Beta 2 needed GZDoom 4.9's Canvas API (same forum page). The repo records that canvas textures draw black in
  VR on QZD 17.3 (`VisualRewards/ideas/A_damage_numbers_arcade.md:54`). **[inference]** Whether Lithium 1.7.0 runs on
  QZD 17.3 at all is unknown and doubtful.
- **Arcade-like, from the release notes (GitHub releases page):**
  - "Monsters will scale to your level" (1.5.3); monsters can level up (1.6); the cap is level 150.
  - **Phantoms** can spawn partway through a level, have their own escape animation, and give rewards.
  - Boss dialogues (1.6.3).
  - Score is the currency: small and large score items replace bonuses (1.6).
  - Damage numbers ("DamNums", 1.6.1); place and advice markers (1.6.3).
  - Weather and time of day (1.7.0).
  - The forum overview shows enemy levels on aim ("lv.") and calls money "Score"
    (https://forum.zdoom.org/viewtopic.php?p=969134).
- **What players see in the world:** enemy level on aim, damage numbers, and a Phantom showing up partway through a
  level and escaping.
- **What our Wheel reads:** the seven characters (`m_pclass`, `wr_compat_lithium.zs:154-164`); magazines, mana, heat,
  charge and status effects (`:310-915`, almost all through `wr_Field`, so nothing on Quest); and a guarded ACS door
  into the RPG data (attributes, upgrades), which is off by default (`:989-993`, `wr_lith_acs` 0). The door is also
  pinned to exactly 1.7.0 (`:960`).
- **Verdict: WORTH A DEEPER LOOK, for ideas only (not for loading alongside BD22).** The Phantom is the closest thing
  in this whole list to the owner's "a marked monster drops in partway through a map" challenge. Score as currency and
  monster levels touch Score pruning and the conductor. Its source is public on GitHub. The Wheel header calls it CC0
  (`wr_compat_lithium.zs:3`).

## 2. LegenDoom
- **What it is:** by Yholl; LegenDoom 3.0 and LegenDoom Lite 4.2 (https://forum.zdoom.org/viewtopic.php?p=888277).
  It brings Fallout 4's legendary system to Doom. The page names no engine.
- **Arcade-like (same page):** random enemies spawn as Legendary with more health. At half health a Legendary fully
  heals and turns into a stronger form. Killing one drops a Legendary weapon with one of about 180 effects. Rarity
  colours: green, blue, purple, orange. A weapon glows in its colour on the ground, and picking it up shows its name,
  effect and rarity on screen.
- **What players see in the world:** the transformation, the coloured glow on dropped weapons, and the pickup card.
- **What our Wheel reads:** the weapon's rarity, from an owned marker item named `<Weapon>Legendary<Rarity>`
  (`wr_compat_legendoom.zs:8-23`, `:104`). It also reads LegenDoom's own glow colours (`:36-43`) and the effect names
  (`:186-233`). These are inventory reads, so they work on stock QZD. Outside the Wheel, VisualRewards already puts a
  gem on a Legendary once it has turned (`VisualRewards/README.md:50-53, 205`).
- **Verdict: WORTH A DEEPER LOOK.** It is in the owner's load (BIG_FOURTH_ARCADE.md:45), it is one of the "rare
  targets" (:49), and MONSTER_SETS.md:20 already warns that it must not double-tier a monster alongside Champions.
  The conductor has to know about it. The half-health transformation is a ready-made in-world event that a challenge
  could hook into **[inference]**.

## 3. DOOM Infinite
- **What it is:** by difficultoldstuff. The version on the forum is DEMO 0.978.5 and needs GZDoom 4.8.2 or newer plus
  Doom2.wad (https://forum.zdoom.org/viewtopic.php?p=1247681). The Doom Wiki lists 0.978.6, a 2023 Cacoward, and says
  it is "incompatible with most other mods" (https://doomwiki.org/wiki/Doom_Infinite).
- **Arcade-like:**
  - **Forum post:** an endless Classic Mode over 37 reworked classic maps; a "big hub area with ever-changing, twisted
    corridors"; 135 stackable perks; an "advanced game director" that swaps and spawns monsters, weapons and items;
    achievements, run challenges, and monster traits.
  - **Doom Wiki:** you earn points from kills until you have enough to open the exit; curses build up; maps can be
    "mutated".
- **What players see in the world:** extra spawns and map mutations. The pages say nothing about in-world text.
- **What our Wheel reads:** procedural weapon stats and quirks, even on unowned floor weapons (`wr_compat_doominfinite.zs:8-21`).
  It also reads the run tally (kills this run, kills this map, shots; `:813`), Arena wave progress (`:831`), maps
  completed and loops (`:880`), and perks (`:917`). Every one of these is a `wr_Field` read, so nothing shows on Quest.
- **Verdict: WORTH A DEEPER LOOK, for design only.** The director that spawns monsters is the same shape as our
  conductor. "Kills open the exit", run challenges and Arena waves are Doom-flavoured arcade structure already worked
  out. It is a total conversion, so nobody will load it with BD22.

## 4. DOOMablo
- **What it is:** by sidav. The README says it needs GZDoom 4.10.0 or newer and has six rarities and
  "more than 100 applicable affixes", plus player XP levels (https://github.com/sidav/doomablo). The forum thread
  header reads v0.10a (https://forum.zdoom.org/viewtopic.php?p=1256172).
- **Arcade-like:** v0.7a added "randomized monsters with their own vile affixes"
  (https://forum.zdoom.org/viewtopic.php?p=1255868). The affix list is hidden in a spoiler I could not see.
  Playtesters describe push-pull, blinking, and a "legendary" monster that strips armour (p=1256172).
- **What players see in the world:** per our compat file, a floating coloured beam over dropped loot
  (`wr_compat_doomablo.zs:19-21`).
- **What our Wheel reads:** weapon rarity (seven tiers; `:63-116`), player level and XP (`:163`), and the "Inferno
  level". The file describes Inferno as scaling monster difficulty and loot together (`:181-185`). All of it is
  `wr_Field`, so nothing shows on Quest.
- **Verdict: MAYBE.** Monster affixes plus one danger dial (Inferno) are the closest example here of a single number
  that sets both monster buffs and loot, which is the conductor's problem **[inference]**. It is a looter, not an
  arcade, and the 4.10 engine floor makes running it on Quest doubtful **[inference]**.

## 5. Pandemonia (base) + Anarchy + Insurrection
- **What it is:** Dusted's Pandemonia v2.6.5 by DustedPandemonic, a "gameplay overhaul mod that heavily relies on
  progression". It has a monsters-only version, and Anarchy and Insurrection are add-ons
  (https://forum.zdoom.org/viewtopic.php?p=1059630). That page names no engine and gives no add-on details. I found
  no page about Anarchy or Insurrection themselves.
- **Arcade-like (from our repo, not from a web page):**
  - **Base:** a player-wide game level that the mod raises as you play (`wr_compat_pandemonia.zs:110-119`).
  - **Anarchy:** the Anarchic Sigil. It has three levels and earns XP; used on a live monster, it instantly upgrades
    that monster into its "Anarchic" superboss form (`wr_compat_pandemonia_anarchy.zs:12-21`).
  - **Insurrection:** weapon augments and durability (`wr_compat_pandemonia_insurrection.zs:15-23`).
- **What our Wheel reads:**
  - **Base:** durability, magazine, sidegrades and game level (`wr_compat_pandemonia.zs:50-119`).
  - **Anarchy:** the Sigil's level, points and cooldown (`wr_compat_pandemonia_anarchy.zs:42`).
  - **Insurrection:** augments and combo bar (`:55-180`).
  - All of these end in `wr_Field` reads, so nothing shows on Quest.
- **Verdict: MAYBE (Anarchy only); base Pandemonia and Insurrection NOT.** A player choosing to turn one monster
  into a superboss is a player-triggered challenge, worth one look at how the Sigil is earned and spent
  **[inference]**. The rest is weapon upkeep.

## 6. BorderDoom
- **What it is:** by Sunbeam, update 1.2, written in ACS; the page names no engine
  (https://forum.zdoom.org/viewtopic.php?p=679128).
- **Arcade-like:** weapons roll random damage, pellet count, fire rate and accuracy; shields recharge; players and
  monsters have levels. The page shows no damage numbers, no events and no rarity colours.
- **What our Wheel reads:** cached per-slot stat arrays on the player, through `GetFieldIntArray`
  (`wr_compat_borderdoom.zs:14-22, 88-97`). These are `wr_Field` reads, so nothing shows on Quest. The file warns
  that BorderDoom's own ACS stat functions disturb the player's ammo (`:4-12`).
- **Verdict: NOT.** Monster levels are better covered by Lithium and Doomablo, and it is an old ACS looter.

## 7. DoomRL Arsenal (DRLA)
- **What it is:** by Yholl and Ryan Cordell; class list current as of 1.1.5; runs on ZDoom and GZDoom; more than 200
  weapons. Weapons come in categories (normal, exotic, superior, unique, Demonic), and modpack assemblies turn one
  weapon into another (https://doomwiki.org/wiki/DoomRL_Arsenal). The DoomRL Monster Pack adds the skill levels
  Nightmare, Technophobia and Armageddon, which swap in themed variants of the monsters (same page).
- **Arcade-like:** loot tiers and assemblies; the PDA remembers the assemblies you have learned. The page lists no
  events and no score.
- **What our Wheel reads:** the tier taken from the weapon's pickup class ancestry (`wr_compat_drla.zs:70`) and the
  modpacks (`:165`). These are class and inventory reads, so they work on stock QZD.
- **Verdict: NOT.** This repeats `design/DOOM_ARCADE_MODS_RESEARCH.md:105`: "DRLA offers us nothing for triggered
  challenges". The Monster Pack's skill-level swaps are a small precedent for "call in a different roster", which
  Monster Assembly already plans.

## 8. MetaDoom
- **What it is:** by Kinsie; v7.1 "Ghost" (May 2021); GZDoom with Doom II (https://doomwiki.org/wiki/MetaDoom).
  It "seeks to implement various elements from the wider Doom franchise".
- **Arcade-like (same page):** randomised monster variants drawn from the wider franchise (Nightmare Imp, Wretched and
  others), and an Ultra-Nightmare skill that ends the game on your first death.
- **What our Wheel reads:** weapon heat (`wr_compat_metadoom.zs:38`, a `wr_Field` read) and the Unmaker's Demon Keys
  (`:56`, an inventory walk).
- **Verdict: NOT.** It is a franchise randomizer. "One death ends it" is already part of the demo-category idea in
  BIG_FOURTH_ARCADE.md.

## 9. Combined Arms
- **What it is:** by Combine_Kegan; 2.3 (May 2021), with 3.0 in development; tested on GZDoom 3.2.4 and Zandronum
  3.0 (https://combine-kegan.itch.io/combined-arms). Four weapon sets. The author describes it as
  "more outlandish and unorthodox weaponry without going completely overkill". The companion monster set,
  Malefactors, makes monsters more aggressive (same page).
- **Arcade-like:** none. The page mentions no score and no combos; there are super weapons, berserk upgrades for each
  class, and easter eggs.
- **What our Wheel reads:** class, heat, resources, cooldowns and upgrades, all from the amounts of owned inventory
  items (`wr_compat_combinedarms.zs:105-421`). It deliberately calls no ACS (`:19-25`). These reads work on stock QZD.
- **Verdict: NOT.**

## 10. Final Doomer +
- **What it is:** posted by Sgt. Shivers; v3.4; ZDoom 2.8.1 or GZDoom 2.1.1. It has nine classes, each with a weapon
  set themed on a Final Doom-era megawad. Its post says "The pistols have infinite reloads"
  (https://forum.zdoom.org/viewtopic.php?p=973165).
- **Arcade-like:** none listed (no score, levelling or events).
- **What our Wheel reads:** the active set and per-weapon counters from owned items (`wr_compat_finaldoomer.zs:79-386`).
  These reads work on stock QZD.
- **Verdict: NOT.**

## 11. Guncaster
- **What it is:** by PillowBlaster and others; GZDoom (https://doomwiki.org/wiki/Guncaster). "Primarily a weapon mod,
  it puts the player in control of an anthropomorphic dragon". The forum title shows 3.888b
  (https://forum.zdoom.org/viewtopic.php?p=826316).
- **Arcade-like:** spells, mana and a shop (forum replies). No page mentions score, combos or events.
- **What our Wheel reads:** spell cooldown and player resources (`wr_compat_guncaster.zs:38-59`). These are
  `wr_Field` reads, so nothing shows on Quest.
- **Verdict: NOT.** It replaces the player with a dragon, which is far from a Brutal Doom 22 base.

## 12. Model Swapper
- **What it is:** our own mod (an "RS_" family mod; `wr_compat_modelswapper.zs:3-8`), not a third-party mod. Its
  source is not in this workspace; only the Wheel's side of it is.
- **What our Wheel reads:** a bridge that RS_ForeignModelHandler publishes each tic (`:52`), plus one cvar write used
  to cycle the model (`:18-25, 147`). The bridge is read through `wr_Field`, so nothing shows on Quest.
- **Verdict: NOT** for arcade design. It changes how weapons look, not how the game plays.

---

## Ranked shortlist: worth a deeper look

1. **LegenDoom.** It is in the owner's load, so the conductor must handle it.
   - Exactly what decides which monster becomes Legendary, and when.
   - How its half-health transformation is triggered, and whether we can see it from outside as an event.
   - How it fits with Champions and RS Monsters' tiers, so no monster is tiered twice.
   - Repo starting points: VisualRewards' gem (`VisualRewards/README.md:50-53`), CHALLENGE_BUILDING_BLOCKS.md:118
     (Miniboss's `Bind`), and the open LegenDoom x BD22 item (`BUGS_1.0.md:52`).
2. **Lithium.** Ideas, from its GitHub source.
   - **Phantoms:** when they spawn partway through a map, how they announce themselves, how they escape, and what
     they reward. This is the nearest existing "marked target drops in" challenge.
   - **Score:** how it pays out as currency, and its "tax".
   - **Monster levels:** how they scale to the player's level.
   - **On-screen text:** how damage numbers and place markers are drawn without a canvas, if they are.
3. **DOOM Infinite.** Ideas only; it cannot share a load with BD22.
   - **The "game director":** what it decides, and when, as a model for the conductor.
   - **Run challenges and achievements:** the wording and the conditions.
   - **"Kill points open the exit":** a Doom-native gate that could suit time attack.
   - **Arena waves:** how many monsters, how the count is shown.
4. **DOOMablo (maybe).** Monster affixes and the Inferno dial: how one number sets both danger and loot, and how
   affixed monsters are shown to the player. GitHub source, GZDoom 4.10+.
5. **Pandemonia Anarchy (maybe).** The Anarchic Sigil: how a player earns it and uses it to turn one live monster
   into a superboss. I found no web page about it; the repo is the only source so far.

Not worth more time for the Big Fourth: BorderDoom, DRLA, MetaDoom, Combined Arms, Final Doomer, Guncaster, Model
Swapper, base Pandemonia and Insurrection.

**One open problem to raise with the owner:** on stock QZD 17.3, roughly half of the Wheel's compat reads (Lithium,
Doom Infinite, Doomablo, Pandemonia family, BorderDoom, Guncaster, Model Swapper) return nothing, because `wr_Field`
is stubbed (`Wheel/zscript/wheel/wr_q_shim.zs:873-886`).
