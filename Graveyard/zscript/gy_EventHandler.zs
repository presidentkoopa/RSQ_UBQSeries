/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020-2021
 *
 * This file is a part of Graveyard.
 *
 * Graveyard is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Graveyard is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Graveyard.  If not, see <https://www.gnu.org/licenses/>.
 */

class gy_EventHandler : EventHandler
{

  override
  void worldTick()
  {
    if (_isFired)
    {
      return;
    }

    _isFired = true;
    removeStonesOnMap();

    let storage = gy_Storage.of();

    gy_Death death;
    while (death = storage.next())
    {
      sendNetworkEvent(spawnEventName(death));
    }
  }

  override
  void worldThingDied(WorldEvent event)
  {
    if (event.thing == NULL || event.thing.player == NULL) { return; }

    String name = event.thing.player.getUserName();
    String obituaryPart;
    if (event.thing.target != NULL)
    {
      String killerName = (event.thing.target.player != NULL)
        ? event.thing.target.player.getUserName()
        : event.thing.target.getTag();
      obituaryPart = ", killed by " .. killerName;
    }
    String obituary = String.format( "Here lies %s%s.\n%s\n%s"
                                   , name
                                   , obituaryPart
                                   , SystemTime.format("%F %T", _now)
                                   , level.TimeFormatted()
                                   );

    let storage = gy_Storage.of();
    let death   = gy_Death.of(event.thing.pos, obituary);
    storage.registerDeath(death);

    if (multiplayer) { sendNetworkEvent(spawnEventName(death)); }
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    // RSQ Edition: "gy_spawk" is the same event for a gold stone (kind 2, an RSQ Score life spent)
    if (event.name.left(8) == "gy_spawn" || event.name.left(8) == "gy_spawk")
    {
      let death = gy_Death.fromString(event.name.mid(8));
      death.setKind(event.name.left(8) == "gy_spawk" ? 2 : 1);
      spawnStone(death);
    }
    else if (event.name == "gy_remove_all")
    {
      gy_Storage.of().clearAll();
      removeStonesOnMap();
      print("GY_REMOVE_ALL_MESSAGE");
    }
    else if (event.name == "gy_remove_map")
    {
      gy_Storage.of().clearThisMap();
      removeStonesOnMap();
      print("GY_REMOVE_MAP_MESSAGE");
    }
  }

  override
  void renderOverlay(RenderEvent event)
  {
    // Workaround to get the current time, which is UI-scoped.
    // Part 1/2.
    int second = level.time / 35 + 1;
    if (second > _lastSecond)
    {
      setNow(second, SystemTime.Now());
    }
  }

  // The one place a stone is made (the original's spawn, moved here unchanged so the RSQ service below uses it too).
  static
  gy_Stone spawnStone(gy_Death death)
  {
    let pos   = death.getLocation();
    int i     = abs(int(pos.x + pos.y + pos.z)) % 4;
    let c     = String.format("gy_Stone%d", i);
    let stone = gy_Stone(Actor.spawn(c, death.getLocation(), ALLOW_REPLACE));
    if (stone)
    {
      stone.setObituary(death.getObituary());
      stone.setKind(death.getKind());
    }
    return stone;
  }

  static
  String spawnEventName(gy_Death death)
  {
    return (death.getKind() > 1 ? "gy_spawk" : "gy_spawn") .. death.toString();
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void print(String message)
  {
    Console.printf("%s", StringTable.localize(message, false));
  }

  private
  void removeStonesOnMap()
  {
    let i = ThinkerIterator.create("gy_Stone");
    Actor a;
    while (a = Actor(i.Next()))
    {
      a.Destroy();
    }
  }

  // Workaround to get the current time, which is UI-scoped.
  // Part 2/2.
  private
  void setNow(int lastSecond, int now) const
  {
    _lastSecond = lastSecond;
    _now = now;
  }

  private transient bool _isFired;
  private int _lastSecond;
  private int _now;

} // class gy_EventHandler

// RSQ EDITION (2026-11-06, owner 19:58 / 19:59): AN RSQ SCORE LIFE SPENT IS A DEATH. RSQ Score asks this service by name
// when a life catches a killing blow: GetInt("stone.life", "", player number, 0, his pawn). The stone is recorded in the
// storage as kind 2 (it comes back with the map like every stone) and spawned now, on every machine, by the same spawn the
// death event uses (Score calls this from synced play code, so no network event is sent). It is the gold stone:
// gy_Stone.setKind. Without RSQ Score nothing asks, and every stone is kind 1.
class gy_RSQService : Service
{
  override
  int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
  {
    // RSQ Edition (owner 2026-11-06): the Bossfight's two asks (zscript/rsqgy/bones.zs)
    if (request == "bones.graves") { return gy_Bones.GravesAsked(stringArg, intArg, doubleArg, Actor(objectArg)); }
    if (request == "stones.pulse") { return gy_Stone.PulseAll(intArg, doubleArg); }
    if (request != "stone.life") { return 0; }
    let mo = Actor(objectArg);
    if (mo == NULL || mo.player == NULL) { return 0; }

    String name = mo.player.getUserName();
    String obituaryPart;
    if (mo.target != NULL && mo.target != mo)
    {
      String killerName = (mo.target.player != NULL) ? mo.target.player.getUserName() : mo.target.getTag();
      obituaryPart = ", killed by " .. killerName;
    }
    String obituary = String.format( "Here %s lost a life%s.\n%s"
                                   , name
                                   , obituaryPart
                                   , level.TimeFormatted()
                                   );
    let death = gy_Death.of(mo.pos, obituary).setKind(2);
    gy_Storage.of().registerDeath(death);
    let stone = gy_EventHandler.spawnStone(death);
    let dc = CVar.FindCVar("rs_score_debug");
    if (dc && dc.GetBool()) { Console.Printf("RSQ Graveyard: a Score life spent: gold tombstone (kind 2) at %.0f %.0f %.0f", mo.pos.x, mo.pos.y, mo.pos.z); }
    return stone ? 1 : 0;
  }
}
