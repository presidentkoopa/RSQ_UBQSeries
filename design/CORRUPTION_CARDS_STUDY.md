# Corruption Cards v6.3b: code study for the challenge conductor (2026-11-08)

Source: `/home/claude/gamedata_real/CorruptionCards-v6.3b.pk3`, read as data (nothing run). Version string `"6.3b"`
(`zscript/corruptioncards/main.zscript:73`). Paths below are inside the pk3; `zscript/corruptioncards/` is shortened
to `cc/`. **[inference]** marks my reading, not something the code states. Nothing here was tested on the rig or in
the headset. No code of ours was changed.

## 1. How it works

### The card pick at map start

| Step | What happens | Where |
|---|---|---|
| Map loads | `CCards_Game.WorldLoaded` (skips TITLEMAP, hub clusters, `ccards_disable`), copies the permanent cards into `deck`, creates the selector thinker | `cc/main.zscript:770-851` |
| Each player enters | Given `CCards_ChoiceInvulnerability` (sets **all** damage to 0, dealt and taken). It deletes itself once the game has started | `cc/main.zscript:1019-1040`, `cc/actors/tools.zscript:540-561` |
| Every monster that spawns before the start | Frozen: `A_SetTics(-1)` plus `CCards_Actor_CardChoiceInvul` (takes no damage). Unfrozen at the start with its old tics or 1-8 random | `cc/thinkers.zscript:106-131, 293-307` |
| Tic 3 | Opens the menu `CorruptionCardsSelector`. First map of a run: game mode, then deck, then cards. Later maps: cards only | `cc/selector.zscript:35-70, 103-106` |
| Tic ~7 | Hand generated (4 tics + `setupdelay` from CCARDS lumps) | `cc/main.zscript:140-158` (`CCards_WorldResolver`), `:861-963` |
| While picking | Players frozen with `SetPlayerProperty(1, on, 4)` = PROP_TOTALLYFROZEN, unless `ccards_selector_nofreeze` | `cc/functions.zscript:166-174`, `cc/selector.zscript:29-33` |
| Pick | Ignored before tic 35. After the last pick, 35 tics of animation (2 with `ccards_noanimation`), then `ChooseCard` and `Start()` | `cc/selector.zscript:233-265, 369-381` |
| Start | `publicdeck` copied, deck sorted, `global.chosenTime = Level.Time`, `isStarted = true`, autosave (unless `ccards_noautosave`) | `cc/main.zscript:429-553`, `cc/selector.zscript:1418-1428` |

- **Length:** at least about 2 seconds (tic 35 plus the 35-tic animation); otherwise it waits for the player with no
  limit. The cvar `ccards_countdown` is declared (`CVARINFO.txt:2`) but nothing reads it.
- **The game is NOT paused.** The menu sets `menuactive = OnNoPause` (`cc/selector.zscript:1378`), so `level.maptime`
  keeps running through the pick. Only players and monsters are frozen.
- If the menu is closed, it reopens every 35 tics for the choosing player (`cc/selector.zscript:314-329`); Back opens
  the main menu (`:817-821`). In co-op players take turns unless `ccards_choiceoption` = 1 (`cc/main.zscript:710-735`).
- **Chaos mode** has no choice; the cards are random (language lump `CC_CHAOSMODE_DESCRIPTION`).

### How it shows
A ZForms menu drawn with `Screen.DrawTexture` / `Screen.DrawShape` at a 704×396 base (`cc/selector.zscript:1374-1396`,
`cc/external/CC_ZForms/Element.zsc:230-241`). Input: `MKEY_Left` / `MKEY_Right` move, `MKEY_Enter` picks
(`cc/selector.zscript:815-860`); ZForms buttons also take mouse clicks. The pick goes out as netevent
`cpickcard <slot>` (`:549-556`). In play, card messages ("A gang of monsters is spawning!") are drawn by
`CCards_UIEvents.RenderOverlay` at 70% screen height (`cc/ui.zscript:25-84`), or printed to the console, depending on
`ccards_cardalerts` (`cc/functions.zscript:270-292`).

