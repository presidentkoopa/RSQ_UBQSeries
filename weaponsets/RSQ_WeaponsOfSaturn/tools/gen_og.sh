#!/bin/sh
# Regenerate src/zscript/wos/og_actors.gen.zs from Weapons of Saturn's DECORATE (the non-weapon actors).
# No monsters (SPEC): ZOMBIEGUY.txt and the zombie-only actors are not converted.
# usage: tools/gen_og.sh <unpacked weapons_of_saturn ACTORS dir>
A=${1:-/home/claude/src/saturn/ACTORS}
HERE=$(cd "$(dirname "$0")" && pwd)
SKIP="Knuckles,Motorsaw,Beretta,1911,MP40,MachineRifle,Riotgun,Coachgun,Minigun,SaturnV,NovaRifle,TITAN,ZombieGuy,Toggle,DuelWield,AltfireToken1,AltfireToken2,ZoomIn,Aiming,Laserdot,ShotgunReloading,ChamberLoading,FirstSix,LastSix,Switch,GrenadeTimer,SaturnG,ZombieAmmoSpawner,ZombieFullAuto"
cd "$A" && python3 "$HERE/dec2zs.py" "$HERE/../src/zscript/wos/og_actors.gen.zs" PLAYER.txt AMMUNITION.txt ITEMS.txt EFFECTS.txt KNUCKLES.txt CHAINSAW.txt PISTOL.txt 1911.txt MP40.txt MACHINERIFLE.txt RIOTGUN.txt COACHGUN.txt MINIGUN.txt SATURNV.txt NOVARIFLE.txt TITAN.txt --skip "$SKIP" --prefix RSQWS_
