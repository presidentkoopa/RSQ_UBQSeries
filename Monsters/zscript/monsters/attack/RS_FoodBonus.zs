// RS_FoodBonus, lifted verbatim from RS_Main's zscript/systems/ui/RS_EliteDrop.zs.
// The elite kill payout. Self-contained: its own FRUT sprites, no score or
// token code. The rest of RS_EliteDrop is weapon-side and is not carried.

class RS_FoodBonus : HealthBonus
{
	Default
	{
		+RANDOMIZE
		-COUNTITEM
		Inventory.PickupMessage "$PICKUP_RS_FOOD";
		Tag "$TAG_RS_FOOD";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		bSpriteFlip = random(0, 1);
		frame = random(0, 7);
	}

	States
	{
	Spawn:
		// '#' holds whatever frame PostBeginPlay picked -- the state does
		// not advance it, which is what keeps each item on its own food.
		FRUT "#" 35;
		FRUT "#" 1 Bright;
		Loop;
	}
}