### Where the active cards live
| Thing | Type | Holds |
|---|---|---|
| `CCards_Game` | EventHandler (per map), from `MAPINFO.txt` AddEventHandlers | `Array<Card> deck`, `Array<Card> publicdeck`, `bool isStarted`, `bool permanentChoice` (`cc/main.zscript:182-190`) |
| `CCards_Global` | Thinker, STAT_STATIC (whole run) | `collection` (permanent cards), `history`, `foundMonsters`, `progress` (maps survived +1), `seed`, `chosenTime`, `rules` (`cc/main.zscript:3-46`) |
| `Card` (base class) | `play` object | `tier`, `tags[]`, `chosen`, `isDisabled`, `stackIndex`, flags `effectPlayers/Monsters/World`, `wildcard` (`cc/cardtypes.zscript:1-66`) |

Card classes are `CCard_<Name>`; language key `CC_CARD_<NAME>` (`cc/functions.zscript:500-512`). Subclasses: `GenericCard` (one monster type), `GenericBuffCard` (an enchantment),
`GenericProjectileModifier`, `CurseCard`, `TotemCard`, `DeckOperationCard`. 288 card classes are compiled
(`cards/unused.zscript` is not included by `ZSCRIPT.txt`).

Each card runs through thinkers made per actor: `CCards_MonsterThinker` for **every legal monster that ever spawns**
(`cc/main.zscript:998-1017`; legal = `bISMONSTER`, not friendly, not a missile, not banned, `cc/functions.zscript:1203-1241`),
`CCards_PlayerThinker`, and one `CCards_WorldThinker`. They call `OnGameStart / OnSpawn / OnTick / OnDeath / OnRespawn`
(`cc/thinkers.zscript:57-96`).

**Marks it leaves on actors** (readable by class name, no code link needed):

| Mark | Meaning | Where |
|---|---|---|
| `CCards_Actor_BuffManager` (inventory, `buffs[]` of card names) | Monster has one or more enchantments | `cc/cardtypes.zscript:569-603` |
| `CCards_Token_Cursed` (`curses[]`) + the curse's own inventory | Monster carries a curse. Curses go to the highest-health monster | `cc/cards/shared.zscript:1-4`, `cc/cardtypes.zscript:416-505` |
| `CCards_Actor_HeldTotem` / actor `CCards_Actor_Totem` | Monster carries a totem; the totem buffs monsters near it every second, drops when the carrier dies | `cc/cardtypes.zscript:685-781`, `cc/cards/shared.zscript:8-140` |
| `CCards_Actor_MonsterGodMode` | The Chosen One (invulnerable until 90% kills) | `cc/cards/monster.zscript:143-157` |
| `CCards_Actor_QuadDamage` | Quad Conviction monster | `cc/cards/monster.zscript:4127-4134` |
| `CCards_Actor_IllusionBuff`, `CCards_Actor_IllusionistBuff`, `CCards_Actor_LiesIllusion` | Fake monsters: uncounted, deal 0 damage | `cc/cards/world.zscript:1047-1130`, `cc/cards/monsterbuffs.zscript:5360-5431`, `cc/cards/totems.zscript:970` |
| `CCards_Actor_AssassinBuff`, `CCards_Actor_SpecialistDamageResist`, `CCards_Actor_ComboShield` | Assassin, Specialist team member, combo-shielded | `cc/cards/monstergeneric.zscript:690`, `cc/cards/world.zscript:1667`, `cc/cards/monsterabilities.zscript:5890` |
| Player `CCards_ChoiceInvulnerability` | **Pick in progress** | above |
| Player `CCards_Actor_BodySwap` | Player is possessing a monster (Curse of Dormin) | `cc/cards/wildcards.zscript:1910` |
| Player `CCards_Actor_DaisyFound` | Rescue Mission done | `cc/cards/world.zscript:1879, 2010-2019` |
| Actor `CCards_Actor_Daisy` with no owner | Daisy still loose | `cc/cards/world.zscript:1893` |
| Actor `CCards_Actor_GangPortal` | A gang is spawning now | `cc/cards/monstergeneric.zscript:295` |

