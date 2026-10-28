# Bonus ideas

A backlog, not a plan. Nothing here is built and nothing here is approved.

Everything below keeps the existing shape: a multiplier on the base points for *how*
a kill happened, in one of the three families, computable from facts available at the
moment of the kill. Values are in the same range as the thirteen that exist — roughly
0.1 to 0.5 for something you can do often, 1.0 and up only for something rare.

**Under the registry rule, a bonus ships from the mod that owns the fact it
measures.** Where that is not RS_Score, it says so.

**Caveat on the VR and physics entries:** these come from reading the engine's
capability list, not its function signatures. Confirm the actual API before building
any of them, the same way `LineTrace`, `FindInventory` and `SpawnHealth` were checked
for the existing thirteen.

---

## Free now — vanilla facts, no other mod needed

| Bonus | Family | Value | Reads |
| --- | --- | --- | --- |
| **Chain** | Style | 0.2 | Two or more monsters dead on the same tic to the same inflictor. Splash, penetration, a round through two bodies. Compare inflictor and tic. |
| **Skeet** | Style | 0.15 | The *victim* was off the ground. The mirror of Air, and it pairs with it rather than duplicating it. |
| **One Shot** | Efficiency | 0.3 | Full health to dead in a single hit. `WorldThingDamaged` gives the damage; compare against spawn health. |
| **Last Man** | Efficiency | 0.5 | The final monster from the map census. The census already exists, so this is nearly free, and it makes a good end-of-map beat. |
| **Crossfire** | Style | 0.2 | The victim was targeting someone else when it died. Co-op only; reads `victim.target`. |
| **Reflected** | Style | 0.4 | Killed by its own projectile. |

## VR — and the reason a VR scorer should not be a port

| Bonus | Family | Value | Reads |
| --- | --- | --- | --- |
| **Braced** | Efficiency | 0.15 | Two-handed hold at the instant of the shot. The engine publishes two-handed hold to weapons. |
| **Freehand** | Daring | 0.2 | Killed one-handed beyond some distance. The deliberate inverse of Braced, so that neither grip is strictly the correct one. |
| **Off-hand** | Style | 0.25 | Killed with the non-dominant hand. Per-hand psprite routing and the off-hand weapon scripting surface both exist. |
| **Hip-fire** | Daring | 0.2 | Weapon well below eye level and the muzzle not aligned with the head. Reads the hand and headset poses on Actor. |
| **Blind-fire** | Daring | 0.4 | The weapon pose has line of sight to the victim and the head does not. **This cannot exist in flat Doom.** If only one of these gets built, it should be this one. |
| **Full Hands** | Style | 0.2 | Killed while the other hand was gripping something. The grip arbitration protocol already knows. |

## Physics layer

| Bonus | Family | Value | Reads | Ships from |
| --- | --- | --- | --- | --- |
| **Hurled** | Style | 0.3, scaled by release speed | Killed by a thrown rigid body. The engine has a peak-velocity throw release window, so this can pay on how well the throw actually was, and the weight service makes it self-balancing. | throwing |
| **Ricochet** | Style | 0.25 per bounce, capped | The hitscan bounced before it landed. Ricochets are deterministic, so the bounce count is a real number and safe in netplay. | ballistics |
| **Pistol-whip** | Daring | 0.35 | Killed by the weapon's own kinematic body rather than by its attack. Brawler's VR cousin. | — |

## Darkness

| Bonus | Family | Value | Reads | Ships from |
| --- | --- | --- | --- | --- |
| **Blackout** | Daring | 0.3 | Killed something in an area whose lights you shot out. Shot-out lights already ship, so the state is there. | darkness |

## From other packs, under the same rule

- **ShieldSaw** — Parried (killed within N tics of the shield absorbing a hit from
  that same actor), Sawed, Bash.
- **Reload** — Dry (the killing shot was the last round in the magazine), Tactical
  (reload finished with something awake and close).

---

## Considered and rejected

**Bullet Time** — paying extra for kills made during slow motion feeds a reward back
into its own source. Worse, the time scale is global: in co-op one player's slow
motion would inflate everyone's scores.

**Interrupted** (killed mid-attack) — reads well, but it needs the victim's state
machine, which is brittle across monster packs.
