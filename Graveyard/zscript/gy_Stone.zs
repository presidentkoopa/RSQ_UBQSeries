/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020
 *
 * This file is a part of Graveyards.
 *
 * Graveyards is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Graveyards is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Graveyards.  If not, see <https://www.gnu.org/licenses/>.
 *
 * --- Modified by presidentkoopa for the RSQ Edition, 2026 (GPLv3 too): pop-in, idle bounce, a culled grave light,
 * gold stones, Living Stones, RSQ Miniboss's heartbeat, and the look read the same on every machine (netplay). ---
 */

class gy_Stone : Actor
{

  Default
  {
    Radius 16;
    Height 1;
    Gravity 1000;
  }

  void setObituary(String obituary)
  {
    _obituary = obituary;
  }

  // RSQ Edition (2026-11-06, owner 19:59): kind 2 = an RSQ Score life spent: the same stone tinted gold (TRNSLATE
  // gy_gold), its light gold, steadier (a third of the flicker) and slightly larger (x1.25). Kind 1 is the stone as it was.
  void setKind(int kind)
  {
    _kind = kind;
    _tintNow = -1;
    _lastRadius = -1;
  }

  override
  void PostBeginPlay()
  {
    Super.PostBeginPlay();

    _spawnTime  = level.time;
    _lastRadius = -1;

    // Per-stone phase, derived from position instead of random(): every client
    // spawns these from the same net event, so a positional seed keeps them
    // identical everywhere without touching the play RNG.
    int seed     = abs(int(pos.x * 3 + pos.y * 7 + pos.z * 11));
    _phaseOffset = seed % 360;

    // A whole graveyard restores on one tic at map load, so scatter the pops
    // over ~1s. A grave from a live death (well past load) pops instantly.
    _popinDelay = (level.time < 35) ? (seed % 35) : 0;

    readConfig();

    if (_cfgAnim && _cfgPopin)
    {
      _base   = MIN_SCALE;
      scale.x = MIN_SCALE;
      scale.y = MIN_SCALE;
    }
    else
    {
      _base = 1.0;
    }
  }

  override
  void Tick()
  {
    Super.Tick();

    // Cvars are re-read on a stagger rather than every tic: 50 graves x 11
    // lookups x 35Hz is a lot of hashing for settings that change by hand.
    if (--_cfgTimer <= 0) { readConfig(); }

    if (_cfgAnim)
    {
      animate();
    }
    else if (scale.x != 1.0 || scale.y != 1.0)
    {
      _base   = 1.0;
      scale.x = 1.0;
      scale.y = 1.0;
    }

    updateLight();
    updateTint();
    bBright = pulseEnv() > 0.35;   // RSQ Edition: the stone itself lights on RSQ Miniboss's beat (seen past the light's cull)
  }

