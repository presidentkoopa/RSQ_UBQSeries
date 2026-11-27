# BD22 VR Reloaded: how each gun reloads today, from the code (2026-11-27)

Commit read: edfaf632ccb6 (`git log -1`; `git status` showed nothing changed). Nothing was run, built or changed.
Paths are relative to `/home/claude/presidentkoopa/rsq_bd_vr_reloaded/src/`. Base Brutal Doom (brutal22test6.pk3) was
read only for magazine sizes (`actors/MISC/Ammo.dec`) and the Reload key (`KEYCONF.txt`: `defaultbind R "+reload"`).

Settings assumed: every menu row at its default, in VR, one player.
- "VR Reloading" `rsr_reload` = On (CVARINFO.rsq:3, MENUDEF.rsq:73)
- "Non-Standard Reloads" `rsq_reload_nonstd` = On (CVARINFO.rsq:4, MENUDEF.rsq:79)
- "Grab Ammo With" `rsr_grab_with` = Trigger, i.e. the off-hand trigger (CVARINFO.rsq:13, vreload.zs:113-122)
- "Reload Gesture" `rsq_reload_gesture` = Point Down, Shoot (CVARINFO.rsq:15)
- "Dual Reload Gesture" `rsq_flick` = On (CVARINFO.rsq:14)
- "Revolver Reload" `rsb_revolver_feed` = Speedloader (CVARINFO.rsb:26)
- "Magazine From" = Anywhere, "Rig Pouch Only" = On (no effect without RSQ Tactical Rig: vreload.zs:99-108)

**There is no per-gun "VR reloading" row.** The menu has one "VR Reloading" row for every gun (MENUDEF.rsq:73) and one
"Non-Standard Reloads" row for the nine belt/tank guns (MENUDEF.rsq:79). Column "VR reload off" below means: "VR Reloading"
Off, or not in VR (both give the same: vreload.zs:1088), or for the nine belt/tank guns also "Non-Standard Reloads" Off.

## The one rule behind every hand reload

The hand reload (all kinds: magazine, break-open, pump, under-barrel) runs only when ALL of these hold
(`RSR_ReloadHandler.Wanted`, vreload.zs:1086-1095; the break-open code asks the same at rsr_break.zs:1146, the pump code at
rsr_pump.zs:664, 687, 1241, the under-barrel at rsr_m203.zs:946):
1. "VR Reloading" is On and the player is in VR;
2. not Brutal Doom's purist mode;
3. **the off hand holds `RSQ_Hands` (the empty off hand)**.

Anything else in the off hand (an off-hand gun `RSQ_Off_<gun>`, the off-hand axe `RSQ_Off_BrutalAxe`, an RSQ saber, Zippo,
flashlight, whip, grenade, glove: flick.zs:95-101) closes the hand reload for the main gun, and each gun falls back to
whatever its file has after the refusal. That fallback is different gun by gun (see the table).

How a reload is started (all guns): Brutal Doom's own Reload key (`+reload`; BD22's script turns it into the `Reloading`
item the gun's Ready loop reads: the script itself is not in the repo, the code says so at vreload.zs:1241 and
Shotgun.dec:52-54); pulling the trigger on an empty gun (`NoAmmo`, DEFAULTWEAPON.dec:209-228; skipped when Brutal Doom's
"no auto reload" item is held, :224, which this mod forces on while both hands hold guns, dual.zs:431-445); the
`rsr_magrelease` button bit (default BT_OFFHANDRELOAD, CVARINFO.rsr:4; read at vreload.zs:1225-1248 and
rsr_break.zs:1467-1490; the owner says no such button exists on his controllers: not seen whether QuestZDoom ever sends it).
**The reload gesture ("Point Down, Shoot") does NOTHING for a lone gun in the main hand with the off hand empty**, except the
SSG and the rifle's launcher: flick.zs:166-178 gives the main hand a gesture only when the off hand holds a gun, or for a lone
SSG (`loneSSG`, :160), or beside an RSQ series item (`offItem`, :162); a lone rifle gets its launcher only (:157, :170).
The Reload button code also leaves a lone main gun alone (flick.zs:377-382); only Brutal Doom's own `Reloading` item reaches it.

## The kinds of reload in this mod

- **Hand magazine reload** (vreload.zs). The magazine drops out of the gun and falls to the floor; the off hand takes a new
  one out of the air, pushes it into the well; on guns with a handle, if the gun was empty, the off hand then racks the
  slide / bolt / handle. Used by: Pistol, SMG, Rifle, MP40, Assault Shotgun, Railgun, Plasma Rifle, Sniper, Rocket Launcher
  (rsr_guns.bd.zs:24-32, rows 1-9).
- **Hand belt / tank reload** (vreload.zs plus counters.zs). The same hands as above, but the gun is one Brutal Doom never
  reloads; this mod gives it a real magazine (`RSQ_Mag_<gun>`) and no handle. Used by: MG42, Flamethrower, Incendiary
  Launcher, Unmaker, Devastator, Nuke Launcher, Hellish Missile Launcher, Minigun, Machinegun (rsr_guns.bd.zs:33-41, rows
  10-18; counters.zs:10-13).
