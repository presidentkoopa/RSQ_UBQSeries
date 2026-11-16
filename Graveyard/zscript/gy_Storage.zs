/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020
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
 * --- Modified by presidentkoopa for the RSQ Edition, 2026 (GPLv3 too): a stone's kind (2 = a gold stone, an RSQ Score
 * life spent) stored as a 4th field of its location; records with 3 fields read as kind 1. A death's key (2026-11-10,
 * netplay) is a 5th field; records without it read with no key. ---
 */

class gy_Storage
{

  static
  gy_Storage of()
  {
    let result = new("gy_Storage");
    result._hashes     = Dictionary.FromString(Cvar.GetCvar("gy_hashes"    ).GetString());
    result._locations  = Dictionary.FromString(Cvar.GetCvar("gy_locations" ).GetString());
    result._obituaries = Dictionary.FromString(Cvar.GetCvar("gy_obituaries").GetString());
    result._hashesIterator = DictionaryIterator.Create(result._hashes);
    return result;
  }

  gy_Death Next()
  {
    String checksum = Level.GetChecksum();
    bool hasNext;
    while ((hasNext = _hashesIterator.Next()) && _hashesIterator.Value() != checksum);

    if (!hasNext) { return NULL; }

    return recordAt(_hashesIterator.Key());
  }

  private
  gy_Death recordAt(String i)
  {
    Array<String> lc;
    _locations.At(i).Split(lc, ":");
    if (lc.Size() < 3) { return gy_Death.of((0, 0, 0), _obituaries.At(i)); }
    Vector3 location = (lc[0].ToDouble(), lc[1].ToDouble(), lc[2].ToDouble());
    // RSQ Edition: a 4th field is the stone's kind (2 = a Score life spent). Stones stored before have 3: kind 1.
    int kind = (lc.Size() > 3) ? lc[3].ToInt() : 1;
    // RSQ Edition (2026-11-10): a 5th field is the death's key (gy_Death.getKey). Records stored before have none.
    String key = (lc.Size() > 4) ? lc[4] : "";

    return gy_Death.of(location, _obituaries.At(i)).setKind(kind).setKey(key);
  }

  // RSQ Edition (owner 2026-11-16, check GY11): AT MOST MAP_CAP STONES A MAP. The store is three ini strings that every
  // map start and every death parse whole, and m8f's kept every death forever. Past the cap the oldest stones of this map
  // go (lowest index first: indices are given in order and kept in order); their keys are left in droppedKeys for the
  // caller (play) to take their stones off the map now (gy_Stone.removeKeyed). Other maps' stones are not touched.
  // Returns how many went.
  const MAP_CAP = 200;
  Array<String> droppedKeys;
  private
  int trimThisMap()
  {
    String checksum = Level.GetChecksum();
    int n = getNewIndex();
    int onMap = 0;
    for (int i = 0; i < n; i++)
    {
      String k = String.Format("%d", i);
      String h = _hashes.At(k);
      if (h == "") { return 0; }   // not the dense 0..n-1 the store keeps: leave it be
      if (h == checksum) { ++onMap; }
    }
    int drop = onMap - MAP_CAP;
    if (drop <= 0) { return 0; }

    droppedKeys.Clear();
    Dictionary newHashes     = Dictionary.Create();
    Dictionary newLocations  = Dictionary.Create();
    Dictionary newObituaries = Dictionary.Create();
    int index = 0, dropped = 0;
    for (int i = 0; i < n; i++)
    {
      String k = String.Format("%d", i);
      String h = _hashes.At(k);
      if (dropped < drop && h == checksum)
      {
        droppedKeys.Push(keyOf(recordAt(k)));
        ++dropped;
        continue;
      }
      String s = String.Format("%d", index);
      newHashes    .Insert(s, h);
      newLocations .Insert(s, _locations .At(k));
      newObituaries.Insert(s, _obituaries.At(k));
      ++index;
    }
    _hashes     = newHashes;
    _locations  = newLocations;
    _obituaries = newObituaries;
    let dc = CVar.FindCVar("gy_bones_debug");
    if (dc && dc.GetInt() != 0) { Console.Printf("RSQ Graveyard: this map's store was %d stones, the cap is %d: the oldest %d removed", onMap, MAP_CAP, dropped); }
    return dropped;
  }

  // a record's stone key, as gy_EventHandler.sendKey makes it (the same two forms)
  static
  String keyOf(gy_Death death)
  {
    if (death.getKey() != "") { return death.getKey(); }
    let l = death.getLocation();
    return String.Format("p%f/%f/%f/%d", l.x, l.y, l.z, death.getKind());
  }

  // how many stones the store holds for this map (the rig's check of the cap)
  int countThisMap()
  {
    String checksum = Level.GetChecksum();
    int n = 0;
    let i = DictionaryIterator.Create(_hashes);
    while (i.Next()) { if (i.Value() == checksum) { ++n; } }
    return n;
  }

  void registerDeath(gy_Death death)
  {
    String i = String.Format("%d", getNewIndex());
    let    l = death.GetLocation();

    _hashes    .Insert(i, Level.GetChecksum());
    // RSQ Edition: x:y:z, then the kind (4th field), then the key (5th, 2026-11-10). m8f's reader takes the first 3; the
    // 11-06 reader takes the 4th as the kind. A death with no key is stored as before (kind 1: 3 fields).
    String loc = String.Format("%f:%f:%f", l.x, l.y, l.z);
    if (death.getKey() != "")      { loc.AppendFormat(":%d:%s", death.getKind(), death.getKey()); }
    else if (death.getKind() > 1)  { loc.AppendFormat(":%d", death.getKind()); }
    _locations .Insert(i, loc);
    _obituaries.Insert(i, death.getObituary());

    trimThisMap();
    write();
  }

  void clearAll()
  {
    _hashes     = Dictionary.Create();
    _locations  = Dictionary.Create();
    _obituaries = Dictionary.Create();

    write();
  }

  void clearThisMap()
  {
    Dictionary newHashes     = Dictionary.Create();
    Dictionary newLocations  = Dictionary.Create();
    Dictionary newObituaries = Dictionary.Create();
    int index = 0;

    String checksum = Level.GetChecksum();
    let i = DictionaryIterator.Create(_hashes);
    while (i.Next())
    {
      if (i.Value() != checksum)
      {
        String s = String.Format("%d", index);
        newHashes    .Insert(s, i.Value());
        newLocations .Insert(s, _locations .At(i.Key()));
        newObituaries.Insert(s, _obituaries.At(i.Key()));
        ++index;
      }
    }

    _hashes     = newHashes;
    _locations  = newLocations;
    _obituaries = newObituaries;

    write();
  }

  private int getNewIndex()
  {
    int nRecords = 0;
    let i = DictionaryIterator.Create(_hashes);
    while (i.Next())
    {
      ++nRecords;
    }
    return nRecords;
  }

  private void write()
  {
    Cvar.GetCvar("gy_hashes"    ).SetString(_hashes    .ToString());
    Cvar.GetCvar("gy_locations" ).SetString(_locations .ToString());
    Cvar.GetCvar("gy_obituaries").SetString(_obituaries.ToString());
  }

  private Dictionary _hashes;
  private DictionaryIterator _hashesIterator;
  private Dictionary _locations;
  private Dictionary _obituaries;

} // class gy_Storage
