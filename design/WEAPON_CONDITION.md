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

## Built / not built (2026-11-16)

| Part | State |
|---|---|
| Everything above | Not built (after the kiosk) |
