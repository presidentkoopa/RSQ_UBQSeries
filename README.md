# RSQ_Miniboss (UBQ / RSQ suite)

The owner's set-piece miniboss, rebuilt from the abandoned minibosses.pk3 (kept unmodified in `original/`; the owner, 10-27: "Miniboss was abandoned so its ours. We can rebuild and optimize the hell out of it and integrate whatever we want."). Credit the original: **Minibosses! v0.1.1 by Tartlman** (ZDoom forum, Nov 2019; "All code by me. Special thanks to the Hideous Destructor server"), on hiatus since 2019. Its effects use Doom 2 IWAD sprites as placeholders. Tartlman's own to-do list included "special legendoom compatibility" -- which this rebuild delivers.

## The design (owner, 10-27)
- A miniboss is fed by THRALLS (three, by default): boosted legendary champions (Champions + LegenDoom Lite), joined to it by trails. It INHERITS the powers of all its thralls.
- Killing a thrall SLOWS TIME (RSQ_SlowMo): a window to damage the miniboss -- or to kill another thrall, which keeps the slow time going.
- Clear the thralls, then fight the miniboss.
- Greedy play: attack the miniboss directly and you probably won't kill it before the slow-down runs out; then ALL monsters get double aggression and speed until the miniboss dies.
- The original's mechanics to keep and optimise: miniboss lives (default 3), living thralls cut the miniboss's damage taken, losing a life gives a short invulnerability, dead thralls revive when it ends.
- Later: this is where RS Monsters' EX tier is reached (EX is not tier-locked).
