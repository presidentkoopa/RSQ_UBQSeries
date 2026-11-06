/* Part of Graveyard. GPLv3, see copying.txt.
 *
 * Boss marker: the testfig terminal, standing where something big died.
 *
 * Two classes, identical except for world size. Both draw the SAME full
 * resolution frames -- only the TEXTURES scale differs -- so the small one is
 * supersampled rather than downsampled. Shrinking the pixels instead would
 * throw away the 1px grid and the readout text, which is most of what the
 * asset is.
 *
 *   gy_BossSmall   45 x 40 map units, grave-marker sized
 *   gy_BossBig    161 x 143 map units, a monolith you walk up to
 *
 * Summon either to compare:  summon gy_BossSmall  /  summon gy_BossBig
 *
 * 22 frames at 4 tics is 2.5s a loop; the GIF runs 0.1s a frame (2.2s), so it
 * is a shade slow. Doom tics cannot express 3.5 evenly.
 */

class gy_BossMarker : Actor
{
  Default
  {
    Radius 16;
    Height 40;
    Gravity 1000;
    +NOBLOCKMAP
    +DONTSPLASH
    +BRIGHT
  }

  void setObituary(String obituary) { _obituary = obituary; }

  override bool Used(Actor user)
  {
    Console.Printf("%s", _obituary);
    return Super.Used(user);
  }

  protected String _obituary;
}

class gy_BossSmall : gy_BossMarker
{
  States { Spawn: gy_b abcdefghijklmnopqrstuv 4; Loop; }
}

class gy_BossBig : gy_BossMarker
{
  Default
  {
    Radius 32;
    Height 143;
  }
  States { Spawn: gy_k abcdefghijklmnopqrstuv 4; Loop; }
}