  override
  bool Used(Actor user)
  {
    Console.Printf("%s", _obituary);
    return Super.Used(user);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  // ---- pop-in, then a slow idle squash & stretch ----
  private
  void animate()
  {
    int age = level.time - _spawnTime;

    if (_cfgPopin)
    {
      if (age < _popinDelay)
      {
        // waiting its turn - stay tiny so the pop reads cleanly when it fires
        _base   = MIN_SCALE;
        scale.x = MIN_SCALE;
        scale.y = MIN_SCALE;
        return;
      }

      int popAge = age - _popinDelay; // time since THIS stone's pop began
      if (popAge < POPIN_TICS)
      {
        double t         = popAge / POPIN_TICS;
        double settle    = 1.0 - (1.0 - t) * (1.0 - t);            // ease-out
        double overshoot = 1.0 + 0.35 * sin(t * 180.0) * (1.0 - t); // bounce past 1, decaying
        _base = settle * overshoot;
      }
      else
      {
        _base = 1.0;
      }
    }
    else
    {
      _base = 1.0;
    }

    // gy_bounce_speed is degrees per tic, so the default 1.5 is a ~7 second
    // breath - slow enough to read as "alive", not as a wobble.
    double squash = _cfgAmount * sin((level.time + _phaseOffset) * _cfgSpeed);

    scale.x = _base * (1.0 - squash);
    scale.y = _base * (1.0 + squash);
  }

  // ---- Heavily culled grave light, with a smooth fade in/out ----
  // The light only exists inside the cull distance, but instead of snapping on
  // at the boundary it ramps a 0..1 level up (in range) or down (out), and the
  // attached radius tracks it. The light actor is only removed once the fade
  // hits 0, so crossing the cull edge reads as a candle brightening or dimming.
  private
  void updateLight()
  {
    bool inRange = _cfgLight && (nearestPlayerDist(true) <= _cfgCull);

    double target = inRange ? 1.0 : 0.0;
    if      (_lightFade < target) { _lightFade = min(target, _lightFade + FADE_STEP); }
    else if (_lightFade > target) { _lightFade = max(target, _lightFade - FADE_STEP); }

    if (_lightFade <= 0.0)
    {
      if (_hasLight)
      {
        A_RemoveLight('gy_grave_light');
        _hasLight   = false;
        _lastRadius = -1;
      }
      return;
    }

    double env = pulseEnv();
    int radius = int(_cfgRadius * (_kind == 2 ? GOLD_RADIUS : 1.0) * _lightFade * flicker() * (1.0 + PULSE_GROW * env));
    if (radius < 1) { radius = 1; }

    Color lc = lightColor();
    if (env > 0)
    {
      // the beat leans the candle to the heartbeat's colour, at full brightness on the beat
      double w = PULSE_MIX * env;
      lc = Color(255, int(lc.r + (_pulseCol.r - lc.r) * w), int(lc.g + (_pulseCol.g - lc.g) * w), int(lc.b + (_pulseCol.b - lc.b) * w));
    }
    // Re-attaching the same light id overwrites it, which is how the fade
    // animates - but skip the call on tics where nothing actually moved.
    if (_hasLight && radius == _lastRadius && lc == _lastColor) { return; }
    _lastColor = lc;

    A_AttachLight( 'gy_grave_light'
                 , DynamicLight.PointLight
                 , lc
                 , radius
                 , 0
                 , DynamicLight.LF_ATTENUATE
                 , (0, 0, 24)
                 );

    _hasLight   = true;
    _lastRadius = radius;
  }

  // ---- RSQ Edition (owner 2026-11-06): RSQ MINIBOSS'S HEARTBEAT --------------------------------------------------------
  // While a miniboss fight waits to be called in, RSQ Miniboss beats RSQ Glow In The Dark's map glow red (lub-dub, every 45 tics)
  // and asks gy_RSQService "stones.pulse" on each beat with the same colour and length: every stone's candle swells (radius up
  // to x1.6) and leans to that colour (85% at the beat), fading over the beat's length, as the map's glow does. RSQ
  // Accessibility's Photosensitive Mode: no beat; the candle holds a steady half lean while the beats keep coming.
  static int PulseAll(int rgb, double secs)
  {
    int n = 0;
    let it = ThinkerIterator.Create("gy_Stone");
    gy_Stone s;
    while (s = gy_Stone(it.Next())) { s.pulse(rgb, secs); n++; }
    let dc = CVar.FindCVar("gy_bones_debug");
    if (dc && dc.GetInt() != 0) { Console.Printf("RSQ Graveyard t%d: miniboss heartbeat %06x %.2f s: %d stone%s pulse%s", level.maptime, rgb & 0xFFFFFF, secs, n, n == 1 ? "" : "s", photoSafe() ? " (Photosensitive Mode: held steady)" : ""); }
    return n;
  }

  void pulse(int rgb, double secs)
  {
    _pulseCol = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
    _pulseAt  = level.time;
    _pulseLen = max(1, int((secs > 0 ? secs : 0.25) * 35));
  }

  private
  double pulseEnv() const
  {
    if (_pulseLen <= 0) { return 0.0; }
    int age = level.time - _pulseAt;
    if (photoSafe()) { return (age >= 0 && age < PULSE_HOLD) ? 0.5 : 0.0; }
    if (age < 0 || age >= _pulseLen) { return 0.0; }
    double t = 1.0 - double(age) / _pulseLen;
    return t * t;
  }

  // Two out-of-step sines instead of random(): a candle wobble rather than
  // white noise, and no RNG draws on any tic.
  private
  double flicker() const
  {
    if (!_cfgFlicker) { return 1.0; }

    double t = level.time + _phaseOffset;
    double amp = (_kind == 2) ? 0.08 * GOLD_FLICKER : 0.08;
    return 1.0 + amp * (0.6 * sin(t * 13.0) + 0.4 * sin(t * 29.0 + 47.0));
  }

  private
  Color lightColor() const
  {
    int b = clamp(_cfgBright, 0, 255);
    if (_cfgLiving)
    {
      Vector3 c = livingRgb();
      return Color(255, int(c.x * b / 255.0), int(c.y * b / 255.0), int(c.z * b / 255.0));
    }
    if (_kind == 2) { return Color(255, b, int(b * 0.80), int(b * 0.15)); } // RSQ Edition: gold
    return Color(255, b, int(b * 0.72), int(b * 0.42)); // warm candle tone
  }

  // ---- RSQ Edition (owner 2026-11-06 20:06): LIVING STONES (gy_living, off) -------------------------------------------
  // Each stone's light colour and its tint breathe like RSQ Score's "Score:" label (its hud.zs LabelColor, copied here so
  // nothing depends on Score being loaded): pulse = 0.5 + 0.5 * sin(ms * 0.18 deg), one breath every 2 s, from calm blue
  // (110,170,230) to warm (250,240,140). A gold stone (an RSQ Score life spent) breathes inside its own gold range, deep
  // (200,135,25) to bright (255,230,110), so the two kinds stay apart. "Living Stones Mode" (gy_living_mode): Uniform,
  // every stone together; Wave, a sequence across the stones by their distance from you (a breath per 512 map units);
  // Chaos, each stone its own pace (0.55x to 1.6x) and starting point (Score's per-letter hash, seeded by the stone's
  // place). RSQ Accessibility's Photosensitive Mode (rsqa_photosafe, by name): held still at the breath's middle. The
  // light stays the one candle light (only its colour changes); the tint is one of 8 steps per kind (trnslate.txt
  // gy_lb0..7 / gy_lg0..7), set only when the step changes.
  private
  double livingPulse() const
  {
    if (photoSafe()) { return 0.5; }
    double ms    = level.time * (1000.0 / 35.0);
    double phase = 0.0;
    double rate  = 1.0;
    if (_cfgLivingMode == 1)
    {
      double d = nearestPlayerDist(false);
      if (d < BIG) { phase = -d * (360.0 / 512.0); }
    }
    else if (_cfgLivingMode == 2)
    {
      int idx = abs(int(pos.x * 3 + pos.y * 7 + pos.z * 11)) % 1000;
      double v1 = sin(idx * 78.233 + 12.9898) * 43758.5453, v2 = sin(idx * 39.346 + 11.135) * 24634.6345;
      rate  = 0.55 + 1.05 * (v1 - floor(v1));
      phase = 360.0 * (v2 - floor(v2));
    }
    return 0.5 + 0.5 * sin(ms * 0.18 * rate + phase);
  }

  private
  Vector3 livingRgb() const
  {
    double p = livingPulse();
    if (_kind == 2) { return (200 + 55 * p, 135 + 95 * p, 25 + 85 * p); }
    return (110 + 140 * p, 170 + 70 * p, 230 - 90 * p);
  }

  static
  bool photoSafe()
  {
    Name an = "RSQA_Menu";
    class<Object> ac = an;
    if (!ac) { return false; }
    let c = CVar.FindCVar("rsqa_photosafe");
    return c != NULL && c.GetInt() != 0;
  }

  private
  void updateTint()
  {
    int want = 0;                                        // 0 none, 1 gold, 10..17 living blue, 20..27 living gold
    if (_cfgLiving) { want = (_kind == 2 ? 20 : 10) + clamp(int(livingPulse() * 8), 0, 7); }
    else if (_kind == 2) { want = 1; }
    if (_cfgLiving && intCvar("gy_living_debug", 0) != 0 && (level.time % 10) == 0)
    {
      Color lc = lightColor();
      Console.Printf("RSQ Graveyard: living stone kind %d mode %d t%d pulse %.2f tint step %d light %d %d %d",
        _kind == 2 ? 2 : 1, _cfgLivingMode, level.time, livingPulse(), want % 10, lc.r, lc.g, lc.b);
    }
    if (want == _tintNow) { return; }
    _tintNow = want;
    if (want == 0)      { Translation = Default.Translation; }
    else if (want == 1) { A_SetTranslation('gy_gold'); }
    else                { A_SetTranslation(String.Format("gy_l%s%d", want >= 20 ? "g" : "b", want % 10)); }
  }

  private
  void readConfig()
  {
    _cfgAnim    = boolCvar ("gy_anim_enabled" , true);
    _cfgPopin   = boolCvar ("gy_popin_enabled", true);
    _cfgAmount  = floatCvar("gy_bounce_amount", 0.05);
    _cfgSpeed   = floatCvar("gy_bounce_speed" , 1.5);
    _cfgLight   = boolCvar ("gy_light_enabled", true);
    _cfgFlicker = boolCvar ("gy_light_flicker", true);
    _cfgRadius  = intCvar  ("gy_light_radius" , 72);
    _cfgBright  = intCvar  ("gy_light_bright" , 210);
    _cfgCull    = intCvar  ("gy_light_cull"   , 640);
    _cfgLiving     = boolCvar("gy_living", false);
    _cfgLivingMode = intCvar ("gy_living_mode", 0);

    // stagger the next refresh so the graves don't all re-read on one tic
    _cfgTimer = 17 + (_phaseOffset % 13);
  }

  // RSQ Edition (2026-11-10), NETPLAY: the scale, tint, brightness and light set here are play state, saved with the
  // game, so they must come out the same on every machine. They used to follow each machine's own player (his settings,
  // his distance), which differs from machine to machine. Now every machine reads one player's settings, the
  // arbitrator's (user cvars travel in his userinfo, so every machine sees the same values), and the candle and Wave
  // mode go by the nearest player in the game. Alone, that is you, as before; in a netgame the host's look applies to all.
  static
  int lookPlayer()
  {
    if (Net_Arbitrator >= 0 && Net_Arbitrator < MAXPLAYERS && playeringame[Net_Arbitrator]) { return Net_Arbitrator; }
    for (int i = 0; i < MAXPLAYERS; i++) { if (playeringame[i]) { return i; } }
    return 0;
  }

  // the distance to the nearest player in the game (3D or across the map), BIG when there is none
  private
  double nearestPlayerDist(bool in3D) const
  {
    double best = BIG;
    for (int i = 0; i < MAXPLAYERS; i++)
    {
      if (!playeringame[i] || players[i].mo == NULL) { continue; }
      double d = in3D ? Distance3D(players[i].mo) : Distance2D(players[i].mo);
      if (d < best) { best = d; }
    }
    return best;
  }

  // Every cvar read goes through these: GetCVar returns NULL for a cvar that
  // isn't registered (older install, cvarinfo overridden by another pk3), and
  // calling GetFloat() on that NULL is a VM abort.
  private
  bool boolCvar(String name, bool defaultValue) const
  {
    let c = CVar.GetCVar(name, players[lookPlayer()]);
    return (c != NULL) ? c.GetBool() : defaultValue;
  }

  private
  double floatCvar(String name, double defaultValue) const
  {
    let c = CVar.GetCVar(name, players[lookPlayer()]);
    return (c != NULL) ? c.GetFloat() : defaultValue;
  }

  private
  int intCvar(String name, int defaultValue) const
  {
    let c = CVar.GetCVar(name, players[lookPlayer()]);
    return (c != NULL) ? c.GetInt() : defaultValue;
  }

  const POPIN_TICS = 24.0;
  const MIN_SCALE  = 0.05;
  const BIG        = 1e9;
  const FADE_STEP  = 0.05; // 20 tics (0.57 s) from dark to full

  const PULSE_GROW = 0.6;
  const PULSE_MIX  = 0.85;
  const PULSE_HOLD = 60;     // Photosensitive Mode: tics the steady lean lasts after a beat (the beats come every 45)
  private Color  _pulseCol;
  private int    _pulseAt;
  private int    _pulseLen;

  private String _obituary;
  private int    _kind;      // RSQ Edition: 0/1 a death, 2 a Score life spent (gold)
  private int    _tintNow;   // the tint set (updateTint); -1 none chosen yet
  private Color  _lastColor;
  private bool   _cfgLiving;
  private int    _cfgLivingMode;
  const GOLD_RADIUS  = 1.25;
  const GOLD_FLICKER = 0.33;

  private int    _spawnTime;
  private int    _phaseOffset;
  private int    _popinDelay;
  private double _base;

  private bool   _hasLight;
  private double _lightFade;  // 0..1, smooth in/out so the cull edge never pops
  private int    _lastRadius; // last radius actually attached, -1 for none

  private int    _cfgTimer;
  private bool   _cfgAnim;
  private bool   _cfgPopin;
  private double _cfgAmount;
  private double _cfgSpeed;
  private bool   _cfgLight;
  private bool   _cfgFlicker;
  private int    _cfgRadius;
  private int    _cfgBright;
  private int    _cfgCull;

} // class gy_Stone

class gy_Stone0 : gy_Stone { States { Spawn: gy_t a -1; Stop; } }
class gy_Stone1 : gy_Stone { States { Spawn: gy_t b -1; Stop; } }
class gy_Stone2 : gy_Stone { States { Spawn: gy_t c -1; Stop; } }
class gy_Stone3 : gy_Stone { States { Spawn: gy_t d -1; Stop; } }
