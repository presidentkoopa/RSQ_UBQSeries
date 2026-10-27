// WHAT THE SCREENS SHOW (10-27): one read of Gun Bonsai's stats, the hands' ammo and RS Score's
// numbers, made fresh each frame in ui scope. Everything here is a read; nothing writes the playsim.
// The skins draw from this and nothing else, so B and C can never disagree with A about a number.

// One hand: its gun's Gun Bonsai info and its ammo.
class RSQUI_Hand ui
{
	bool valid;              // a gun with a Gun Bonsai info
	int hand;                // 0 main, 1 off
	TFLV_WeaponInfo info;
	Weapon wpn;
	String tag;              // the gun's own tag
	int lvl;
	double xp, xpmax;
	bool ready;              // a level-up is waiting (XP >= max)
	bool ignored;            // Gun Bonsai ignores this weapon (no levels)
	TFLV_Upgrade_UpgradeBag bag;

	// ammo: reserve and magazine, -1 when that counter does not apply
	int reserve, mag;
	TextureID ammoIcon;

	void Read(TFLV_PerPlayerStats st, int which)
	{
		hand = which;
		valid = false; info = null; bag = null; wpn = null;
		reserve = -1; mag = -1; ammoIcon.SetInvalid();
		let p = players[consoleplayer];
		wpn = which == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		if (wpn) ReadAmmo();
		if (!st || !wpn) return;
		info = st.GetInfoForHand(which);
		if (!info || !info.wpn) return;
		valid = true;
		tag = info.wpn.GetTag();
		lvl = info.level;
		xp = floor(info.XP);
		xpmax = max(1.0, info.maxXP);
		ignored = info.IsIgnored();
		ready = !ignored && info.XP >= info.maxXP;
		bag = info.upgrades;
	}

	// Which counter is the magazine is the weapon's business: Brutal Doom's guns keep the round in
	// the chamber count as Ammo1 and the pouch as Ammo2, Doom's keep one pool as Ammo1. The rule
	// that holds for both: with two pools the smaller one (by MaxAmount) is the magazine.
	void ReadAmmo()
	{
		Inventory a1 = wpn.Ammo1, a2 = wpn.Ammo2;
		if (a1 && a2 && a1 != a2)
		{
			Inventory m = a1.MaxAmount <= a2.MaxAmount ? a1 : a2;
			Inventory r = m == a1 ? a2 : a1;
			mag = m.Amount; reserve = r.Amount;
			ammoIcon = r.Icon.IsValid() ? r.Icon : m.Icon;
		}
		else if (a1)
		{
			reserve = a1.Amount;
			ammoIcon = a1.Icon;
		}
		else if (a2)
		{
			reserve = a2.Amount;
			ammoIcon = a2.Icon;
		}
	}
}

class RSQUI_Data ui
{
	TFLV_PerPlayerStats stats;
	RSQUI_Hand hands[2];
	int plvl, pxp, pmax;
	bool pready;
	TFLV_Upgrade_UpgradeBag pbag;

	// RS Score (absent = no score line)
	bool haveScore;
	int score, progress, lives, rewards;

	int health, armor;
	TextureID armorIcon;

	static RSQUI_Data Make()
	{
		let d = new("RSQUI_Data");
		d.hands[0] = new("RSQUI_Hand");
		d.hands[1] = new("RSQUI_Hand");
		return d;
	}

	bool Read()
	{
		stats = TFLV_EventHandler.GetConsolePlayerStats();
		hands[0].Read(stats, 0);
		hands[1].Read(stats, 1);
		if (stats)
		{
			plvl = stats.level;
			pxp = stats.XP;
			pmax = max(1, bonsai_gun_levels_per_player_level);
			pready = pxp >= pmax;
			pbag = stats.upgrades;
		}
		ReadScore();
		let mo = players[consoleplayer].mo;
		health = mo ? mo.health : 0;
		armor = 0;
		armorIcon.SetInvalid();
		if (mo)
		{
			let ba = BasicArmor(mo.FindInventory("BasicArmor"));
			if (ba) { armor = ba.Amount; armorIcon = ba.Icon; }
		}
		return stats != null;
	}

	// RS Score's service, looked up once (and again now and then while it is missing)
	Service scoreSvc;
	int scoreLook;

	void ReadScore()
	{
		haveScore = false;
		if (!scoreSvc && scoreLook-- <= 0)
		{
			scoreLook = 70;
			let it = ServiceIterator.Find("RS_ScoreService");
			scoreSvc = it ? it.Next() : null;
		}
		if (!scoreSvc) return;
		let mo = players[consoleplayer].mo;
		score = scoreSvc.GetIntUI("score", "", 0, 0, mo);
		if (score < 0) return;
		haveScore = true;
		progress = scoreSvc.GetIntUI("progress", "", 0, 0, mo);
		lives = scoreSvc.GetIntUI("lives", "", 0, 0, mo);
		rewards = scoreSvc.GetIntUI("rewards", "", 0, 0, mo);
	}

	static bool ScoreServiceLoaded()
	{
		let it = ServiceIterator.Find("RS_ScoreService");
		return it && it.Next();
	}
}
