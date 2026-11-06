// RSQ FlashFlare -- A THROWN FLARE THAT HITS (owner 11-06, BUGS_1.0 item 4: "Thrown flares need to do a little damage, at
// least, and light an enemy on fire if BD is detected, if enemy is below a certain tier (humanoids only?)").
// The owner's answers: humanoids and imps can burn (zombiemen, shotgunners, chaingunners, SS, Brutal Doom / XMVE humans,
// imps and similar small demons); a boosted monster (a LegenDoom legendary, a Champions champion) only below
// "Boosted monsters ignite below N% health" (rsqff_boost_pct, 25) of its normal health.
//
//   THE HIT: HIT_DMG (4) to the monster a flying flare strikes, once per monster per flight (RSQFF_Flare.SpecialMissileHit
//     for FnF's own throw; RSQ Distance Grab's throw already hurts by its own impact and asks FnF to ignite only:
//     RSQFF_Service "flare.hit").
//   THE BURN, BRUTAL DOOM ONLY (found by name: BDWeaponSpawner / BrutalPistol): Brutal Doom's own burning is its damage
//     type "Fire" (BD22 Flamethrower.dec: FlamethrowerProjectileNew "damagetype fire"), so the monster's own Fire pain and
//     burning death are Brutal Doom's. The flare's hit is a Fire hit, and a monster that may burn carries RSQFF_OnFire for
//     BURN_TICS (4 s): BURN_DMG (2) Fire damage every BURN_EVERY (10) tics, flame off its body. Without Brutal Doom: the
//     hit's damage only, no burn.
// No hard reference to Brutal Doom, LegenDoom or Champions: every name is looked up as a String at run time.
class RSQFF_Fire play
{
	const HIT_DMG = 4;
	const BURN_TICS = 140;
	const BURN_EVERY = 10;
	const BURN_DMG = 2;

	static bool Named(String n) { class<Object> c = n; return c != null; }

	// Brutal Doom is loaded
	static bool BrutalDoom() { return Named("BDWeaponSpawner") || Named("BrutalPistol"); }

	static bool Has(Actor t, String n)
	{
		class<Inventory> c = n;
		return c && t.FindInventory(c, true);
	}

	// a LegenDoom legendary (picked or turned) or a Champions champion
	static bool Boosted(Actor t)
	{
		return Has(t, "LDLegendaryMonsterToken") || Has(t, "LDLegendaryMonsterTransformed") || Has(t, "champion_PersistentInfo");
	}

	// THE KINDS THAT BURN: a Doom zombieman, shotgunner, chaingunner, SS or imp by class, parent or what it replaces (Brutal
	// Doom's and XMVE's replacements of them); and, for the humans and small demons of those packs that replace nothing, a
	// walking monster of a zombie's or an imp's build: no wider than 21, no taller than 64, at most 100 health.
	static bool Kind(Actor t)
	{
		static const Name kinds[] = { 'ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'WolfensteinSS', 'DoomImp' };
		class<Actor> c = t.GetClass();
		for (int d = 0; c && d < 8; d++)
		{
			for (class<Object> k = c; k; k = k.GetParentClass())
				for (int i = 0; i < kinds.Size(); i++) { class<Object> kc = kinds[i]; if (kc && k == kc) return true; }
			class<Actor> r = Actor.GetReplacee(c);
			if (!r || r == c) break;
			c = r;
		}
		return !t.bFLOAT && !t.bNOGRAVITY && t.Radius <= 21 && t.Height <= 64 && t.SpawnHealth() <= 100;
	}

	static bool CanBurn(Actor t)
	{
		if (!t || !t.bISMONSTER || t.player || t.Health <= 0 || !t.bSHOOTABLE || !BrutalDoom() || !Kind(t)) return false;
		if (!Boosted(t)) return true;
		double pct = clamp(CVar.FindCVar("rsqff_boost_pct") ? CVar.FindCVar("rsqff_boost_pct").GetInt() : 25, 0, 100);
		return t.Health < max(1, t.SpawnHealth()) * pct / 100.0;
	}

	static bool Debug() { let p = players[consoleplayer]; let c = p ? CVar.GetCVar("rsqff_debug", p) : null; return c && c.GetBool(); }

	// the flare struck t: its little damage (dmg) and, with Brutal Doom, the burn
	static void Hit(Actor flare, Actor t, Actor src, bool dmg, bool burning)
	{
		if (!t || !t.bSHOOTABLE || t.Health <= 0 || t.player) return;
		bool bd = BrutalDoom();
		bool burn = burning && CanBurn(t);
		String tn = t.GetClassName();
		if (dmg) t.DamageMobj(flare, src, HIT_DMG, bd ? 'Fire' : 'None');
		bool dead = !t || t.Health <= 0;
		if (burn && !dead) Ignite(t, src);
		if (Debug()) Console.Printf("RSQFF hit t%d: %s%s%s", level.maptime, tn, dmg ? String.Format(" takes %d", HIT_DMG) : "",
			dead ? ", killed" : burn ? ", set on fire" : (bd ? (burning ? ", does not burn (kind or tier)" : "") : ", no Brutal Doom: no burn"));
	}

	static void Ignite(Actor t, Actor src)
	{
		let f = RSQFF_OnFire(t.FindInventory("RSQFF_OnFire"));
		if (!f)
		{
			t.GiveInventory("RSQFF_OnFire", 1);
			f = RSQFF_OnFire(t.FindInventory("RSQFF_OnFire"));
		}
		if (!f) return;
		f.left = BURN_TICS;
		f.src = src;
	}
}

// ON FIRE: Brutal Doom's Fire damage a few times a second and flame off the body, for its time; out when it ends or the
// monster dies (its burning death is Brutal Doom's own, by the damage type).
class RSQFF_OnFire : Inventory
{
	int left;
	Actor src;
	transient TextureID texFlame;
	transient bool texReady;

	Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE Inventory.MaxAmount 1; }

	override void DoEffect()
	{
		Super.DoEffect();
		let o = Owner;
		if (!o) return;
		if (left <= 0 || o.Health <= 0) { Destroy(); return; }
		left--;
		if (!texReady) { texReady = true; texFlame = TexMan.CheckForTexture("RQFFLAM", TexMan.Type_Any); }
		double r = o.Radius * 0.7;
		for (int i = 0; i < 2; i++)
			o.A_SpawnParticleEx(0xFFFFFF, texFlame, STYLE_Add, SPF_FULLBRIGHT, 10, frandom[RSQFF_Fx](4.0, 7.0), 0,
				frandom[RSQFF_Fx](-r, r), frandom[RSQFF_Fx](-r, r), frandom[RSQFF_Fx](o.Height * 0.2, o.Height * 0.9),
				frandom[RSQFF_Fx](-0.2, 0.2), frandom[RSQFF_Fx](-0.2, 0.2), frandom[RSQFF_Fx](0.4, 0.9), 0, 0, 0.02, 0.95, -1, -0.3);
		if (left % RSQFF_Fire.BURN_EVERY == 0) o.DamageMobj(self, src, RSQFF_Fire.BURN_DMG, 'Fire', DMG_THRUSTLESS);
	}
}