There is **no common mark on monsters CC spawns**. A spawned extra looks like any monster except for its buffs.

## 2. Cards that touch monsters, the player or items

Clash key: **BD** Brutal Doom 22, **CH** Champions, **LD** LegenDoom, **VR** our rig/holsters/hands, **SC** Score's
25% rule for monsters not there at load, **DN** DOWN, **BF** Miniboss Bossfight. All clash marks are **[inference]**.

### Monsters added or moved (24 cards tagged `newspawn`, 11 `startspawn`, 3 `spawnnew`)
Most spawn through `CCards_SafeSpawner` (`cc/actors/tools.zscript:57-440`): out of the player's sight, at least
512 units away by default, wandering to a free spot. Every spawn is a normal `Spawn()`, so Champions and LegenDoom
roll on it, CC's own buff cards apply to it (`OnSpawn`), and Score pays it 25% (Score's census is taken at
`WorldLoaded`, before the pick, `Score/zscript/rsscore/handler.zs:45-50`).

| Cards | What | Clash |
|---|---|---|
| 16th Sin `CCard_Revenge`, Hell's Answer `CCard_BossRevenge` | A monster (a boss) teleports in near the killer every 16th (42nd) kill; counter is inventory `CCards_Actor_RevengeCount` / `BossRevengeCount` on the player | SC, BF (second spawner), CH, LD |
| Monster Gang, Monster Squad, Miniboss Attack, Warring Factions, The Specialists, The Assassin, Guild of Assassins | A group arrives mid-level when items+secrets+kills pass a random total (`WorldEvent` mixin, `cc/cardtypes.zscript:663-683`); announced by CardAlert | SC, BF, CH, LD, "who speaks" |
| Mystery Eggs, Curse of the Rabbit, Mystery Egg Pouch, 69 Surprises | Shootable eggs hatch monsters (a mini or normal copy), items, grenades, or a special: chicken, fake Daisy, plush weapon, mech, ally marine... (`cc/cards/shared.zscript:366-560`) | SC, VR (plush weapon) |
| Clone Monster, Small Companions, Summoned Monsters, Cherubs Descent, Piloted Mechs/Carrier, Ally Marines, Vile Guardians, Unfinished Business, Garden of Statues, Spawn Pods, The Nest, Gas Pods, Boss-in-a-Box, Sealed Guardians, Scent of Blood | Extra monsters at the start or on a trigger | SC, CH, LD |
| Duplication / Miniature Army / Resurrection / Polymorph curses, Death Echo, Living Vessel, Symbiosis, Distress, Frankenstein, Eldritch horrors (4 cards), Micro Avengers, Haunting, Haunted House | Copies, minis, ghosts, horrors, raises on a death | SC, CH, LD, BF (kill credit) |
| Hotter Start, Revise Strategy, Shifting Curse, Pursuit, Eject, Lock-on Teleports, Void Walk | Monsters teleported, often next to the player | BF and DN fit tests (crowding) |
| Angry Bones, New Hunting Grounds, Balance The Scales | Monsters removed (`A_Remove`), some replaced or doubled (`cc/cards/wildcards.zscript:73-111`, `cc/cards/monster.zscript:1430-1450`) | SC (census holds monsters that vanish), BF roster |

