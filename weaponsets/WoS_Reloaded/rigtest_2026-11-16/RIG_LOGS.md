# WoS_Reloaded 0.8, 2026-11-16: rig logs (QZD 17.3 Linux rig, rig only, not headset-confirmed)
# probe lines: WFX/WATCH/SPIN/BTN = this lane's rig-only probe; STATE/AMMO/DMG/PROBE = the suite's probe

## 1. Chaingun spots (doom2 + WoS alone): 20 Chaingun placed, 20 Chaingunners killed
      8 RSQWS_MachineRifle dropped 0
      9 RSQWS_MachineRifle dropped 1
     12 RSQWS_Minigun dropped 0
     11 RSQWS_Minigun dropped 1
## 1b. with the Series (GunBonsai + WoS + 20 RSQ pk3s, Miniboss left out: it needs LegenDoom and Champions)
      5 RSQWS_MachineRifle dropped 0
      6 RSQWS_MachineRifle dropped 1
      5 RSQWS_Minigun dropped 0
      4 RSQWS_Minigun dropped 1
      1 RSQWS_Motorsaw dropped 0
      1 RSQWS_Riotgun dropped 0
      1 RSQWS_SaturnV dropped 0
   (the last three are the map's own pickups, logged as they spawn)

## 2. full cost (t1): Nova 3 cells no reserve -> dry; 3 cells + reserve -> stock reload; Titan 30 -> dry, 40 -> Hyper Nova; Titan 3 -> dry
MARK_NOVA
STATE t111 RSQWS_Riotgun Deselect
STATE t126 RSQWS_NovaRifle Select
STATE t141 RSQWS_NovaRifle Ready
AMMO t175 main RSQWS_NovaRifle Cell=60 RSQWS_Cellpak=60
STATE t175 RSQWS_NovaRifle AltFire
PROBE t188 missile RSQWS_NovaBall
STATE t218 RSQWS_NovaRifle Ready
MARK_NOVASHORT
AMMO t244 main RSQWS_NovaRifle Cell=60 RSQWS_Cellpak=55
AMMO t244 main RSQWS_NovaRifle Cell=0 RSQWS_Cellpak=3
STATE t244 RSQWS_NovaRifle Reload
STATE t252 RSQWS_NovaRifle Ready
MARK_NOVARELOAD
AMMO t293 main RSQWS_NovaRifle Cell=0 RSQWS_Cellpak=3
AMMO t303 main RSQWS_NovaRifle Cell=100 RSQWS_Cellpak=3
STATE t312 RSQWS_NovaRifle StockReload
STATE t333 RSQWS_NovaRifle Ready
MARK_TITAN
AMMO t518 main RSQWS_NovaRifle Cell=43 RSQWS_Cellpak=60
STATE t518 RSQWS_NovaRifle Deselect
STATE t533 RSQWS_TITAN Select
STATE t548 RSQWS_TITAN Ready
AMMO t587 main RSQWS_TITAN Cell=0 RSQWS_BFGCell=30
STATE t592 RSQWS_TITAN Reload
STATE t600 RSQWS_TITAN Ready
MARK_TITANFULL
AMMO t655 main RSQWS_TITAN Cell=0 RSQWS_BFGCell=30
AMMO t660 main RSQWS_TITAN Cell=0 RSQWS_BFGCell=40
STATE t660 RSQWS_TITAN AltFire
PROBE t694 missile RSQWS_HyperNova
STATE t739 RSQWS_TITAN Ready
MARK_TITANNOVA
AMMO t769 main RSQWS_TITAN Cell=0 RSQWS_BFGCell=0
STATE t769 RSQWS_TITAN Reload
STATE t777 RSQWS_TITAN Ready
AMMO t814 main RSQWS_TITAN Cell=0 RSQWS_BFGCell=3
STATE t820 RSQWS_TITAN Fire
PROBE t826 missile RSQWS_Nova
STATE t843 RSQWS_TITAN Ready
MARK_1911

## 3. Knuckles (t1): Punches off -> the trigger punches; Punches on (VR) -> trigger free
MARK_KNUCK
STATE t1001 RSQWS_1911 Deselect
STATE t1016 RSQWS_Knuckles DoKick
STATE t1031 RSQWS_Knuckles Ready
STATE t1077 RSQWS_Knuckles Fire
DMG t1080 DoomImp by RSQWS_FistPuff 16
STATE t1086 RSQWS_Knuckles Ready
STATE t1110 RSQWS_Knuckles Fire
DMG t1113 DoomImp by RSQWS_FistPuff 2
STATE t1119 RSQWS_Knuckles Ready
MARK_KNUCKON
STATE t1145 RSQWS_Knuckles AltFire
STATE t1155 RSQWS_Knuckles Ready
STATE t1185 RSQWS_Knuckles AltFire
STATE t1191 RSQWS_Knuckles Ready
MARK_END

## 4. Tactical Rig reads the set's RSQTRFIT (tr1)
T_ASSIGN t102: web: RSQWS_Riotgun assigned to Left shoulder and holstered there
T_ASSIGN t108: web: RSQWS_NovaRifle assigned to Right shoulder and holstered there
T_ASSIGN t127: web: RSQWS_MachineRifle assigned to Left hip and holstered there
T_ASSIGN t127: web: RSQWS_Coachgun assigned to Right hip and holstered there
T_ASSIGN t127: web: RSQWS_SaturnV assigned to Left chest and holstered there
T_ASSIGN t127: web: RSQWS_Minigun assigned to Right chest and holstered there

## 5. Gun Cards' reading (WoS + Gun Cards with this lane's card.zs)
WFXGC t103 hand RSQWS_Knuckles empty 1 grenades 3 hud_noammo false
WFXGC t169 hand RSQWS_MP40 empty 0 grenades 3 hud_noammo false
WFXGC t329 hand RSQWS_MP40 empty 0 grenades 3 hud_noammo true

## 6/7. charge glow and buzz, muzzle lights (t2, t3, t1)
WFX t102 glow age 0 fill 0.00 fading 0 alpha 0.00 scale 0.020 muzzle-dist 0.0 (muzzle ok 1) buzzers 0
WFX t102 glow spawned RSQWS_ChargeGlowNova
WFX t103 glow age 1 fill 0.08 fading 0 alpha 0.25 scale 0.062 muzzle-dist 0.0 (muzzle ok 1) buzzers 1
WFX t104 glow age 2 fill 0.15 fading 0 alpha 0.31 scale 0.095 muzzle-dist 0.0 (muzzle ok 1) buzzers 1
WFX t105 glow age 3 fill 0.23 fading 0 alpha 0.36 scale 0.127 muzzle-dist 0.0 (muzzle ok 1) buzzers 1
WFX t106 glow age 4 fill 0.31 fading 0 alpha 0.42 scale 0.159 muzzle-dist 0.0 (muzzle ok 1) buzzers 1
WFX t107 glow age 5 fill 0.38 fading 0 alpha 0.47 scale 0.192 muzzle-dist 0.0 (muzzle ok 1) buzzers 2
WFX t108 glow age 6 fill 0.46 fading 0 alpha 0.52 scale 0.224 muzzle-dist 0.0 (muzzle ok 1) buzzers 2
WFX t109 glow age 7 fill 0.54 fading 0 alpha 0.58 scale 0.256 muzzle-dist 0.0 (muzzle ok 1) buzzers 2
WFX t110 glow age 8 fill 0.62 fading 0 alpha 0.63 scale 0.288 muzzle-dist 0.0 (muzzle ok 1) buzzers 2
WFX t111 glow age 9 fill 0.69 fading 0 alpha 0.68 scale 0.321 muzzle-dist 0.0 (muzzle ok 1) buzzers 3
WFX t112 glow age 10 fill 0.77 fading 0 alpha 0.74 scale 0.353 muzzle-dist 0.0 (muzzle ok 1) buzzers 3
WFX t113 glow age 11 fill 0.85 fading 0 alpha 0.79 scale 0.385 muzzle-dist 0.0 (muzzle ok 1) buzzers 3
WFX t114 glow age 12 fill 0.92 fading 0 alpha 0.85 scale 0.418 muzzle-dist 0.1 (muzzle ok 1) buzzers 3
WFX t115 glow age 13 fill 1.00 fading 1 alpha 0.90 scale 0.450 muzzle-dist 0.1 (muzzle ok 1) buzzers 4
WFX t116 glow age 13 fill 1.00 fading 1 alpha 0.72 scale 0.345 muzzle-dist 0.0 (muzzle ok 1) buzzers 4
WFX t117 glow age 13 fill 1.00 fading 1 alpha 0.55 scale 0.240 muzzle-dist 0.0 (muzzle ok 1) buzzers 4
WFX t118 glow age 13 fill 1.00 fading 1 alpha 0.38 scale 0.135 muzzle-dist 0.0 (muzzle ok 1) buzzers 4
WFX t949 flash for RSQWS_1911: row RSQWS_1911 radius 250 colour ffd49a tics 2 tail rsb/tail/pistol_mag/ext / rsb/tail/pistol_mag/ext vol 0.85
WFX t188 flash for RSQWS_NovaRifle: row RailGun radius 220 colour 8080ff tics 2 tail  /  vol 1.00
WFX t694 flash for RSQWS_TITAN: row NukeLauncher radius 420 colour ff9940 tics 4 tail  /  vol 1.00

## new 1. butt strike, Riot Gun (b2) and Maschine Rifle (b3, cooldown)
MARK_SHOVE1
WATCH t122 steady 1 kind 6 hand 5.0 12.0 34.0 off 5.1 18.7 35.4 gap 20.6 cm
DMG t123 DoomImp by RSQWS_ButtStrike 20
WATCH t123 steady 1 kind 6 hand 5.0 18.8 34.0 off 5.1 25.5 35.4 gap 20.6 cm
MARK_SHOVE2_COOL
DMG t144 DoomImp by RSQWS_ButtStrike 18
MARK_SHOVE3
DMG t208 DoomImp by RSQWS_ButtStrike 16
MARK_ONEHAND
MARK_OFF
DMG t309 DoomImp by rsqb_punch 4
MARK_A
DMG t123 Demon by RSQWS_ButtStrike 30
MARK_B_WITHIN_COOL
MARK_C_AFTER
DMG t167 Demon by RSQWS_ButtStrike 18

## new 2. hold to charge (h1): taps fizzle (no cells), holds fire on release
MARK_NOVA_TAP
AMMO t112 main RSQWS_NovaRifle Cell=60 RSQWS_Cellpak=60
BTN t114 32 wstate 557184 pending none psp 1
BTN t120 0 wstate 557199 pending none psp 1
AMMO t160 main RSQWS_NovaRifle Cell=60 RSQWS_Cellpak=60
MARK_NOVA_HOLD
BTN t162 32 wstate 557184 pending none psp 1
BTN t207 0 wstate 557184 pending none psp 1
PROBE t207 missile RSQWS_NovaBall
AMMO t267 main RSQWS_NovaRifle Cell=60 RSQWS_Cellpak=55
MARK_TITAN_TAP
BTN t341 32 wstate 557184 pending none psp 1
BTN t361 0 wstate 557199 pending none psp 1
AMMO t401 main RSQWS_TITAN Cell=140 RSQWS_BFGCell=160
MARK_TITAN_HOLD
BTN t403 32 wstate 557184 pending none psp 1
BTN t473 0 wstate 557184 pending none psp 1
PROBE t473 missile RSQWS_HyperNova
AMMO t563 main RSQWS_TITAN Cell=140 RSQWS_BFGCell=120

## new 3. Chain Saw rev burst (r1)
MARK_TRIGGER
DMG t112 Demon by RSQWS_SawCut 9
STATE t112 RSQWS_Motorsaw RSVR_SawRun
DMG t114 Demon by RSQWS_SawCut 10
DMG t116 Demon by RSQWS_SawCut 10
STATE t148 RSQWS_Motorsaw Ready
MARK_REV
DMG t167 Demon by RSQWS_SawCutRev 18
STATE t167 RSQWS_Motorsaw ? (sprite 63 frame A tics 1)
DMG t169 Demon by RSQWS_SawCutRev 8
DMG t171 Demon by RSQWS_SawCutRev 12
DMG t173 Demon by RSQWS_SawCutRev 4
DMG t175 Demon by RSQWS_SawCutRev 12
STATE t202 RSQWS_Motorsaw Ready
MARK_REV_COOL
STATE t218 RSQWS_Motorsaw ? (sprite 63 frame A tics 6)
STATE t224 RSQWS_Motorsaw Ready
MARK_REV_AGAIN
STATE t294 RSQWS_Motorsaw ? (sprite 63 frame A tics 1)
STATE t329 RSQWS_Motorsaw Ready
MARK_GIB

## new 4. Coach Gun point blank (r1, g2)
MARK_TRIGGER
MARK_REV
MARK_REV_COOL
MARK_REV_AGAIN
MARK_GIB
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
DMG t345 Zombieman by none 1000000
PROBE spawned Zombieman at 50 sight 1 pos -96 834 56 player -96 784 56 angle 90 monster 1 shootable 1 health 20
DMG t417 Zombieman by RSQWS_ShotPuff 18
RSQWS point blank t417: Zombieman gibbed at 30 units
DMG t417 Zombieman by RSQWS_ShotPuff 6
MARK_FAR
PROBE spawned Zombieman at 400 sight 1 pos -96 1184 56 player -96 784 56 angle 90 monster 1 shootable 1 health 20
MARK_ONE
PROBE spawned Zombieman at 50 sight 1 pos -96 834 56 player -96 784 56 angle 90 monster 1 shootable 1 health 20
DMG t529 Zombieman by RSQWS_AltPuff 18
DMG t529 Zombieman by RSQWS_AltPuff 12
MARK_MID
PROBE spawned Zombieman at 130 sight 1 pos -96 914 56 player -96 784 56 angle 90 monster 1 shootable 1 health 20
DMG t113 Zombieman by RSQWS_ShotPuff 6
DMG t113 Zombieman by RSQWS_ShotPuff 6
DMG t113 Zombieman by RSQWS_ShotPuff 12
MARK_CLOSE
PROBE spawned Zombieman at 50 sight 1 pos -96 834 56 player -96 784 56 angle 90 monster 1 shootable 1 health 20
DMG t168 Zombieman by RSQWS_ShotPuff 12
RSQWS point blank t168: Zombieman gibbed at 30 units
DMG t168 Zombieman by RSQWS_ShotPuff 18

## new 5. Rotary Cannon spun by the off hand (s2): trigger alone 8 tics to the first shot; grabbed or swiped, the shot the same tic
MARK_TRIGGER_ONLY
STATE t107 RSQWS_Minigun Fire
BTN t107 1 wstate 557184 pending none psp 1
PROBE t115 hitscan
STATE t115 RSQWS_Minigun Hold
PROBE t117 hitscan
BTN t132 0 wstate 557184 pending none psp 1
PROBE t133 hitscan
STATE t139 RSQWS_Minigun AltHold
STATE t151 RSQWS_Minigun Fire
STATE t178 RSQWS_Minigun Ready
MARK_GRAB
STATE t202 RSQWS_Minigun ? (sprite 933 frame S tics 1)
SPIN t207 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 29 offtrig 1
SPIN t208 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 28 offtrig 1
SPIN t209 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 27 offtrig 1
SPIN t210 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 26 offtrig 1
MARK_FIRE_SPUN
PROBE t227 hitscan
STATE t227 RSQWS_Minigun Hold
BTN t227 1 wstate 557184 pending none psp 1
PROBE t229 hitscan
BTN t252 0 wstate 557184 pending none psp 1
PROBE t253 hitscan
STATE t259 RSQWS_Minigun AltHold
STATE t271 RSQWS_Minigun Fire
STATE t298 RSQWS_Minigun ? (sprite 933 frame S tics 1)
STATE t310 RSQWS_Minigun Fire
MARK_SWIPE
STATE t337 RSQWS_Minigun Ready
STATE t382 RSQWS_Minigun ? (sprite 933 frame S tics 1)
SPIN t392 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 34 offtrig 0
SPIN t393 muzzle 4.6 40.4 23.1 on-barrels 1 spinLeft 34 offtrig 0
SPIN t394 muzzle 4.6 40.4 23.1 on-barrels 0 spinLeft 33 offtrig 0
SPIN t395 muzzle 4.6 40.4 23.1 on-barrels 0 spinLeft 32 offtrig 0
MARK_FIRE_SWIPED
PROBE t404 hitscan
STATE t404 RSQWS_Minigun Hold
BTN t404 1 wstate 557184 pending none psp 1
PROBE t406 hitscan
BTN t429 0 wstate 557184 pending none psp 1
PROBE t430 hitscan
STATE t436 RSQWS_Minigun AltHold
STATE t448 RSQWS_Minigun Fire
STATE t475 RSQWS_Minigun ? (sprite 933 frame S tics 1)
MARK_LINGER_OUT
STATE t523 RSQWS_Minigun Fire
STATE t550 RSQWS_Minigun Ready

## with the Series (ser1): 0 script errors; charge, Knuckles free trigger with RSQ Melee
0
STATE t0 RSQWS_Beretta Select
STATE t14 RSQWS_Beretta Ready
STATE t60 RSQWS_Beretta Deselect
STATE t75 RSQWS_NovaRifle Select
STATE t90 RSQWS_NovaRifle Ready
STATE t132 RSQWS_NovaRifle AltFire
WFX t132 glow spawned RSQWS_ChargeGlowNova
PROBE t145 missile RSQWS_NovaBall
STATE t175 RSQWS_NovaRifle Ready
STATE t198 RSQWS_NovaRifle Deselect
STATE t213 RSQWS_TITAN Select
STATE t228 RSQWS_TITAN Ready
STATE t270 RSQWS_TITAN AltFire
WFX t270 glow spawned RSQWS_ChargeGlowTitan
PROBE t304 missile RSQWS_HyperNova
STATE t349 RSQWS_TITAN Ready
STATE t356 RSQWS_TITAN Deselect
STATE t371 RSQWS_Knuckles DoKick
STATE t386 RSQWS_Knuckles Ready
STATE t418 RSQWS_Knuckles AltFire
STATE t424 RSQWS_Knuckles Ready
