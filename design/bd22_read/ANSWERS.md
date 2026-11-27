# BD22 VR Reloaded bug read: the owner's answers (2026-11-27)

Nothing in his BD22 repo has been changed yet. Each answer here is to be built there.

| Finding | Answer (his words or his pick) | Built? |
|---|---|---|
| B7.1 grenade pin out across a map change sticks the grenade in the hand | "Pin back in on a new map" (Fix A: Reset right after the state is made, grenade.zs:337-338) | no |
| B7.3 / B3.1 Recoil row does nothing (RSQ_Recoil is in no handler list) | "Recoil stays off, remove the row" (MENUDEF.rsq:132-133, changelog line) | no |
| B8.2 one kick press lands two kicks with a gun in each hand | "Leave it as it is" (intended) | n/a |
| B6.1 / B2.2 eight guns cannot reload with the off hand busy | my question was bad: "WHAT THE FUCK QUESTION IS THIS REASK THIS IN A WAY THAT ISN'T RTARTED". Re-asked. | |