### Monsters made stronger
| Cards | What | Clash |
|---|---|---|
| About 38 `GenericBuffCard` enchantments (Shield, Reflect, Swiftness, Last Breath, Rampart...) and 25 projectile augments | Applied to one monster **type** on spawn, so our teleported monsters of that type get them too | CH + LD + BF tiers stack on one monster |
| Icon's Blessing, Keys of Power, Vile Rebirth, Enchantment Echo, Adaptable Foe, Prismatic / Overpowered curses, Mystical Urns, Jewelled Enchantments, Enchanting Teleports/Augment | Random enchantments handed out | as above |
| 11 Totems (Turbo, Brutal, Aegis, Thorns, Night, Vile, Fireblu, Bath, Change, Lying, Grand) | A totem over a monster in a group; buffs within range each second | as above; a totem is a shootable non-monster |
| The Chosen One, Quad Conviction, Curse of Achilles, Curse of the Cat, Abomination | One monster invulnerable / x4 damage / near-only / 9 lives / 10 forms | A challenge target could be unkillable |
| Blood Rain, Breach!, Quickening, The Dunkening, Iron Skins, Co-operative Evil | Map-wide monster buffs | stacking |

### The player and items
| Card | What it does in code | Clash |
|---|---|---|
| **Curse of Dormin** `CCard_BodySwapCurse` (wild card) | Killing the cursed monster puts the player inside a monster: player made non-solid, non-shootable, invisible; the weapon sprite is replaced; attack / alt attack fire the monster's attacks (`cc/cards/wildcards.zscript:1910-2199`, `:2032`) | **VR** (no gun, hands meaningless), SC (kill credit), DN |
| **Curse of Attention** | While the cursed monster is in sight, the player's yaw is turned toward it every tic (`target.A_SetAngle`, `cc/cards/monstercurses.zscript:2654`) | **VR** (forced turning) |
| Bewilderment | Movement reversed 3 s after a kill | VR |
| Bane (Break the Bat) | Grabs and lifts the player (`target.Warp`, `cc/actors/bane.zscript:366`), throws him and sets pitch 0 (`:341-342`); won't let you leave | VR, BF (a second boss fight) |
| Earthquake | Players, items and monsters thrown about | VR comfort |
| Second Slice `CCard_Lap2` (wild card) | At the exit, players are teleported to the start without keys; a countdown runs (field `timer`) and monsters spawn near players; at 0 every player takes 999999 forced damage (`cc/cards/wildcards.zscript:3577-3598, 3677`) | DN (forced death), SC, an existing timed challenge |
| Fluffy Gifts, eggs | Puts a `Weapon` (`CCards_Actor_PlushWeapon1-7`, slots 1-7) in the player's inventory (`cc/cards/monsterabilities.zscript:4640-4822`) | **VR** holsters/Wheel see a foreign weapon |
| Combo Shield | 80% less damage to that monster type when `player.ReadyWeapon` is in one of 3 chosen slots (`cc/cards/monsterabilities.zscript:5890-5925`) | **VR/BD**: melee, whip and offhand guns are judged by the main-hand ReadyWeapon |
| Spring-loaded Loot, Patience, Demand/Supply (hold USE standing still), Kleptomania, Incineration Curse, Mystify Items, Cult Chow, The Masquerade | Items jump away, are locked 3 s, removed, stolen, burned, disguised; monsters disguised as items | **VR** pickups, DistanceGrab |
| Mirror Curse | Turns on post-process shader `cc_flipper` (`cc/ui.zscript:241-256`, `GLDEFS.txt:1-23`, GLSL 330) | VR (see §4) |
| Unlucky Number, Blurry Affliction, Leaking Soul, The Bleeding, Boiling Blood, Lethality Curse (sets health to a tenth directly, `cc/cards/monstercurses.zscript:289-292`) | Player numbers | DN (health set without damage) |

Rescue Mission: Daisy (`CCards_Actor_Daisy`, an Inventory that wanders) spawns near an item, preferably in a secret
(`cc/cards/world.zscript:1755-1880`). Picking her up by touch gives `CCards_Actor_DaisyFound`. If she is not found,
at 1 s into the next map every monster gets the same seeded enchantment (`:2046-2145`). A fake Daisy can hatch from eggs.

