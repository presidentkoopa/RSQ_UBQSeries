# RSQ Whip: code that does nothing today, and what it could be

Owner 2026-11-10 12:53, on the code read: "But that dead code seems like a feature i want?" None of this is deleted. For
each piece: what the player would get if it worked, and what it would take. Read from the code (Whip/zscript/rsqwp/),
nothing here is shown. The owner picks; nothing is built without his yes.

## 1. Fly: a hook you throw (core.zs Fly, PH_FLY; the recall in Press)

**What the player would get.** A real grappling throw from the whip hand: press, and the line flies straight out along
the hand (40 map units a tic, up to 1024 units, about 30 m). It latches on ANY wall, floor or ceiling it meets, not only
an edge above the hand (today's Catch Edges) or the aimed-swing spot, and you swing or reel from it. If it meets a
monster it bites: a light one is pulled along the floor to you, a heavy one (or a boss) becomes an anchor you swing to.
A second press while it is still flying calls it back. This is RSQ Grapple's hook, inside the whip.

**Why it does nothing.** Nothing ever makes a hook in PH_FLY: core.zs Fire starts the whip instead of a claw, and
every hook the whip builds is already latched (whip.zs Snag, swing.zs SwingLatch) or bitten (whip.zs Leash).

**What it would take.**
- An input. The keybind rule (design/KEYBINDS_PLAN.md) allows no key for what attack / alt attack can do, so it needs
  a gesture or a free button on the whip weapon (both of the weapon's buttons are taken: trigger marks / reels,
  alt-fire moves the mark / lets go).
- A Fire that spawns a hook in PH_FLY (the code after that, Fly / Latch / Bite, is there and is Grapple's).
- A look: the claw sprites (RSGH, RSGK) are not in the pk3 and RSQWP_Looks.Sprite answers TNT1, and DrawRope makes
  the claw invisible; there is no flight sound.
- A decision on the overlap: RSQ Grapple is this mod already, and both load together.

## 2. The PH_HOLD yank: a zip instead of a swing (core.zs Latch 313-327; checked at Press 66, WorldTick 210, Comfort 229)

**What the player would get.** jpalomo's grapple feel: the moment the rope latches you are THROWN at the anchor once
(sideways by the distance / 12, up by the height / 16, capped at Top Speed), the line stays shut 16 tics and then
comes back. A zip, not a pendulum. It would apply to every latch: a snag, an aimed swing (and Fly's claw if built).

**Why it does nothing.** It runs only when `rsqwp_geo_mode` is 1, and that cvar is not defined anywhere.

**What it would take.** A row (for example "Rope: Swing / Zip") with a defined cvar; a look at what a zip means for
the aimed swing's ground start, the mantle and chain swings, which all assume a pendulum; RSQ Score pays nothing for
it today (its rope rows read "swinging", which only a latched rope answers).

## 3. PlaceChain: a chain rope (hook.zs 245-292, `if (true)` at 216)

**What the player would get.** The rope after a snag drawn as a chain of small links (jpalomo's look: 5-unit links
every 5 units from 15 units out of the hand, at most 160 links, none drawn within 15 units of your eye) instead of
today's leather tube.

**Why it does nothing.** DrawRope always takes the tube branch (`if (true)`). The two numbers it reads,
`rsqwp_chain_links` and `rsqwp_chain_scale`, are not defined. Its link actor (RSQWP_Link) draws TNT1: the link sprite
(jp_grapple's tenda0) is not in the pk3.

**What it would take.** A link sprite in the pk3 (with credit), a row in place of `if (true)` (and the old
`rsqwp_rope_style` cvar defined, or a constant), the two numbers defined or made constants. For a whip the rope IS the
thong, so a chain look may read wrong; it suits a "chain whip" variant better.

## 4. RSQWP_Perks: rope upgrades (fx.zs 29-36, all stubs)

**What the player would get.** RSQ Grapple's Gun Bonsai VR rope nodes on the whip's rope. Grapple's own versions:
- `Factor('reel')`: Fast Reel, a faster reel (the slot-1 whip's reel reads it today, so this one would work at once).
- `SteadyDrag`: Steady Line, the swing settles faster while you leave the stick alone (a pump still pumps; read by the
  live swing today).
- `OnLetGo`: Slingshot (let go of a swing in the air and it carries you further) and Barbed Claw's tear (read on every
  let-go today).
- `Factor('mass')`, `OnBite`, `OnArrive`, `Bowl`: Heavy Haul, Barbed Claw's bite, Get Over Here / Scorpion, Bowling.
  These only run for a monster on the core's line, which only the bind whip's Leash makes (see 6).

**Why it does nothing.** Every one returns 1 or 0 or does nothing; the whip's Gun Bonsai VR tree (up_whip.zs) has no
such nodes.

**What it would take.** New nodes on the whip tree in Gun Bonsai VR (Rope already has Snag, Mantle, Momentum, Tarzan),
and these stubs reading their levels as RSQWP_Whip.Gb does. Fast Reel, Steady Line and Slingshot need nothing else;
the other four need the leash back first.

## 5. Bitten (service.zs 99, empty)

**What the player would get.** Nothing directly: it is the ledger entry other mods read. Filled, the whip would
answer "hooked", "hooked.by", "hooked.heavy" (as RSQ Grapple does), so RSQ Score's hook rows (Boarding Party, Fly Ball
and the like) could pay for monsters the whip's line caught.

**Why it does nothing.** It is empty, and it is called only from Fly (never runs) and Leash (the bind whip only).

**What it would take.** Fly or the leash working first; then the same few lines as Grapple's service. Note: the
whip's VisualRewards marker service already answers a request named "hooked" for its whipped marker (whip.zs), so a
new answer must not clash with it.

## 6. The bind whip: Whip (Main) / Whip (Off), with Whip Style, Lock and Leash

**What the player would get.** A whip out of either hand WITHOUT selecting slot 1: a gun in the main hand and the whip
in the off hand at the same time. With it, the three rows that went from the menu on 11-10:
- **Whip Style: Assist** (`rsqwp_whip_mode` 1): a press throws a lash for you, over the shoulder and down, to the
  monster nearest where the hand points (within 15 degrees, about 4 m), and it cracks there.
- **Whip Aim: Lock** (`rsqwp_whip_aim` 2): hold the whip hand's alt-fire and point the OTHER hand; the nearest thing
  within 7 degrees is locked (the diamond) for a second; the next crack flies to it.
- **Leash** (`rsqwp_whip_leash`): a locked or Assist crack on a monster, with the bind still held, catches it on a line
  and it slides to you along the floor (10 a tic, stopping 16 short); over mass 1000, a boss or a Can't Be Yanked
  miniboss, it is an anchor you swing from instead. This is what feeds 4's Heavy Haul, Get Over Here and Bowling.

**Why it does nothing.** Its keys went on 11-10 (design/KEYBINDS_PLAN.md: the whip is attack and alt attack). The
console events are still handled (`event rsqwp_press 0` / `event rsqwp_release 0`; from the code, not tried), but no
key or alias sends them. The cvars
are kept (no menu rows) because this code still reads them.

**What it would take.** This is close to the planned "Whip and pistol, Indiana Jones" (design/PLANNED_PROJECTS.md,
owner 11-10 12:27 / 12:30, "maybe a gbovr upgrade"): the whip in one hand and a gun in the other, the whip hand's own
ray as the snag cursor while its trigger is up. The bind whip already runs a whip beside a gun; what it lacks is an
input that is not a key (for example the whip coming out when the off hand is empty and the gun hand holds a pistol,
or a Gun Bonsai VR node), and its Lock aim uses the other hand, which the pistol would have. The owner said he likes
the slot-1 whip as it is (11-10), so this would be a second way to carry it, not a change to the first.
