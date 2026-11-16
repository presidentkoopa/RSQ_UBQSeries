# Weapons of Saturn Reloaded (WoS Reloaded) 0.8

Lippeth's Weapons of Saturn, rebuilt for VR in QuestZDoom 17.3. Twelve guns you hold in your hands, reload with your
hands and fire from the muzzle you see. It sits between vanilla Doom and Brutal Doom: the guns hit a bit harder and do
more than vanilla's, with no Brutal Doom gore.

**It stands on its own.** Load it on Doom II (or Doom / Freedoom) with your own monster mods, maps and add-ons. It needs
no other mod. If you also use the RSQ UBQ Series, the Series mods it knows about are picked up automatically (list at
the end); none of them is needed.

Status: tested on the QuestZDoom 17.3 Linux rig (rig only, not headset-confirmed).

## Load order

1. Doom II (or another IWAD)
2. your maps and monster mods
3. **WoS_Reloaded_0.8.pk3**
4. anything that should load after weapons (HUDs, effects). Load only one weapon mod.

On a new game you pick a start: Pistol + Shotgun, Pistol + 1911, or Shotgun + MP40.

## The guns

| Slot | Gun | Fire | Alt fire |
|---|---|---|---|
| 1 | Knuckles | punch with your arms (VR); with Punches off or out of VR, the trigger punches | - |
| 1 | Chain Saw | run the chain, cut whatever the bar touches | **rev burst**: one second of revved chain, double cutting damage, then a two-second rest |
| 2 | Beretta / 1911 / MP40 | semi or full auto | - |
| 3 | Riot Gun | pump shotgun | slug |
| 3 | Coach Gun | one barrel | both barrels; **at point blank a kill blows the monster apart** (its own gib death) |
| 4 | Maschine Rifle | full auto | underbarrel grenade launcher, loaded by hand |
| 4 | Rotary Cannon | spins up, then fires | spins up, then fires plasma bolts |
| 5 | Saturn V | rocket | hold to lock on up to three targets, let go to fire the salvo |
| 6 | Nova Rifle | plasma stream (live 3x scope) | **hold to charge, let go**: the Nova Ball |
| 7 | Titan | Nova | **hold to charge, let go**: the Hyper Nova |

The Chaingun's spots in a map (and the Chaingunner's drop) give the Rotary Cannon or the Maschine Rifle, half the time
each.

## In VR

- **Reload by hand**: drop the magazine, take a new one with the off hand and push it in; pump and break-open shotguns
  are worked by hand, shells one at a time. Reloading can be set to Stock or Flick in the options.
- **Two hands on the gun** (off grip near it) steadies it.
- **Charged shots** (Nova Ball, Hyper Nova): hold alt fire. A glow grows at the muzzle, a buzz rises and the gun hand
  rumbles harder; a beep and one hard pulse say it is full. Let go to fire. Let go before it is full and nothing is
  fired or spent. The shot needs its full cells (5 or 40): with fewer in the magazine the gun reloads, or clicks dry.
- **Butt strike**: both hands on a long gun (Maschine Rifle, MP40, Riot Gun, Coach Gun), drive the stock forward. It
  smacks what it meets (a kick's damage), with a short rest between strikes. Option: Butt Strike.
- **Rotary Cannon, spun by hand**: put the off hand on the barrels and hold its trigger, or swipe the off hand past
  them. The barrels turn and the next trigger pull fires at once, with no spin-up. The trigger alone still works.
- **Punches**: jab, hook and uppercut with either free fist (an uppercut flips a barrel). **Pistol whip** with either
  pistol. **Lift a door** by pressing your palm to it and lifting.
- **Quick Grenade** (slot 0 or its key), **Quick Kick** key, **Dual Wield** key (pistols, MP40, rifle; more in Dual
  Options).

Out of VR every gun works with its normal fire, alt fire and reload buttons.

## Options

Options menu > Weapons of Saturn VR. Among them: VR Hands and skin tone, Punches, Reloading (VR / Stock / Flick), where
new magazines come from, Butt Strike, Ballistics (Stock = Weapons of Saturn's own look and sound; Low / Max = flashes,
echoes, impacts), True Bullets, Remove HUD Health and Armor, Remove HUD Ammo, Real Casing Models, Dual Options.

Accessibility: if RSQ Accessibility is loaded, its Photosensitive Mode makes the charge glow dimmer and slower to fade,
and its Rumble Strength / Rumble Backup apply to the set's rumble.

## Works with (all optional)

RSQ Melee (its punches replace the set's), RSQ Grenade (its grenade replaces the set's frag and feeds the underbarrel),
RSQ Distance Grab (its door lift replaces the set's), RSQ Tactical Rig (holstered guns drawn on your body, ammo
pouch), RSQ Gun Cards (status and gun cards; its Remove HUD Ammo works here), RSQ Accessibility, GBOVR (its HUD replaces
the set's).

## Credits

Weapons of Saturn by Lippeth and everyone in CREDITS.txt. The VR systems, gun meshes and hands come from BD22 VR
Reloaded (presidentkoopa); the 1911 from RS ModelSwapper's BrutalWolf card; pickups from Voxels of Saturn and the BD22
voxel pack.