- **Break-open / revolver speedload** (rsr_break.zs). The barrels or cylinder swing open, spent rounds fly out, the off hand
  pushes a shell (or a whole speedloader) into each empty chamber, then a flick of the gun hand or a push of the off hand
  shuts it. Used by: Super Shotgun, Grenade Launcher, Shotvolver (`Revolver`), Silvergun (`BrutalRevolver`) (rsb_guns.zs:32-35).
- **Pump: hand shell insert and hand pump** (rsr_pump.zs). No magazine. The off hand pushes shells one at a time into the
  loading port (any time, no button needed), and works the pump after each shot. Used by: the pump Shotgun (`Shot_Gun`).
- **Under-barrel by hand** (rsr_m203.zs). The tube slides open, the off hand puts a 40 mm round in, the tube is pulled shut.
  Used by: the Rifle's launcher and the Machinegun's launcher (rsr_m203.zs:57-64).
- **Brutal Doom's own reload animation**. The gun plays BD22's animation and tops its magazine up from the reserve, no hands.
  Used by: every magazine and break-open gun when the hand reload is refused or off; every off-hand gun copy except three.
- **A refill by itself** (no hands, no BD22 animation; a sound and a few tics, the magazine fills from the reserve). Used by:
  the Minigun when the hand reload is refused (Minigun.dec:36-44); the off-hand Minigun always (DECORATE.rsqdualmg:40-50);
  the Super Shotgun on the gesture, either hand, always (SSG.dec:61-86, flick.zs:420-434); the rifle launchers on the gesture
  or the Reload button (rsr_m203.zs:171-206); and the nine belt/tank guns once at the start of every map (counters.zs:270-282:
  `inited` is false in each map's new handler, MAPINFO.rsvr:5 adds it per map).
- **None**: the eight belt/tank guns other than the Minigun when the hand reload is refused (each file's `RSR_Start` ends
  `Goto Ready  // RSR_Stock: BD22 has no reload for this gun`, e.g. MG42.dec:30).

## The table

"Counter" is the magazine number the HUD shows (`RSQ_HudMag`, counters.zs:192-213: the gun's `AmmoType2`, or for the nine
belt/tank guns `RSQ_Mag_<gun>`, counters.zs:141-159). "Parked" means the rounds were moved into an invisible item
`RSR_Held_<gun>` (rsr_guns.bd.zs:1015-1032): not in the gun, not in the reserve number on the HUD, given back into the gun
when the next magazine is seated.

| Gun | Reload kind (VR) | Drop the mag: counter shows / rounds go | Chamber round | Last round fires? | Off hand busy | VR reload off |
|---|---|---|---|---|---|---|
| Pistol `BrutalPistol` | hand magazine, slide rack if it was empty | **1** (if any round was in it) / the rest parked | stays, counted | firing to 0: yes. With the mag out: **no**, trigger dead until a mag seats | BD22 animation | BD22 animation |
| SMG `BrutalSMG` | hand magazine, bolt if empty | 1 / rest parked | stays | as Pistol | BD22 animation | BD22 animation |
| Rifle `Rifle` (magazine) | hand magazine, handle if empty | 1 / rest parked | stays | as Pistol | BD22 animation | BD22 animation |
| Sniper `Sniper` | hand magazine, bolt if empty | 1 / rest parked | stays | as Pistol | BD22 animation | BD22 animation |
| MP40 `MP40` | hand magazine, handle if empty | **0** / all parked | none kept | firing to 0: yes; mag out: nothing to fire | BD22 animation | BD22 animation |
| Assault Shotgun `AssaultShotgun` | hand magazine, handle if empty | 0 / all parked | none kept | as MP40 | BD22 animation | BD22 animation |
| Railgun `RailGun` | hand magazine, no handle | 0 / all parked | none kept | as MP40 | BD22 animation | BD22 animation |
| Plasma Rifle `Plasma_Gun` | hand magazine, no handle | 0 / all parked | none kept | as MP40 | BD22 animation | BD22 animation |
| Rocket Launcher `Rocket_Launcher` | hand magazine, no handle | 0 / all parked | none kept | as MP40 | BD22 animation | BD22 animation |
| MG42, Flamethrower `Flamethrower2`, Incendiary Launcher, Unmaker, Devastator, Nuke Launcher, Hellish Missile Launcher | hand belt/tank | **same number as before** / stay counted in the gun (`RSQ_Mag_<gun>`) | no chamber | firing to 0: yes. Mag out: no (nothing lent, gun cannot fire) | **none: never reloads** once dry | Brutal Doom's own gun: no magazine, fires straight from the reserve |
| Machinegun `Machinegun` (box) | hand belt/tank | same as MG42 | no chamber | as MG42 | none: never reloads | BD21's own gun (no box); its Reload is the grenade only |
| Minigun `Minigun` | hand belt/tank | same number / stay counted in the gun | no chamber | as MG42 | **refills by itself** from the pouch | Brutal Doom's own gun |
| Shotgun `Shot_Gun` (pump) | hand shells + hand pump | no magazine | the shell in the chamber is counted in the 9 | yes, always (fire ends the loading) | BD22 insert animation + automatic pump | same |
| Super Shotgun `SSG` | break-open by hand; gesture = refill by itself | open: same number, a live barrel stays counted | live barrel stays | yes after it shuts; not while open | gesture: refill by itself; Reload key: BD22 animation | BD22 animation (gesture refill still works in VR) |
| Grenade Launcher | break-open by hand | reloads only when empty (0) | n/a (1 round) | yes | BD22 animation | BD22 animation |
| Shotvolver `Revolver` | speedloader by hand | open: same number, live rounds stay counted; empties fly out | live rounds stay | yes after it shuts; not while open | BD22 animation (one shell at a time) | BD22 animation |
| Silvergun `BrutalRevolver` | speedloader by hand | open: same number, live rounds stay counted, but **all six fly out on screen** | live rounds stay | as Shotvolver | the mesh's own animation, fills to 6 | same |
| Rifle / Machinegun launcher | under-barrel by hand; gesture or button = loads by itself | open tube: no round in it | n/a | n/a | gesture or button loads it by itself | BD22 reloads it by itself after each shot |
| Off-hand Pistol, SMG, MP40, Rifle, Plasma Rifle, Assault Shotgun, Railgun (`RSQ_Off_<gun>`) | BD22 animation only (gesture or Reload button) | no drop: top-up, counter never falls | as BD22 | yes | (it is the busy hand) | same |
| Off-hand Shotvolver `RSQ_Off_Revolver` | BD22 animation only | no drop | as BD22 | yes | - | same |
| Off-hand Shotgun `RSQ_Off_Shot_Gun` | BD22 insert animation + automatic pump | no magazine | as BD22 | yes | - | same |
| Off-hand Super Shotgun `RSQ_Off_SSG` | refill by itself (gesture or button) | no drop | - | yes | - | same |
| Off-hand Silvergun `RSQ_Off_BrutalRevolver` | the mesh's own animation | no drop | - | yes | - | same |
| Off-hand Minigun `RSQ_Off_Minigun` | refill by itself from the pouch | no drop | - | yes | - | same |

Guns the player can hold with no reload at all: BFG (BFG.dec has no Reload state), Flame Cannon (FlameCannon.dec:63-65:
Reload is its Ready), Chainsaw (Saw.dec:58: Reload is an inspect), Axe and off-hand Axe (Axe.dec:277, 483), Dragonslayer,
hand grenades. Brutal Doom's own two-gun weapons (`DualPistols`, `DualRifles`, `DualPlasmaRifles`) are not reached: the
guns' jump to them is `A_JumpIf(0, ...)` (e.g. Pistol.dec:234) and dual.zs:447-451 takes the Dual key's item.

Count: 23 main-hand guns with a reload and 12 off-hand copies (dualtable.zs:9-12, the axe left out) = 35.

## Hand magazine reload, step by step (Pistol, SMG, Rifle, Sniper, MP40, Assault Shotgun, Railgun, Plasma Rifle, Rocket Launcher)

1. The reload starts (Reload key, empty trigger, or the gun is selected again with no magazine in it: `Resume`,
   vreload.zs:1257-1308, up to 4 tries). The gun's own `Reload` checks run first (not full, reserve or parked rounds left),
   then `Goto RSR_Start`.
2. `RSR_Start` asks `Wanted`. Yes: the gun goes on to `RSR_Out`. No: `Goto RSR_Stock`, BD22's own animation (vreload.zs:866-885).
3. `RSR_Out`: the magazine drops (`RSR_MagOut`, its sound; it slides 24 cm in 4 tics and falls as a world object,
   vreload.zs:443-450, 488-501). `RSR_Unload` moves the rounds into `RSR_Held_<gun>` and gives the gun's "no magazine" item
   (`HasUnloaded<gun>`).
4. `RSR_Wait`: the gun holds still and **its trigger is dead** (`A_WeaponReady(WRF_NOBOB|WRF_NOFIRE)`, e.g. Pistol.dec:47).
   Switching weapons is allowed; coming back puts it straight back here (step 1, `Resume`).
5. Off hand: press and hold the off-hand trigger at least 20 cm from the magazine's place on the gun (vreload.zs:65, 378-380):
   a magazine appears in the hand (vreload.zs:503-510). Let go = it falls (:514-520).
6. Bring the magazine's top into the well's capture zone, pointing along the well; it is caught and now only moves along the
   well (:524-539). Push it home: its sound, `RSR_Seated` (:568-579). Let go before home = it falls out (:547-554).
7. The gun's `RSR_Fill`: the parked rounds go back in first (`RSR_Return`), then BD22's own top-up from the reserve.
8. If the gun was empty and has a handle (Pistol, SMG, Rifle, Sniper, MP40, Assault Shotgun: `ChargeRule` 1,
   rsr_guns.bd.zs:445-469), the off hand must take the slide / bolt / handle (trigger near it) and pull it back far enough,
   then let go: it springs forward, the reload ends (vreload.zs:454-466, 583-665). Railgun, Plasma Rifle, Rocket Launcher
   have none (`ChargeRule` 0) and end at the seat.
9. `RSR_Done`: back to Ready. Pistol, MG42 and the other belt guns end with `A_ReFire` (Pistol.dec:95): a trigger still held
   fires at once.

The result always equals BD22's own top-up reload: no round is lost and none goes to the reserve.

### Pistol (`BrutalPistol`; magazine 15 + 1, base Ammo.dec:831-834 MaxAmount 16)
- Steps above. Pistol.dec:17-96 (hand reload), :454-468 (Reload), :469-540 (BD22's own `RSR_Stock`).
- Drop the mag: `RSR_Unload` takes rounds only while 2 or more are in the gun (Pistol.dec:37) and parks them
  (Pistol.dec:41-45). So **the counter shows 1** (the chambered round) if the gun had any rounds, 0 if it was empty.
- **Why he cannot fire that 1**: the gun now waits in `RSR_Wait` with the trigger switched off (Pistol.dec:46-51,
  `WRF_NOFIRE`) until a magazine is seated. The Pistol's `Fire` itself would fire it (it checks only `BDPistolAmmo`,
  Pistol.dec:320-321), but it is never reached from the wait. Switching away and back does not help: `Resume` sends the gun
  straight back into the wait (vreload.zs:1281-1307). Only if there is nothing to load (reserve 0 and nothing parked) does
  the Reload give up and go to Ready (Pistol.dec:460-462), and then the 1 fires.
- Seated with a round chambered: fills to 16, no rack (Pistol.dec:64-65, 79-87). Seated empty: fills to 15, rack owed
  (`RSR_Charge`, :66, :70-78).
- Rack shortcut: with rounds in the gun and `RSR_Charge` still held from an earlier reload, the next reload skips the
  magazine and goes straight to the rack (Pistol.dec:31-33).
- Off hand busy or VR reload off: `RSR_Stock`, BD22's animation (Pistol.dec:469-506): rounds stay in the gun, top-up.
  Parked rounds from an unfinished hand reload are NOT given back on this path (nothing in `RSR_Stock` reads
  `RSR_Held_BrutalPistol`).

### SMG (`BrutalSMG`; 40 + 1, base Ammo.dec:213-216)
- Same as the Pistol. SubMachinegun.dec:15-94 (hand reload; keeps 1: :35), :484-507 (Reload), :508 (`RSR_Stock`).
- Same rack shortcut (SubMachinegun.dec:29-31).

### Rifle (`Rifle`; 30 + 1, Rifle.dec:980-983)
- Same, magazine: Rifle.dec:15-80 (keeps 1: :28), :788-814 (Reload), :815 (`RSR_Stock`). Rack owed when empty
  (`RifleReloadToken`, :54-56).
- Its launcher is a separate reload (see "Rifle launcher").

### Sniper (`Sniper`; 10 + 1, Sniper.dec:727-730)
- Same. Sniper.dec:20-79 (keeps 1: :31), :587 (Reload), :610 (`RSR_Stock`). Bolt owed when empty (:55-56).

### MP40 (`MP40`; 32, base Ammo.dec:627-630)
- Same steps, but `RSR_Unload` takes every round (threshold 1, Mp40.dec:27): **counter 0**, no round kept in the chamber.
- Handle owed only when the gun was empty (Mp40.dec:54-56). Mp40.dec:16-80, :430-457 (Reload), :458 (`RSR_Stock`).

### Assault Shotgun (`AssaultShotgun`; 20, AssaultShotgun.dec:800-803)
- As the MP40: all rounds parked, counter 0 (AssaultShotgun.dec:26). Handle owed when empty (:49-52).
- AssaultShotgun.dec:15-73, :471 (Reload), :500 (`RSR_Stock`). Its Fire refuses while the magazine is out (:241).

### Railgun (`RailGun`; 5 shots, base Ammo.dec:645-648; each shot loaded costs 10 cells)
- As the MP40: all parked, counter 0 (Railgun.dec:28). No handle. Railgun.dec:17-74, :609 (Reload), :633 (`RSR_Stock`).

### Plasma Rifle (`Plasma_Gun`; 50, base Ammo.dec:558-561)
- As the MP40: all parked, counter 0 (Plasma.dec:28). No handle. Plasma.dec:17-80, :645 (Reload), :657 (`RSR_Stock`).

### Rocket Launcher (`Rocket_Launcher`; 6, RocketLauncher.dec:785-788)
- As the MP40: all parked, counter 0 (RocketLauncher.dec:30). No handle. RocketLauncher.dec:19-76, :577 (Reload), :597.

## Hand belt / tank reload, step by step (MG42, Flamethrower, Incendiary Launcher, Unmaker, Devastator, Nuke Launcher, Hellish Missile Launcher, Machinegun, Minigun)

Magazine sizes (counters.zs:13): MG42 100, Flamethrower 100 (canister), Incendiary 6, Machinegun 100 (box), Unmaker 200
(skull), Devastator 50, Nuke 1, Hellish 6 (drum), Minigun 200 (box).

1. The gun's `Reload` (e.g. MG42.dec:20-25): magazine out: go put it back; full: Ready; rounds in the pouch: `RSR_Start`.
   An empty magazine with rounds in the pouch sends the gun to Reload by itself (`RSQ_Empty_<gun>`, counters.zs:308-309;
   e.g. MG42.dec:114).
2. `RSR_Start` asks `Wanted` (and "Non-Standard Reloads" On, vreload.zs:871). Yes: `RSR_Out` (MG42.dec:31-35): the magazine
   comes off and falls, `RSQ_NoMag_<gun>` is given.
3. **The rounds stay in `RSQ_Mag_<gun>`** (counters.zs:215-221: "its rounds stay in the magazine for the top-up"), so the
   **counter shows the same number** as before the pull (counters.zs:154). The gun cannot fire: with the magazine out
   nothing is lent to Brutal Doom's fire code (counters.zs:283-284), and it is in `RSR_Wait` with the trigger off anyway.
4. Off hand: take a new one (same rules as step 5 above), push it into the well. No handle on any of them
   (rsr_guns.bd.zs:268-281).
5. Seated: `RSQ_Fill_<gun>` (MG42.dec:42-47) and counters.zs:270-282 move (size minus what is in it) from the pouch into the
   magazine, so the count ends at the full size or the pouch runs out. Done (MG42.dec:48-52, `A_ReFire`).

- Last round: the magazine fires to 0 like any belt (no chamber). Empty: Reload by itself (step 1).
- **Off hand busy**: the magazine stays live (counters.zs:231 asks `WantsHands`, which ignores the off hand,
  vreload.zs:1098-1101), but the hand reload is refused and the file says `Goto Ready` (MG42.dec:30, Flamethrower.dec:35,
  IncendiaryLauncher.dec:29, Unmaker.dec:36, Devastator.dec:35, NukeLauncher.dec:34, HellishMissile.dec:32,
  Machinegun.dec:41). Once dry, every trigger pull goes empty -> Reload -> refused -> Ready: the gun never reloads (until
  the next map's one free fill, counters.zs:270). **Minigun only**: `RSQ_StockFill` (Minigun.dec:36-44): a belt sound, 16
  tics, the magazine tops up from the pouch by itself.
- **VR reload off** (or "Non-Standard Reloads" Off): the rounds in the magazine go back to the reserve, the magazine item is
  idle (counters.zs:232-257), the HUD shows no magazine number (counters.zs:152-153), and the gun is Brutal Doom's own: no
  reload, it fires straight from the reserve (counters.zs:316-320). Flamethrower: BD22's dry-ready loop. Machinegun: BD21's
  Reload is its grenade only (Machinegun.dec:268-273).
- **Every new map**: the first tic a belt gun is held, its magazine fills from the pouch by itself (counters.zs:270-282,
  `inited` false in a new map's handler; MAPINFO.rsvr:5).

### MG42 - MG42.dec:15-52.
### Flamethrower (`Flamethrower2`) - Flamethrower.dec:25-35 (Reload), Ready jumps to Reload when empty (:97).
### Incendiary Launcher - IncendiaryLauncher.dec:19-29.
### Unmaker - Unmaker.dec:23-36 (stops its firing loop sound first, :24-25).
### Devastator - Devastator.dec:25-35.
### Nuke Launcher - NukeLauncher.dec:24-34 (magazine of 1).
### Hellish Missile Launcher - HellishMissile.dec:22-32.
### Machinegun (BD21) - box: Machinegun.dec:31-63 (`RSR_Box`, reached from Reload only when `RSM_VR`, :271); launcher: see below.
### Minigun - Minigun.dec:25-65; refill by itself when refused :36-44. The dropped box says NO AMMO (vreload.zs:414).

## Pump Shotgun (`Shot_Gun`; 9 = 8 in the tube + 1 chambered, Shotgun.dec:1028-1031)

- **Shells by hand, any time, no button** (`FreeFeed`, rsr_pump.zs:231-344, run every tic from :1254): off-hand trigger at
  least 20 cm from the port takes a shell; line it up with the loading port (or the ejection port with "Shotgun Side Port"
  On) and push it home: its sound, "Shells Per Insert" shells credited (default 1, :322-325); the gun's `RSP_Feed` moves one
  `AmmoShell` into `ShotgunAmmo` per credit (Shotgun.dec:30-44). A gun loaded from empty then waits for the pump
  (Shotgun.dec:41-50).
- **Reload key**: BD22's checks (Shotgun.dec:819-851), then `RSP_Load` -> `RSP_LoadWait` (Shotgun.dec:20-24, 74-96): the
  same shell pushing; pressing fire, the Reload key again, or a full pump stroke ends it. The Reload key also starts the hand
  insert straight from a pump wait (`InsertWanted`, rsr_pump.zs:359-376 -> `RSP_VRIns`, Shotgun.dec:51-73).
- **Pump**: after each shot the gun waits for the hand (rsr_pump.zs:683-708): off hand steadied at the pump, or the grab on the
  pump; back (the spent shell out of the port), forward (ready). Fire pressed while it waits: BD22's automatic pump
  (Shotgun.dec:134-143). The owner's answer "always wait for the hand" (ANSWERS.md line 15) is not built yet.
- No magazine: nothing is dropped, nothing parked. Last round: yes; even mid-loading the trigger works (`RSP_LoadWait` has no
  `WRF_NOFIRE`, Shotgun.dec:88).
- Off hand busy or VR reload off: every hook falls through: Reload key -> `RSP_LoadStock`, BD22's insert animation
  (Shotgun.dec:852-856, 24); BD22's automatic pump; no shell by hand (rsr_pump.zs:1241).

## Break-open, step by step (Super Shotgun, Grenade Launcher, Shotvolver, Silvergun)

1. Reload starts (Reload key, empty trigger, or `rsr_magrelease`, rsr_break.zs:1467-1490). Gun's own checks, then `RSB_Start`
   asks `Wanted` (rsr_break.zs:1140-1153). No: `RSB_Stock`, BD22's own animation.
2. It swings open over 6 tics (rsr_break.zs:683-695). At full open the spent rounds fly out (`Eject`, :602-662). **Live
   rounds are not taken out of the count**: `SetChambers` marks as many chambers live as the gun's count says (:578-599).
3. `RSB_Wait`: trigger off (e.g. SSG.dec:34). Off hand: trigger at least 20 cm from the chambers takes a round
   (:486-515, 742-755); the Super Shotgun takes two when both barrels are empty ("SSG Two Shells", :747-749).
4. Line the round's tip up with an empty chamber and push it home (:757-846): its sound, `RSB_LoadT`, the gun's `RSB_Load`
   adds one round and takes one from the reserve (a speedloader fills the cylinder to 6).
5. Shut: a quick turn of the gun hand the closing way (450 deg/s, :702-709) or the off hand pushing the barrels/cylinder
   shut (:942-991). `RSB_Done`, Ready. Switching away while open closes it with what was loaded (:1061-1076).

### Super Shotgun (`SSG`; 2)
- SSG.dec:19-55 (hand), :453-461 (Reload: only when not both loaded and a shell in reserve), :462 (`RSB_Stock`).
- Open with one live barrel: counter 1, that barrel stays loaded; it can be fired after shutting (SSG flags set at
  rsr_break.zs:1030-1043).
- **Gesture ("Point Down, Shoot"), lone or dual, VR Reloading On or Off**: `RSQ_FlickReload` (SSG.dec:61-86, flick.zs:420-434):
  every empty barrel loads from the reserve by itself, then it shuts. So the lone SSG has two reloads side by side.
- Off hand busy: the gesture refill as above (flick.zs:160 `loneSSG` needs only "off hand not a gun"; with a gun it is the
  dual gesture); the Reload key gives BD22's animation.

### Grenade Launcher (`GrenadeLauncher`; 1)
- GrenadeLaunch.dec:18-55 (hand), :272-280 (Reload only when empty), :281 (`RSB_Stock`). Nothing live at open.

### Shotvolver (`Revolver`; 6 shells, Revolver.dec:532-535)
- Revolver.dec:17-55 (hand), :390-401 (Reload), :402 (`RSB_Stock`). Speedloader at default (rsb_guns.zs:35).
- Open: one casing per empty chamber flies out (rsr_break.zs:628-635), live rounds stay counted; the speedloader home tops the
  cylinder up to 6 (Revolver.dec:39-51). Shut without loading: the old live rounds are still there.
- Off hand busy or VR reload off: BD22's own one-shell-at-a-time animation (Revolver.dec:402-448).
- "Revolver Reload: Per Round" (`rsb_revolver_feed` 1): the first round pushed fills all six (Revolver.dec:39-42 always
  goes to the top-up loop). The owner has decided both revolvers always speedload and the row goes (ANSWERS.md line 14).

### Silvergun (`BrutalRevolver`; 6 shots, 3 pistol rounds `Clip1` each)
- BrutalRevolver.dec:206-249 (hand), :173-179 (Reload), :180-204 (`RSB_Stock`, the mesh's own animation).
- Open: **all six rounds are thrown out on screen** (`WorldEject`, rsr_break.zs:616-622), but the live count is kept
  (`RSB_Eject` takes only the token, BrutalRevolver.dec:223-225). The speedloader home fills to 6 (:229-235).
- Empty trigger: reloads by itself whenever 3 `Clip1` are left (`NoAmmo`, BrutalRevolver.dec:164-166), even while Brutal
  Doom's "no auto reload" is on.
- Off hand busy or VR reload off: the mesh's own animation (:180-204).

## Rifle launcher and Machinegun launcher (under-barrel)

- In VR, VR Reloading On, off hand empty (`active`, rsr_m203.zs:946): steady the rifle with the off grip, hold the off trigger
  and push forward: the tube opens (sound, case out); take a 40 mm round (a rocket by default, "Rifle Grenade Ammo",
  rsr_m203.zs:81-95) away from the gun, push it into the breech; steady and pull back: shut (rsr_m203.zs:5-14).
- Secondary fire with nothing loaded: a dry click, no reload (Rifle.dec:495-503).
- Gesture: a lone rifle's "Point Down, Shoot" loads the launcher only, by itself (flick.zs:157, 170, 289-305;
  rsr_m203.zs:171-206): an open tube takes a round and shuts; a shut empty one is filled straight from the reserve.
- Off hand busy: the hand tube is off (rsr_m203.zs:946); the gesture or the Reload button loads it by itself
  (flick.zs:385, 452-453).
- VR reload off: BD22 reloads the launcher by itself after each shot (`RSM_NotLoaded` -> `ReloadGrenade`, Rifle.dec:495-497,
  538-566). Machinegun: BD21's grenade reload (Machinegun.dec:268-273).

## Off-hand copies (`RSQ_Off_<gun>`)

- None of them ever uses a hand reload: with a copy in the off hand, `Wanted` is false (the off hand is not `RSQ_Hands`), and
  `RSR_Start` / `RSB_Start` / `RSP_LoadStart` look at the main gun anyway (vreload.zs:868).
- They reload only from the gesture (that hand pointed down + its trigger, "Dual Reload Gesture" On, flick.zs:148-152,
  247-313) or the Reload button (always reloads the off hand's gun, flick.zs:367-408). BD22's `Reloading` item is read on the
  main layer only (e.g. Pistol.dec:228 `OverlayID() != 1000000`). An empty off gun only clicks: "no auto reload" is forced
  on while both hands hold guns (dual.zs:431-445).
- Pistol, SMG, MP40, Rifle, Plasma Rifle, Assault Shotgun, Railgun copies: `Reload` -> `RSR_Start` (refused) -> `RSR_Stock`,
  BD22's animation on the copy's own magazine (DECORATE.rsqdual:465-479, 1671-1694, 2277-2304, 3304-3330, 4133-4144,
  6363-6391, 7283-7306). Top-up: the counter never drops.
- Shotvolver copy: BD22's one-shell animation (DECORATE.rsqdual:1047-1059). Shotgun copy: BD22's insert animation and
  automatic pump (DECORATE.rsqdual:4273, 5065). Super Shotgun copy: its own `RSQ_FlickReload`, refill by itself
  (DECORATE.rsqdual:5343). Silvergun copy: the mesh's own animation (BrutalRevolver.dec:338-363). Minigun copy: refill by
  itself from the shared pouch (DECORATE.rsqdualmg:40-50, counters.zs:356-381).
- The main gun beside a copy: refused, so the fallback in its row of the table (BD22 animation for magazine, pump and
  break-open guns; none for the eight belt/tank guns; refill by itself for the Minigun). The code has no rule against a belt
  gun in the main hand beside an off-hand copy (PART_6 B6.1 checked dual.zs).

## What the off hand being busy does, by what is in it

- **An off-hand gun copy**: main gun refused. Main gun reloads from its gesture, the Reload button, or the Reload key.
- **An RSQ series item** (saber, Force hand, ShieldSaw, Zippo, cigarette, flashlight / torch, whip, grenade, glove:
  flick.zs:95-101): main gun refused; its gesture sends it into its own Reload (`offItem`, flick.zs:162, 169), which ends in
  the refusal fallback. The Reload button skips the main gun (flick.zs:377-382), but the Reload key's `Reloading` item still
  reaches it. Whether one of these items has a `Reload` state of its own (then flick.zs:84 would count it as a gun) is not
  seen: they live in other mods.
- **The off-hand axe** (`RSQ_Off_BrutalAxe`, two axes are on by default, CVARINFO.rsqdual:15): main gun refused; no gesture
  at all (the axe is neither a gun, flick.zs:77, nor a series item), except a lone SSG's refill and a lone rifle's launcher.
  Only the Reload key or an empty trigger reach the main gun.

## Things that look broken (one line each)

1. Pistol, SMG, Rifle, Sniper: after the drop the counter shows 1 chambered round but the trigger is off in `RSR_Wait`
   (Pistol.dec:47) and `Resume` puts the gun back there when reselected (vreload.zs:1281-1307): the 1 cannot be fired.
2. Parked rounds (`RSR_Held_<gun>`) show nowhere: not in the counter, not in the reserve number (counters.zs:145, 156-157).
3. A hand reload left half done and then finished by BD22's animation (off hand became busy, VR off) never gives the parked
   rounds back (each `RSR_Stock`, e.g. Pistol.dec:469-506, Rifle.dec:815-830; PART_1 B1.4).
4. Eight belt/tank guns never reload once dry with anything but the empty hand in the off hand (MG42.dec:30 and the seven
   like it; counters.zs:231 keeps their magazine live; PART_6 B6.1). The Minigun alone refills (Minigun.dec:36-44).
5. Belt/tank guns: pulling the magazine leaves the counter unchanged (counters.zs:154, 215-221); the owner wants those rounds
   back in the reserve (ANSWERS.md line 28), not built.
6. Belt/tank guns: a pulled magazine that still holds rounds cannot be put back once the shared reserve reaches 0
   (vreload.zs:364 checks only the reserve and `RSR_Held_*`; PART_6 B6.8).
7. Belt/tank guns refill from the pouch by themselves at every new map (counters.zs:270-282, per-map handler MAPINFO.rsvr:5).
8. Silvergun: all six rounds fly out on screen when it opens but the live ones stay in the count (rsr_break.zs:616-622,
   BrutalRevolver.dec:223-225).
9. Silvergun reloads itself on an empty trigger even with "no auto reload" on (BrutalRevolver.dec:164-166); every other gun
   obeys it (DEFAULTWEAPON.dec:224).
10. Pistol / SMG rack shortcut: a reload with rounds in the gun and an old `RSR_Charge` racks instead of changing the
    magazine (Pistol.dec:31-33, SubMachinegun.dec:29-31; PART_6 B6.12).
11. Shotvolver "Per Round" fills all six on the first round (Revolver.dec:39-42); row to be removed per the owner.
12. The reload gesture does nothing for a lone magazine, belt or pump gun with the off hand empty (flick.zs:169-178), while
    the same gesture fully reloads a lone SSG by itself (flick.zs:160, SSG.dec:61-86).

## Differences between guns that look unintended

- **What stays in the gun when the magazine drops**: Pistol, SMG, Rifle, Sniper keep 1 (Pistol.dec:37, SubMachinegun.dec:35,
  Rifle.dec:28, Sniper.dec:31); MP40, Assault Shotgun, Railgun, Plasma Rifle, Rocket Launcher keep 0 (Mp40.dec:27,
  AssaultShotgun.dec:26, Railgun.dec:28, Plasma.dec:28, RocketLauncher.dec:30). (The split follows BD22's "+1" guns.)
- **What the counter means with the magazine out**: magazine guns show only the chamber (1 or 0); the nine belt/tank guns
  show the whole pulled magazine (counters.zs:154); break-open guns show the live rounds left in the open gun.
- **Where the pulled rounds go**: magazine guns park them in a hidden item (`RSR_Held_<gun>`); belt/tank guns keep them in
  the magazine item (`RSQ_Mag_<gun>`); neither returns them to the reserve. Same top-up result, two mechanisms.
- **Off hand busy**: magazine guns, pump and break-open guns fall back to BD22's animation; the Minigun refills by itself;
  the other eight belt/tank guns get nothing (see table).
- **Off-hand copies**: seven use BD22's animation, the SSG copy and the Minigun copy refill by themselves, the Silvergun copy
  plays the mesh animation.
- **The gesture alone in the main hand**: nothing for most guns; a full refill by itself for the SSG; a launcher load by
  itself for the rifle (flick.zs:157-178).
- **Trigger while reloading**: the pump Shotgun can fire mid-loading (Shotgun.dec:88); every magazine, belt and break-open
  gun cannot until the reload ends (`WRF_NOFIRE` in `RSR_Wait` / `RSB_Wait`).
- **Taken up again after a weapon switch**: magazine and belt guns restart the hand reload on reselect (`Resume`,
  vreload.zs:1257); break-open guns shut with what was loaded (rsr_break.zs:1061-1076); the pump just stops.
- **Empty trigger**: the Silvergun always auto-reloads (BrutalRevolver.dec:164-166); every other gun obeys "no auto reload".
- **Shotvolver vs Silvergun on opening**: the Shotvolver throws only the empties (rsr_break.zs:628-635), the Silvergun throws
  all six (rsr_break.zs:616-622), both keep the live count.

## Not seen (depends on the engine or on code not in the repo)

- BD22's script that turns the Reload key into the `Reloading` item, and its "no auto reload" option's default
  (`bd_noautoreload`; dual.zs:444 falls back to 0).
- Which controller button, if any, sends BT_OFFHANDRELOAD (the `rsr_magrelease` default) or BT_RELOAD on QuestZDoom.
- Whether `A_WeaponReady(WRF_NOFIRE)` leaves the engine's "ready" flag set (decides whether the gesture can reach a gun that
  is waiting in `RSR_Wait`; it does not matter for a lone gun, whose gesture is off anyway).
- Whether the RSQ series items have a `Reload` state (flick.zs:84).
