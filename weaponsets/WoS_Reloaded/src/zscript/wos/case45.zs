// The 1911's brass (owner: "Ballistics 45 casing model"): RS Ballistics' casing_45.md3, lent to the 1911's casings as
// BD22 VR lends its other real casings (rsq/casemodels.zs). A mount point only: it draws nothing of its own.
class RSQ_Case45 : Actor
{
	Default { +NOINTERACTION; +NOBLOCKMAP; RenderStyle "None"; }
	States { Spawn: TNT1 A -1; Stop; }
}
