Colourful Hell Plus -> RSQ Monsters (2026-11-16). Test and build tools, never shipped (build_all.py excludes tools/*).
  idx.py, closure.py   index CHP's / 1.04's DECORATE (unzipped at /tmp/chplus, /tmp/ch104) and walk a boss's references
  conv.py, drive.py    the DECORATE -> ZScript converter and its driver (names, ACS map, stubs) -> gen/*.zs
  place.sh, handfix.py copy gen/ into zscript/monsters/plus with headers, then the reviewed hand edits
  sounds.py            CHP's sounds -> sounds/plus + SNDINFO.plusex (rsplus/ names)
  clash.py             lump-name check against the owner's full order
  zeroloop2.py         looks for zero-tic state cycles
  run1.sh / run4.sh / batch3.sh / bf.sh   rig runs (bf.sh: boss_full.sh with a SKIP filter for bisecting)
  probe6/  the fight probe (RSPX lines): spawn, buddha, face, log states / missiles / hits / deaths, kill after N tics,
           force a state (test harness), census; probe3/ the gates, the roster service and the Big Boss pool (RSPG);
           probe7/ the dormant portraits (RSPP)
