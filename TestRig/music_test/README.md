# Music test (TEST ONLY, never ships)

The Bossfight music outline (owner 11-09: the miniboss fight changes to his track; when it's over the regular music
crossfades back in). Track: the owner's "20 organic beat" (OGG, 2:36, stereo 44.1 kHz).

- The original fades out over its last 8 s and has no loop point. `RSQMUS1.ogg` is cut at 2:02.97 (sample 5422827, the
  best match for its opening), with its last 0.5 s crossfaded into its first 0.5 s, and tagged `LOOP_START=22050`
  `LOOP_END=5422827`: it plays from the top once, then loops from 0.5 s with no gap.
- `seam_preview.wav`: 8 s before the loop point, then 8 s after it. Listen for the join.
- `RSQMusTest.pk3` (load it last): `netevent rsqmus_on` fades the level music to silent (it keeps playing underneath)
  while the track fades in as a looping sound; `netevent rsqmus_off` fades the track out and the level music back in
  where it has got to by then (QuestZDoom can't pause or seek music from a mod). `rsqmus_fade` = crossfade tics (70).
- Rig 11-09 (no audio on the rig): loads with no errors; the track starts on its own channel, crossfades in and out.
  Not yet heard.
- Cost: held as a sound, the 2-minute stereo track is about 22 MB of memory once decoded.
