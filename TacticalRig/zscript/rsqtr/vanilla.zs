// VANILLA DOOM'S GUNS ON THE BODY (owner, 11-04 18:16; BUGS_0.99a item 44): "Assume vanilla Doom has Pistol, Shotgun, SSG,
// Chaingun, RPG, Plasma, BFG. We use the same holstered meshes for vanilla as we do for BD." A stored gun is drawn only
// when RSQTRFIT measures it, wearing the MODELDEF of the class its row names (RSQTR_Icon.Wear: A_ChangeModel). Brutal
// Doom's guns wear BD22 VR's own MODELDEF; with vanilla Doom that is not loaded, so these classes carry the rig's own
// one-frame copies of the same meshes (models/rsqtr/vanilla, MODELDEF.txt's VANILLA blocks, RSQTRFIT's VANILLA rows; all
// written by tools/vanilla_holsters.py). Pistol -> BrutalPistol, Shotgun -> Shot_Gun, SuperShotgun -> SSG, Chaingun ->
// Minigun (brutal22test6's own replacement of it), RocketLauncher -> Rocket_Launcher, PlasmaRifle -> Plasma_Gun, BFG9000 ->
// BIG_FUCKING_GUN, Chainsaw -> Chain_saw. With Brutal Doom loaded the vanilla classes are replaced and never carried, so
// its guns show exactly as before. Nothing spawns these: they are only names A_ChangeModel borrows.
class RSQTR_VanillaHolder : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }
	States { Spawn: RTGN A -1; Stop; }
}
class RSQTR_VH_Pistol : RSQTR_VanillaHolder {}
class RSQTR_VH_Shotgun : RSQTR_VanillaHolder {}
class RSQTR_VH_SuperShotgun : RSQTR_VanillaHolder {}
class RSQTR_VH_Chaingun : RSQTR_VanillaHolder {}
class RSQTR_VH_RocketLauncher : RSQTR_VanillaHolder {}
class RSQTR_VH_PlasmaRifle : RSQTR_VanillaHolder {}
class RSQTR_VH_BFG9000 : RSQTR_VanillaHolder {}
class RSQTR_VH_Chainsaw : RSQTR_VanillaHolder {}