## 3. Hooks, cvars and compatibility

- **No outgoing events.** CC sends no netevents or interface events for others, and has **no detection of other
  mods** (no Brutal Doom, Champions, LegenDoom or GZChaos checks anywhere; only game type and Doom 1 vs 2,
  `cc/functions.zscript:294-297`). GZChaos's "pause during the pick" is GZChaos reading CC, not CC offering it.
- **Its own netevents**: `cpickcard`, `ccconfirm`, `ccnext`, `ccprev`, `ccreturn` (`cc/selector.zscript:340-381`).
- **Static functions** in `CCards_Functions` (`cc/functions.zscript`): `GameStarted()` `:154`, `GetGameTime()`
  (tics since the pick, `:624`), `GetDeckSize()` `:476`, `GetDeckCardClassName(i)` `:528`, `FindCardByName` `:963`,
  `CountCardByName` `:979`, `FindCardByTag` / `CountCardsByTag` `:995, 1029`, `IsLegalMonster` `:1203`. ACS reaches
  them by `ScriptCall` (`acs_source/CC_SELECT.acs:30-65`). Calling them from ZScript needs CC compiled in.
- **Cvars of interest** (`CVARINFO.txt`): `ccards_disable` (all off), `ccards_selector_nofreeze` (compat: no player
  freeze), `ccards_noanimation`, `ccards_cardalerts` (0 overlay, 1 console, 2 both), `ccards_skipmenus`,
  `ccards_noautosave`, `ccards_disablecard` (disables a named card at run time, `cc/main.zscript:304-330`).
- **The real compat API is the `CCARDS` lump** (every one in the load order stacks, `CCARDS.txt:1-21`,
  parser `cc/setup.zscript:180-420`): `excludeactor <class>` (CC ignores the actor entirely: no thinker, no cards,
  `cc/functions.zscript:1213-1216`), `addmonster`, `dontfreeze <class>` (not frozen during the pick),
  `excludemap`, `cleardeckmap`, `monstergroup`, `setupdelay <tics>`, `addcard` / `removecard`.
- **Global class names** with no prefix, which no mod of ours may reuse: `Card`, `GenericCard`, `GenericBuffCard`,
  `CurseCard`, `TotemCard`, `DeckOperationCard`, `GenericProjectileModifier`, `PreloadCard`, `SectorWrapper`, mixin
  `WorldEvent`, `cybertest` (a Cyberdemon subclass, `cc/main.zscript:1197`), `stomachtest`. I grepped the UBQ Series:
  no clash today.

## 4. QuestZDoom 17.3 in VR

Nothing here was checked on the rig or headset. The owner loads CC often, so it loads and runs on his setup.
- **The card pick** is a menu, not a canvas texture: ZForms draws with `Screen.DrawTexture` / `DrawShape` inside
  `Menu.Drawer`, and it takes `MKEY_Left/Right/Enter`. [inference] It should show on QuestZDoom's menu plane and be
  picked with the controller's menu keys, like any menu; the mouse is not needed. A bound `netevent cpickcard 0/1/2`
  would also pick (only the choosing player, after tic 35).
- **In-play text** (card alerts, the Second Slice timer, the Unlucky Number badge) is `RenderOverlay` 2D. [inference]
  Whether it shows in the headset is unknown; `ccards_cardalerts 1` sends alerts to the console instead.
- **Post-process shaders** (`cc_flipper`, `cc_topsyturvy`, GLSL 330): [inference] likely not available on the Quest's
  GLES renderer, so the Mirror Curse would do nothing visible.
- **PROP_TOTALLYFROZEN** stops movement, turning and firing through the engine. [inference] Our ZScript-driven hands,
  holsters and VR guns may still move or act during the pick; the player deals 0 damage anyway.
