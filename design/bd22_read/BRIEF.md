# BD22 VR Reloaded: whole-code bug read (owner, 2026-11-27 08:12)

The owner's order, his words: "bd22 should ahve bugs aplenty. read the tnriee code. don't miss a fucking thing."

The repo: /home/claude/presidentkoopa/rsq_bd_vr_reloaded (his own weapon set for Brutal Doom on QuestZDoom 17.3 VR:
DECORATE weapons under src/actors/Weapons, ZScript under src/zscript, lumps directly in src/). It is HIS code. Base
Brutal Doom (brutal22test6.pk3) is NOT his and is not in the repo: where his code inherits from, jumps into or replaces
a base class you cannot see, say so and do not guess. `tools/`, `renders/`, `reference/` are not the shipped mod.
You change NOTHING in that repo: no edits, no git command that changes anything, no build. Nothing can be run here.

## Your job
You are one of nine readers; each has a PART (a list of files) given in its own prompt. Read EVERY LINE of every file
in your part with the Read tool, in consecutive chunks, start to end, however long. Do not skim, do not sample, do not
grep in place of reading. Keep a list of the files and line ranges you have read and put it in your report; a file not
read to its last line is reported as such. Read files outside your part whenever you need them to confirm or kill a
suspicion (who calls this, where a cvar is defined, what a state jumps to), by grep and targeted Read.

Look for anything that would go wrong for a player or break the game, for example:
- script errors and aborts: a null used without a check (owner, player, ReadyWeapon, OffhandWeapon, a FindInventory
  result, a service, a CVar.FindCVar result), an array index out of range, a division by zero, a cast that can fail;
- DECORATE / state faults: a Goto or A_Jump to a state that does not exist in that actor or its parents, a state with
  no way out (a loop that holds the weapon forever), a missing Ready / Deselect / Select path, frames that fire twice,
  A_ReFire into the wrong state, ammo taken twice or not at all, an off-hand twin that differs from its main-hand
  weapon where it should not (compare the two side by side: damage, ammo use, timings, sounds, flags), wrong
  AmmoType / AmmoUse / AmmoGive, an inventory token given and never taken (or taken and never given), a MaxAmount that
  clips a counter;
- logic faults: a condition that can never be true or is always true, the wrong hand's data used (main for off or the
  reverse), left-handed play (vr_control_scheme) not handled where the other hand is, a comparison the wrong way round,
  units mixed (tics / seconds, map units / metres, degrees), a value computed and never used, a timer never reset, state
  that survives a map change or a death or a save when it should not (or is lost when it should not be), per-player
  state kept in a static or a single global (netplay: more than one player), consoleplayer used in play code;
- settings: a cvar read that is not defined, defined and never read, defined twice, the wrong type or scope, a menu row
  whose cvar does not exist or whose range disagrees with the code's clamp, a tip that says something the code does not
  do, a default in CVARINFO that differs from the fallback in code;
- keys: an alias that sends an event nothing hears, an event heard that nothing sends, a bind that collides;
- assets named by code that are not in the repo (a sound, sprite, model, texture, class name in a string), and class
  names referred to by string that do not exist (spelling, case);
- two files doing the same job differently; a copy that drifted from its source;
- comments or the README promising something the code does not do (only where a player would be misled);
- performance traps a player would feel in VR on a Quest: a ThinkerIterator, BlockThingsIterator, LineTrace or service
  lookup every tic for every actor, unbounded spawns.
This list is not a limit. If something looks wrong, check it, then write it down.

Before you write a finding: open the line again and confirm it; look for the other place that already handles it (a
guard earlier in the function, a parent state, another file) and say what you checked. Do not present a guess as a
fact: every finding says how sure you are and what would settle it.

After your own read is done (not before), read /home/claude/presidentkoopa/rsq_bd_vr_reloaded/BUGS_FROM_CODE_READ_2026-11-24.md
and mark any of your findings that is already there with its id and the owner's recorded answer. Do not drop it: say
"already known".

## Writing rules (the owner's)
Plain words. Use the names the code and the menus use; invent no names. Lead each finding with what the PLAYER would
see or lose. Nothing is ever "parked": each finding ends as a fix or as "intended". Every claim has a file:line (paths
relative to the repo root).

## Output: one file
Write /home/claude/rsq_ubqseries/design/bd22_read/PART_<n>.md (n and the title are in your prompt). If the Write tool
is refused, write it with Bash (`cat > file <<'EOF'`); if that is refused too, put the whole text at the end of your
final message. Shape:

```
# BD22 VR Reloaded bug read, part <n>: <title> (2026-11-27)
Commit read: <git rev-parse --short HEAD>. Nothing was run. Nothing was changed.
## Files read
| file | lines | read to the end? |
## Findings, worst first
## B<n>.<k>: <what the player sees, one line>
- Kind: crash or abort | wrong behaviour | setting or menu | key | missing asset or class | netplay | performance | drifted copy | misleading text | dead code
- Where: file:line (each place)
- What the code does: ...
- Why it is wrong: ...
- Checked: what else you opened to confirm, and what you could not see
- Sure?: certain | likely | unsure, and what would settle it
- Fix A: ... (size: lines, files)
- Fix B: ... (only if there is a real second way)
- Or intended: what would be true if this is meant
- Already known?: no | yes, <id>, owner said: ...
## Things that looked wrong and are not (so the next reader does not chase them)
## Not read or not checkable
```

Your final message is read by another agent, not the owner: files read with line totals, number of findings by kind,
the five worst in one line each, anything you could not read. If the file could not be written, the whole text follows.
