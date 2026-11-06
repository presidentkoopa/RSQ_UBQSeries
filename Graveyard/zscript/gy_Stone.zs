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
 * --- Modifications: pop-in, idle bounce, and a culled grave light. GPLv3 too. ---
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

    // Cvars are re-read on a stagger rather than every tic: 50 graves x 9
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
    let pmo     = players[consolePlayer].mo;
    bool inRange = _cfgLight && (pmo != NULL) && (Distance3D(pmo) <= _cfgCull);

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

    int radius = int(_cfgRadius * _lightFade * flicker());
    if (radius < 1) { radius = 1; }

    // Re-attaching the same light id overwrites it, which is how the fade
    // animates - but skip the call on tics where nothing actually moved.
    if (_hasLight && radius == _lastRadius) { return; }

    A_AttachLight( 'gy_grave_light'
                 , DynamicLight.PointLight
                 , lightColor()
                 , radius
                 , 0
                 , DynamicLight.LF_ATTENUATE
                 , (0, 0, 24)
                 );

    _hasLight   = true;
    _lastRadius = radius;
  }

  // Two out-of-step sines instead of random(): a candle wobble rather than
  // white noise, and no RNG draws on any tic.
  private
  double flicker() const
  {
    if (!_cfgFlicker) { return 1.0; }

    double t = level.time + _phaseOffset;
    return 1.0 + 0.08 * (0.6 * sin(t * 13.0) + 0.4 * sin(t * 29.0 + 47.0));
  }

  private
  Color lightColor() const
  {
    int b = clamp(_cfgBright, 0, 255);
    return Color(255, b, int(b * 0.72), int(b * 0.42)); // warm candle tone
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

    // stagger the next refresh so the graves don't all re-read on one tic
    _cfgTimer = 17 + (_phaseOffset % 13);
  }

  // Every cvar read goes through these: GetCVar returns NULL for a cvar that
  // isn't registered (older install, cvarinfo overridden by another pk3), and
  // calling GetFloat() on that NULL is a VM abort.
  private
  bool boolCvar(String name, bool defaultValue) const
  {
    let c = CVar.GetCVar(name, players[consolePlayer]);
    return (c != NULL) ? c.GetBool() : defaultValue;
  }

  private
  double floatCvar(String name, double defaultValue) const
  {
    let c = CVar.GetCVar(name, players[consolePlayer]);
    return (c != NULL) ? c.GetFloat() : defaultValue;
  }

  private
  int intCvar(String name, int defaultValue) const
  {
    let c = CVar.GetCVar(name, players[consolePlayer]);
    return (c != NULL) ? c.GetInt() : defaultValue;
  }

  const POPIN_TICS = 24.0;
  const MIN_SCALE  = 0.05;
  const FADE_STEP  = 0.05; // ~0.7s from dark to full

  private String _obituary;

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