- Forced yaw, Bane's lift-and-throw, Earthquake throws and Bewilderment are VR comfort problems; Curse of Dormin
  removes the gun outright (section 2).

## 5. Recommendations for the conductor

**Read, never write.** Never set CC cvars, never disable its cards, never give or take its items.

1. **Do not hard-link to CC.** A `CCards_*` type in our ZScript would make our pk3 fail to load without CC.
   Look things up by name at run time: build the class from a string variable (`(class<Inventory>)(name)`), treat
   null as "CC not loaded", then use `CountInv`, `FindInventory` and `ThinkerIterator.Create(cls)`. [inference] If we
   later need the card list itself, the clean way is a tiny bridge pk3, loaded after CC, that calls
   `CCards_Functions` and answers through our usual string service.
2. **Pick in progress** = any player holds `CCards_ChoiceInvulnerability`. While it is held: no clock, no meter, no
   kill counting, no spawning (our monsters would be frozen and invulnerable). Start our clock from the tic it
   disappears, not from `level.maptime` (the pick does not pause the game). Hub maps: CC never starts there, so the
   item stays; also check `level.ClusterFlags & CLUSTER_HUB`.
3. **Mark our own monsters ourselves** (a token, as Miniboss's `RSQMB_Called`). CC spawns carry no common mark, so a CC
   extra must never be taken for our target.
4. **Skip as targets** monsters holding `CCards_Actor_MonsterGodMode`, any illusion mark, `CCards_Actor_HeldTotem`
   carriers (optional), and decorations CC spawns (eggs, totems, pods are not monsters but are shootable).
5. **Buff budget:** count a monster's CC load (`CCards_Actor_BuffManager`, `CCards_Token_Cursed`, `QuadDamage`) before
   Champions / LegenDoom / Bossfight tiers stack on it. We cannot read the buff names without the bridge.
6. **Treat as "challenge already running"** (stay quiet or wait):

| Situation | How to see it |
|---|---|
| Card pick | player `CCards_ChoiceInvulnerability` |
| Curse of Dormin active | player `CCards_Actor_BodySwap` (stand down completely) |
| Rescue Mission open | an ownerless `CCards_Actor_Daisy` exists and no player has `CCards_Actor_DaisyFound` |
| Second Slice lap | needs the bridge (`CCard_Lap2.timer`); [inference] proxy: player teleported to the start after an exit |
| A gang or squad arriving | `CCards_Actor_GangPortal` exists |
| Bane, the 8-bit hero, Santa, Angry Bones' Revenant, the Ancient One, a horror, ROM3R-0 | their actors exist: `CCards_Actor_Bane`, `CCards_Actor_Maestro` (8-bit hero, `cc/cards/wildcards.zscript:408`), `CCards_Actor_Santa`, `CCards_SpookySkeleton`, `CCards_Actor_TheAncientOne`, `CCards_Actor_Horror`, `CCards_Boss_Romero` (`cc/actors/`) |
| Chosen One or Quad monster alive | inventory on a monster, as above |

7. **Second spawner:** our Bossfight and hunts should count CC's arrivals (16th Sin, gangs, eggs) as "awake monsters
   on you" before landing, and keep a cooldown after a CardAlert-style event. [inference]
8. **Score's 25%:** every CC extra is a spawned monster and already pays 25%. If challenge monsters get an exemption,
   it must key on our own mark, never on "spawned after load".
9. **Optional CCARDS lump in our pk3** [inference, owner's call]: `excludeactor` for any helper actor of ours that has
   `bISMONSTER` (probes, hidden copies), so CC does not attach thinkers or buffs to it; `dontfreeze` if one of ours
   must keep acting during the pick. DOWN's hidden Champions copies (up to 300) each get a CC thinker today.
10. **Words:** CC's alerts sit at 70% screen height and send no event; [inference] the gang portal is the only cue.
