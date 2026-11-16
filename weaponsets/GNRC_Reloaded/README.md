# GNRC Reloaded VR 0.8

Led's Generic Weapon Mod rebuilt for VR on QuestZDoom 17.3: Doom's ten weapons with their hands, real hand reloading
(magazines, a pump, a break-open double-barrel), dual wield and 3D guns, for your own modlist. It is a **vanilla+**
weapon set: Doom's slots, Doom's ammo (shells, rockets, cells; bullets become GNRC's 9 mm and rifle rounds), Doom's
BFG, and it plays with Doom's own monsters or whatever monster mod you load.

**It stands alone.** It needs Doom 2 (or Doom / Freedoom) and nothing else. It works with any player class: if another
mod in your list sets its own, that class's Doom start weapons become GNRC's and every gun still comes loaded. The
RSQ UBQ Series mods are optional extras (see the end).

Load order: `doom2.wad` -> your monster mod (optional) -> `GNRC_Reloaded_0.8.pk3` -> anything else.

## The guns

| Slot | Gun | Fire | Alt fire | Reload |
|---|---|---|---|---|
| 1 | Brass Knuckle | free (your melee mod or the punches below) | free | none |
| 1 | Chainsaw | runs the chain; in VR the bar cuts whatever it touches | none | none |
| 2 | Beretta (pistol) | 10 + 1, about 6 shots a second held | 3-round burst | magazine by hand |
| 2 | Assault Rifle (drops from zombiemen and clip boxes) | full auto or 3-round burst | switches the mode | magazine by hand |
| 3 | Riot Shotgun | 7 pellets, one shot per pull | slug | pump and shells by hand |
| 3 | Double-Barrel Shotgun | one barrel per pull | both barrels | break it open by hand |
| 4 | Minigun | spins up, 2 rounds every 4 tics | none | ammo box by hand |
| 5 | Rocket Launcher | 5-rocket magazine | none | magazine by hand |
| 6 | Plasma Rifle | bolts | a charged rail (20 cells) from the barrel | cell by hand |
| 7 | BFG 9000 | Doom's BFG ball for 40 cells | none | none (fires from the cells you carry) |
| 0 | Quick grenade | a frag with Doom's explosion | | |

- **One shot per pull** on both shotguns: holding the trigger never fires again or breaks the double-barrel open.
- **An empty gun clicks.** With rounds to load, a pull starts the reload instead.
- **The rifle's two modes have two clicks**: a high one for the 3-round burst, a low one for full auto.
- **Explosions are felt in your hands**, never as a shaking view.
- **Every gun comes loaded** the first time you pick it up.
- **You start with two pistols**, one in each hand (Start With Two Pistols; off: one pistol until you find a second).
- The basics: punches (jab, hook, uppercut; an uppercut kicks a barrel away), a pistol whip, lifting a door by hand, the
  quick grenade on slot 0 and a Quick Kick key.

## Options (Options -> GNRC Reloaded VR)

- **Vanilla Damage** (off): off, Led's numbers. On, each gun deals Doom's own damage, and fires at Doom's rate where
  that is how Doom balances it:

  | Gun | Led's (off) | Vanilla Damage (on) |
  |---|---|---|
  | Pistol | 7 a bullet, a shot every 6 tics | 5 a bullet, every 14 tics (the burst stays a burst, 5 a bullet) |
  | Assault Rifle | 7 a round, every 4 tics | 5 a round (the chaingun's), every 4 tics |
  | Riot Shotgun | 7 pellets of 6; slug 42 | 7 pellets of 5; slug 35 |
  | Double-Barrel | one barrel 9 pellets of 6, both 20 of 6 | one barrel 10 of 5, both 20 of 5 (Doom's super shotgun) |
  | Minigun | 2 rounds of 5 every 4 tics | 1 round of 5 every 4 tics (Doom's chaingun) |
  | Rocket Launcher | Doom's rocket hit (20 x 1-8, 128 blast), flies at 45, every 8 tics | the same rocket, flies at 20, every 20 tics |
  | Plasma Rifle | 8 a bolt, every 4 tics | 5 a bolt, every 3 tics; the rail keeps Led's numbers |
  | Chainsaw | Led's saw, about 144 a second | Doom's, about 96 a second |
  | BFG | Doom's BFG ball | unchanged |

  (Bullet, pellet and bolt damage is rolled the way Doom rolls it: x 1-3, plasma x 1-8.)
- **Rifle Underbarrel Launcher** (off): off, the rifle is drawn without its grenade launcher. On, it is drawn, and with
  your off hand on the handguard (the engine's Two-Hand Grip) the **off-hand trigger** launches a grenade for one
  rocket, one a second.
- **Instant Weapon Switch** (on): no lowering and raising when you switch (in VR a lowered gun tips down).
- **Gun Recoil (Visible)** (off): the drawn gun kicks up; your aim and the view never move.
- **Remove HUD Ammo**, **Remove HUD Health and Armor** (off): for players who read them elsewhere.
- Reloading (VR by hand, or Stock), Grab ammo with, New magazine from, Shotgun Shells Per Insert, Reload assist,
  Pistol Semi Auto, Pump Shotgun Spread, Shotgun Slugshot Alt Fire, Ballistics (Stock = GNRC's own look and sounds),
  True Bullets, Two-Hand Spread, Two-Hand Grip, Dual Options (which guns can be held two at once), hands and casings.

## Keys

Options -> Customize Controls -> **GNRC Reloaded VR**: Quick Kick, Dual Wield (a gun in each hand, or the hands back).
The quick grenade has its own key in the Grenade section.

## With the RSQ UBQ Series (optional)

Each of these does something only when its mod is loaded, found by name:
- **RSQ Tactical Rig**: holstered guns are drawn on your body.
- **RSQ Gun Cards**: the rifle's fire mode on the watch card.
- **RSQ Accessibility**: every buzz this pack makes goes through its Rumble Strength and Rumble Backup.
- **RSQ Grenade, RSQ Melee, RSQ Distance Grab**: the quick grenade, the punches and the door lift stand down for them.

## Status

Every item above was run on the QuestZDoom 17.3 Linux rig (logs and frames). **Rig only, not headset-confirmed.**
Sounds were checked by the engine's sound log, not heard.

Credits: CREDITS_GNRC.txt (Led's Generic Weapon Mod and its sources), BD22 VR Reloaded (RS_Brutal22WeaponsQ) for the
meshes, hands and reload systems, the GNRC voxel pack.
