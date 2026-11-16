# Weapon condition (owner, 2026-11-16 04:55-05:08): design, build after the kiosk

His starting question: "how do we handle weapon condition? player takes a big hit and cnd drops? or using the weapon
drops cnd?" On jams: "i doubt we can convincingly pull off jams and clears, we don't have precise hands on gun stuff yet"
(no jam-and-clear mechanic). He picked accuracy loss and damage loss ("2 and 3 for sure") and gave his earlier weapon
base as the reference for the curve and the backfire system (`hf_weapon.zs`, the CND section: the profile enum,
HF_CndGetModifiers, HF_CndApplyModifiers).

## Decided

| Question | His answer |
|---|---|
| What wears a gun | **Big hits only:** one blow of more than 20 damage to the player drops the condition of the guns in his hands. Shooting never wears a gun. |
| Repair | **Both:** steel kill-reward bits top a held gun up a little (+1 per bit per held gun); the Boss kiosk repairs fully, for gold |
| Very worn (under 30) | **The wild flip** (below) |
| At 0 | **Losing the gun is an option, off by default:** with it off, a gun stays at its worst band until repaired |
| Which guns | Every gun: one Series layer that tracks a gun by its class (BD22 VR Reloaded, GNRC, WoS, any other mod's guns), with or without LegenDoom |
| Default | **Off**: an option the player turns on; the game plays as today until then |
| Shown | **On Gun Cards:** a small condition bar on the gun's card |
| When | Written now, **built after the kiosk** (the kiosk builder is changing the same gold code) |
| LegenDoom for GNRC / WoS | **Not yet**, "until I play those sets more" |

## The curve (from his earlier weapon base; the numbers are the starting point)

Condition 0-100 per gun. Five profiles, chosen by the gun's kind:

| Profile | Guns | Its bend |
|---|---|---|
| Workhorse | the default; pistols, rifles | the anchor table below |
| Bruiser | shotguns, chaingun / minigun | accuracy penalty halved; damage turns up a band earlier; extra pellets from 40-49; backfire halved |
| Precision | revolver, rail, sniper | accuracy penalty doubled; damage barely changes (at most +10% at the bottom); no pellet bonus |
| Overheat | plasma, BFG | never backfires; its misfire is an overload (more self-damage) |
| Volatile | rockets, grenades | as Workhorse; blast radius to scale with condition later |

Workhorse (accuracy = spread multiplier, so higher is worse; rate > 1 = faster):

| Condition | Accuracy | Damage | Rate | Pellets (spread guns only) | Backfire | Misfire |
|---|---|---|---|---|---|---|
| 90-100 | — | — | — | — | — | — |
| 80-89 | ×1.05 | — | — | — | — | — |
| 70-79 | ×1.12 | −10% | — | — | — | — |
| 60-69 | ×1.15 | −15% | −15% | — | — | — |
| 50-59 | ×1.20 | −20% | −33% | — | 1% | — |
| 40-49 | ×1.30 | −30% | −30% | — | 2% | — |
| 30-39 | ×1.45 | −40% | +5% | — | 3% | — |
| **20-29 (the flip)** | ×1.50 | **+20%** | +20% | ×1.4 / +1 | 4% | 0.5% |
| 10-19 | ×1.80 | **+50%** | +20% | ×1.8 / +2 | 5% | 1% |
| 1-9 and 0 | ×1.90 | **+80%** | +25% | ×2.2 / +3 | 7% | 2% |

- **The wild flip:** under 30 a worn gun turns dangerous and powerful: more damage, more pellets, faster, while its
  accuracy collapses and it can hurt you. A gamble, not just a weaker gun.
- **Backfire:** a small chip to the player (1-5 HP, never lethal by itself, armour ignored) and a sound.
- **Misfire:** a bigger self-hit (4-12 HP; an Overheat gun's overload 8-20) and a sound.
- Both are shown as **toasts** (`PRESENTATION_GUIDE.md` section 5), never as engine centre prints.
- **Damage scaling applies on hit** (the Series layer scales the player's damage by the gun that fired it), so it works
  for bullets, pellets, rockets and plasma alike (the earlier base could not scale a projectile's damage).
- Accuracy needs the gun's own spread: a hook each weapon set (BD22 VR, GNRC, WoS) calls, asked by name; a gun without
  the hook gets damage and backfire only.
- Legendaries and Gun Bonsai may later wear slower or repair better; not in the first version.

## My readings (where the doc left it open; numbers to tune in the headset)

- **How much a big hit wears:** Wear per Big Hit, 3 (1-20). A gun goes from 100 into the wild flip in 24 big hits.
- **Steel bits:** Steel Share 15 % of a kill's bits that are not gold (Gold Share is rolled first), +1 each (the decision).
- **The kiosk's price:** 1 gold a missing condition point over every gun carried, at least 10 (a cycle between Bosses is
  ~250-280 gold, design/KIOSK.md: one gun from 30 back to 100 is 70 gold). It repairs every gun carried, not only the held ones.
- **Misfire:** not lethal by itself either (the doc says so only of the backfire). At most one backfire or misfire a
  second a hand (so a chaingun at 5 does not chip every shot), and the toasts say the health lost.
- **A shot,** for the backfire roll, is a tic in which a hand fired (a hitscan, a rail or a missile born at that hand).
- **The bar:** on the watch card's Weapon card and on Both on One Card (the owner's own setting), not on the small card.

## Built / not built (2026-11-16)

Where it lives: **RSQ Gun Cards** (`GunCards/zscript/rsqgc/cnd.zs`), no new pk3. Gun Cards already rides with every weapon
set, knows both hands' guns and draws the gun's card the bar goes on; the layer is one file plus a few lines in the cards
(`side.zs`, `worldcard.zs`, `card.zs`). Other mods ask it by name (`RSQGC_Service "cnd.*"`, the list at the end of cnd.zs).
Evidence: `design/condition/rig/` (`evidence_2026-11-16.txt` and the frames). Nothing here has been seen in the headset.

| Part | State |
|---|---|
| Master option | **Built, rig only, not headset-confirmed**: Weapon Condition (`rsqgc_cnd`), **off by default**, on Gun Cards' page. Off: no tracking, no wear, no scaling, no steel bits, no REPAIR, no CND row (rig `cnd_m2`: 20 damage a bullet at every condition, no wear, 0 condition log lines) |
| Condition per gun | **Built, rig only, not headset-confirmed**: 0-100 by the gun's class, kept on the player (`RSQGC_CndBook`, saved, carried across maps); a gun first seen is 100. Every gun of every pack (a weapon with ammo that is not melee, a tool or a thrown grenade), with or without LegenDoom. BD22 VR's off-hand copy (`RSQ_Off_<gun>`) is a gun of its own |
| Wear | **Built, rig only, not headset-confirmed**: a blow of more than Big Hit Over (20) to the player takes Wear per Big Hit (3) off the gun in each hand (rig: a monster's 30, 45 on Black Metal, `Rifle 100 -> 97`; its 12, 18 on Black Metal, no wear). Shooting never wears |
| The curve and profiles | **Built, rig only, not headset-confirmed**: the owner's numbers as they are (`RSQGC_Cnd.Curve`); the profile by the gun's name, then its ammo (Precision: rail, sniper, revolver...; Bruiser: shot, SSG, minigun, chaingun, MG42, machinegun; Volatile: rocket, grenade launcher, missile, nuke...; Overheat: plasma, BFG, unmaker, flame...; else Workhorse) |
| Damage on hit | **Built, rig only, not headset-confirmed**: the player's damage scaled by the gun that fired it (`ModifyDamage`): hitscans and rails by their hand (the engine's off-hand flags), missiles by the hand they were born at with its trigger down, their bursts' missiles inherit. Rig `cnd_m1`, the Rifle's 20: 100 -> 20, 75 -> 18, 45 -> 14, 25 -> 24, 5 -> 36 |
| Accuracy | **Built for BD22 VR Reloaded, rig only, not headset-confirmed**: the hook is `RSQGC_Service` GetDouble `"cnd.spread"` (a gun's spread multiplier). BD22 VR Reloaded 2.0.4z's `muzzle.zs` widens BD22's own spread by it (main-hand hitscans, either hand's missiles). Rig `cnd_m3on`: 0.74 deg at 100, 0.87 at 55 (x1.18; the table x1.20), 1.03 at 25 (x1.39; x1.50); off: 0.73 / 0.69 / 0.71. GNRC and WoS do not ask yet: their guns keep their spread |
| Pellets | **Hook only** (`"cnd.pellets"`, `"cnd.pelletmul"`): no weapon set asks yet, so no gun gets the wild pellets |
| Rate | **Built where the gun's frames allow, rig only, not headset-confirmed**: Fire Rate Follows Condition (on). Rig `cnd_m3on`: the Rifle's 4-tic cycle is 6 tics at 55 (x0.67, as the table); at 25 its x1.20 is not reached (its frames are 1 tic and cannot be shortened). Off: 4 tics throughout |
| Backfire / misfire | **Built, rig only, not headset-confirmed**: rolled once a tic a hand fired; never lethal by itself (my reading for the misfire too); at most one a second a hand; a sound and a toast (`RSQVR_Service "toast"`, `down|BACKFIRE -n`, `MISFIRE -n`, `OVERLOAD -n`), never a centre print. Rig: natural backfires at 25 and 5, then forced ones (`rsqgc_cnd_force`), `rig_CND_backfire_misfire_toasts.png` |
| Steel bits | **Built, rig only, not headset-confirmed** (VisualRewards `RSQ_KRSteelBit`, sprite KRBS, `tools/gen_steel_bit.py`): Steel Share (15 %) of a kill's non-gold bits, +1 a bit to each gun in hand (`"cnd.repair"`), only with Weapon Condition on. Rig: four kills, 15 steel bits, six picked up in the window, `Shot_Gun 50 -> 56` |
| Kiosk REPAIR | **Built, rig only, not headset-confirmed** (Miniboss `kiosk.zs`): a REPAIR button left of LUCKY with its price (Repair Gold per Point 1, Repair Minimum 10), the trigger on it: every carried gun to 100 (`"cnd.fix"`) after `gold.spend`; refused with a toast when short. Rig: `103 points on 3 gun(s) for 103 G (bank 400 -> 297)`, `rig_KIOSK_repair_button_and_toast.png`. The rig pressed it through the kiosk's own network event (what its trigger sends), not by pointing |
| The card | **Built, rig only, not headset-confirmed**: a CND row (the word, a bar of 5, the number, in the band's colour) on the watch card's Weapon card and Both on One Card (under the keys), and on the world card. Rig `cnd_m4`: `rig_CARD_cnd_25_and_72.png` |
| Lose the Gun at 0 | **Built, not shown** (off by default): the gun is taken with a toast `<GUN> BROKE`; not run on the rig |
| Netplay | Play state per player (the book on each pawn; per-player arrays in the handler); not tested in netplay |
| Legendaries / Gun Bonsai wearing slower | Not built (not in the first version) |
