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
 *
 * --- Modified by presidentkoopa for the RSQ Edition, 2026 (GPLv3 too): gold stones (an RSQ Score life spent, the
 * "gy_spawk" event, gy_RSQService), one spawn function for every stone, the service's Graves Rise and heartbeat asks,
 * and netplay (2026-11-10): every machine sends its own stored stones at map load, only the dying player's machine
 * sends a new death's stone, and each stone carries a key made from sim data, so a stone whose key was already spawned
 * on this map is skipped: everyone's stones, each one once. ---
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
    _spawnedKeys.Clear();

    // RSQ Edition (2026-11-10, owner: everyone's stones): every machine sends the stones in its own store (alone, as
    // m8f's did). A netgame death was stored by every machine that saw it, under one key, so its copies arrive
    // more than once; networkProcess, which runs in the same order on every machine, spawns the first and skips the
    // rest. A solo death is in one machine's store only, so it comes once, from its machine.
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
    death.setKey(deathKey(event.thing.PlayerNumber(), event.thing.pos, 1));
    storage.registerDeath(death);

    // Every machine stores the death (each has its own store); only the dying player's machine sends the spawn, so the
    // stone is made once (RSQ Edition, 2026-11-10: m8f's sent it from every machine, one stone per player).
    if (multiplayer && event.thing.player == players[consolePlayer]) { sendNetworkEvent(spawnEventName(death)); }
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    // RSQ Edition: "gy_spawk" is the same event for a gold stone (kind 2, an RSQ Score life spent)
    if (event.name.left(8) == "gy_spawn" || event.name.left(8) == "gy_spawk")
    {
      // RSQ Edition (2026-11-10): "gy_spawn<key>@<x:y:z:obituary>". The key has no "@"; the first one ends it.
      String rest = event.name.mid(8);
      int    at   = rest.IndexOf("@");
      String key  = (at >= 0) ? rest.left(at) : "";
      if (at >= 0) { rest = rest.mid(at + 1); }
      if (key != "" && _spawnedKeys.Find(key) != _spawnedKeys.Size())
      {
        let dc = CVar.FindCVar("gy_bones_debug");
        if (dc && dc.GetInt() != 0) { Console.Printf("RSQ Graveyard t%d: stone %s already on the map, copy from player %d skipped", level.maptime, key, event.player); }
        return;
      }
      if (key != "") { _spawnedKeys.Push(key); }
      let death = gy_Death.fromString(rest);
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
    return (death.getKind() > 1 ? "gy_spawk" : "gy_spawn") .. sendKey(death) .. "@" .. death.toString();
  }

  // RSQ Edition (2026-11-10, netplay): a death's key, from sim data only (never the real clock), so every machine in the
  // game computes the same one: the dead player's number, the game's total tics, the map's tics, the spot (whole map
  // units) and the kind. The map itself is the store's checksum. "n" marks a keyed record.
  static
  String deathKey(int playerNumber, Vector3 pos, int kind)
  {
    return String.Format("n%d.%d.%d.%.0f.%.0f.%.0f.%d", playerNumber, level.totaltime, level.maptime, pos.x, pos.y, pos.z, kind);
  }

  // The key a stone is sent with. A record stored before keys (m8f's, or this edition's before 2026-11-10) has none: it
  // is sent with a key made of its exact stored spot and kind ("p"). A netgame death stored by m8f's code was stored at
  // the same spot by every machine, so its copies still meet as one; two old stones at the very same spot become one
  // stone (they stood in one place anyway).
  static
  String sendKey(gy_Death death)
  {
    if (death.getKey() != "") { return death.getKey(); }
    let l = death.getLocation();
    return String.Format("p%f/%f/%f/%d", l.x, l.y, l.z, death.getKind());
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
  private Array<String> _spawnedKeys; // RSQ Edition: the keys of the stones spawned on this map since it loaded
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
    // RSQ Edition (owner 2026-11-06): RSQ Miniboss's two asks, Graves Rise and the heartbeat (zscript/rsqgy/bones.zs)
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
    death.setKey(gy_EventHandler.deathKey(mo.PlayerNumber(), mo.pos, 2)); // the same key on every machine (2026-11-10)
    gy_Storage.of().registerDeath(death);
    let stone = gy_EventHandler.spawnStone(death);
    let dc = CVar.FindCVar("rs_score_debug");
    if (dc && dc.GetBool()) { Console.Printf("RSQ Graveyard: a Score life spent: gold tombstone (kind 2) at %.0f %.0f %.0f", mo.pos.x, mo.pos.y, mo.pos.z); }
    return stone ? 1 : 0;
  }
}
