# Grenade rig tests (TEST ONLY, never ships)

`probe/` is a test pk3 source (GRP lines: inventory, damage and kills with their source, the thrown grenade's flight,
the hands and the ring each tic with `grp_trace N`, the scatter counts at map load; net events `grp_mon`, `grp_put`,
`grp_inv`). It names `RSQGN_Geo`, so it loads only after RSQ_Grenade. `plain.txt` is the main console script (ring
pull, swing throw at an imp, pin back in, cook in hand, teeth then a cooked throw), for tools/rig17/run17.sh:

    cd probe && zip -q -r -X /tmp/probe.pk3 . && cd ..
    PK3S="pk3/RSQ_Grenade.pk3 /tmp/probe.pk3" IWAD=doom2.wad tools/rig17/run17.sh gren_plain 200 "$(tr '\n' ' ' < plain.txt)"

Run `rsqgn_debug 1` for the RSQGN lines. Poses are the rig's qz_rhand / qz_lhand (stage metres; pitch 30 = level).
