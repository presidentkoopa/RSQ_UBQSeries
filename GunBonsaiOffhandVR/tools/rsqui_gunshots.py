#!/usr/bin/env python3
"""rsqui_gunshots.py -- pictures of each gun's own model, for the status screen's gun cards.

    python3 tools/rsqui_gunshots.py --pk3s "<load order, space separated>" [--classes A,B,C]
                                    [--out graphics/rsqui/guns] [--res 600] [--hold 70]

What it does, all on the test rig (no engine change, nothing hand-drawn):
  1. Writes a stage pk3 to a temp folder: a one-room UDMF map (RSQGUN) whose walls, floor and
     ceiling are a flat magenta key colour at full light, and an event handler that spawns each
     gun class as a world actor in front of the player, posed on its Ready frame -- MODELDEF keys
     models by class + sprite + frame, so the actor draws the same mesh the hand does -- side on.
  2. Runs the rig (RSQUI_RIG, default /home/claude/scratch/run17C.sh) with the load order plus the
     stage, `map RSQGUN`, and dumps the eye every few frames (QZ_DUMP_EVERY / QZ_DUMP_DIR, PPM).
     Which gun a frame shows is written INTO the frame: the handler draws its index as a row of
     Screen.Dim blocks, which QZD draws straight onto the eye in VR (outside the HUD layer), so
     they land on exact eye pixels whatever the HUD settings.
  3. For each gun takes the last settled frame, keys out the magenta, crops to the model and saves
     <out>/<ClassName>.png (transparent, at most 512x256). The skins look these up by class name
     and fall back to the weapon's icon or pickup sprite when there is none.

Without --classes the guns are the player's weapon slots after `give all` (the set the player can
select), so rerunning it for another gun set needs only a new --pk3s.
"""
import argparse
import glob
import os
import shutil
import struct
import subprocess
import sys
import tempfile

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KEY = (255, 0, 255)
BITS = 10          # barcode bits: gun index+1 (7 bits, up to 127 guns), candidate frame (3)
BX, BY, BS, BP = 4, 4, 8, 12   # barcode: first block at (BX,BY), BS px square, BP px pitch


def textmap():
    v = [(-512, 512), (512, 512), (512, -512), (-512, -512)]
    out = ['namespace = "zdoom";',
           'thing { x = -256.0; y = 0.0; angle = 0; type = 1; skill1 = true; skill2 = true; '
           'skill3 = true; skill4 = true; skill5 = true; single = true; coop = true; dm = true; }']
    for x, y in v:
        out.append('vertex { x = %.1f; y = %.1f; }' % (x, y))
    for i in range(4):
        out.append('linedef { v1 = %d; v2 = %d; sidefront = %d; blocking = true; }' % (i, (i + 1) % 4, i))
    for i in range(4):
        out.append('sidedef { sector = 0; texturemiddle = "RSQKEY"; }')
    out.append('sector { heightfloor = 0; heightceiling = 512; texturefloor = "RSQKEY"; '
               'textureceiling = "RSQKEY"; lightlevel = 255; }')
    return '\n'.join(out) + '\n'


def wad(lumps):
    """A PWAD of (name, bytes) lumps."""
    data = b''
    dirs = []
    off = 12
    for name, body in lumps:
        dirs.append((off, len(body), name))
        data += body
        off += len(body)
    head = struct.pack('<4sii', b'PWAD', len(lumps), 12 + len(data))
    d = b''.join(struct.pack('<ii8s', o, l, n.encode().ljust(8, b'\0')) for o, l, n in dirs)
    return head + data + d


ZSCRIPT = r'''
version "4.14"
// rsqui_gunshots.py stage (test only, never shipped): one gun at a time, side on, in front of the
// player, with its index drawn as Dim blocks at the eye's top left.
class RSQGun_Stage : StaticEventHandler
{
	Array<String> guns;
	Actor shown;
	int cur, curTic, phaseTic;
	const HOLD = %(hold)d;
	const SETTLE = 12;
	const CANDS = 8;   // four frames, each at two yaws (models are not all authored facing the same way)
	const DIST = 96;
	int tnt1;

	override void WorldLoaded(WorldEvent e)
	{
		if (level.MapName != "RSQGUN") return;
		guns.Clear();
		String given = "%(classes)s";
		if (given != "") given.Split(guns, ",", TOK_SKIPEMPTY);
		cur = -1;
		phaseTic = level.maptime + 30;
		tnt1 = Actor.GetSpriteIndex("TNT1");
	}

	void Collect()
	{
		let p = players[consoleplayer];
		if (!p.mo) return;
		for (int s = 0; s < 10; s++)
			for (int i = 0; i < p.weapons.SlotSize(s); i++)
			{
				class<Weapon> c = p.weapons.GetWeapon(s, i);
				if (c && guns.Find(c.GetClassName()) == guns.Size()) guns.Push(c.GetClassName());
			}
		Console.Printf("RSQGUN %%d guns", guns.Size());
	}

	override void WorldTick()
	{
		if (level.MapName != "RSQGUN") return;
		let p = players[consoleplayer];
		if (!p.mo) return;
		p.cheats |= CF_TOTALLYFROZEN;
		p.mo.SetOrigin((-256, 0, 0), false);
		p.mo.angle = 0; p.mo.pitch = 0;
		if (level.maptime < phaseTic) return;
		if (cur < 0)
		{
			if (guns.Size() == 0) Collect();
			// nothing in hand: no hand meshes in front of the stage
			p.mo.ClearInventory();
			cur = 0; curTic = level.maptime;
			Show();
			return;
		}
		if (level.maptime - curTic >= HOLD)
		{
			cur++;
			curTic = level.maptime;
			Show();
		}
		Pose();
	}

	void Show()
	{
		if (shown) shown.Destroy();
		shown = null;
		if (cur >= guns.Size())
		{
			if (cur == guns.Size()) Console.Printf("RSQGUN done");
			return;
		}
		class<Actor> c = guns[cur];
		if (!c) return;
		let p = players[consoleplayer];
		double z = p.mo.pos.z + p.mo.player.viewheight - 6;
		shown = Actor.Spawn(c, (-256 + DIST, 0, z), NO_REPLACE);
		if (!shown) return;
		shown.bNoInteraction = true;
		shown.bNoGravity = true;
		shown.angle = 90;
		Candidates();
		Console.Printf("RSQGUN %%d %%s", cur, guns[cur]);
	}

	// MODELDEF keys the hand's mesh by class + sprite + frame, and not every frame is keyed: try
	// the first drawn frames of Ready, Select, Fire and Spawn in turn (the tool keeps the one that
	// shows the most model).
	Array<State> candStates;
	void Candidates()
	{
		candStates.Clear();
		if (!shown) return;
		for (int l = 0; l < 5 && candStates.Size() < CANDS / 2; l++)
		{
			State st;
			switch (l)
			{
			case 0: st = shown.FindState("Ready"); break;
			case 1: st = shown.FindState("Select"); break;
			case 2: st = shown.FindState("Fire"); break;
			case 3: st = shown.FindState("Deselect"); break;
			default: st = shown.SpawnState; break;
			}
			for (int i = 0; st && i < 40; i++)
			{
				// a frame that is ever on screen: not TNT1, not a 0-tic jump
				if (st.sprite != tnt1 && st.tics != 0)
				{
					bool dup = false;
					for (int k = 0; k < candStates.Size(); k++)
						if (candStates[k].sprite == st.sprite && candStates[k].Frame == st.Frame) dup = true;
					if (!dup) { candStates.Push(st); break; }
				}
				st = st.NextState;
			}
		}
	}

	clearscope int Cand() { return (level.maptime - curTic) / (HOLD / CANDS); }

	clearscope int Shots() { return candStates.Size() * 2; }

	void Pose()
	{
		if (!shown || candStates.Size() == 0) return;
		int k = min(Cand(), Shots() - 1);
		let st = candStates[k / 2];
		shown.angle = (k & 1) ? 0 : 90;
		shown.sprite = st.sprite;
		shown.frame = st.Frame;
		shown.tics = -1;
		shown.SetOrigin((-256 + DIST, 0, shown.pos.z), false);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (level.MapName != "RSQGUN") return;
		// the code: gun index + 1 in the low 7 bits, the candidate frame in the high 3, and nothing
		// while a frame is still settling
		int code = 0;
		int per = HOLD / CANDS;
		int into = (level.maptime - curTic) %% per;
		if (cur >= 0 && cur < guns.Size() && into >= SETTLE && Cand() < Shots())
			code = (cur + 1) | (Cand() << 7);
		for (int b = 0; b < %(bits)d; b++)
		{
			bool on = (code >> b) & 1;
			Screen.Dim(on ? 0xFFFFFF : 0x000000, 1.0, %(bx)d + b * %(bp)d, %(by)d, %(bs)d, %(bs)d);
		}
	}
}
'''


def build_stage(tmp, classes, hold):
    st = os.path.join(tmp, 'stage')
    os.makedirs(os.path.join(st, 'maps'))
    os.makedirs(os.path.join(st, 'textures'))
    with open(os.path.join(st, 'maps', 'RSQGUN.wad'), 'wb') as f:
        f.write(wad([('RSQGUN', b''), ('TEXTMAP', textmap().encode()), ('ENDMAP', b'')]))
    Image.new('RGB', (64, 64), KEY).save(os.path.join(st, 'textures', 'RSQKEY.png'))
    with open(os.path.join(st, 'zscript.txt'), 'w') as f:
        f.write(ZSCRIPT % dict(hold=hold, classes=','.join(classes), bits=BITS, bx=BX, by=BY, bs=BS, bp=BP))
    with open(os.path.join(st, 'mapinfo.txt'), 'w') as f:
        f.write('GameInfo { AddEventHandlers = "RSQGun_Stage" }\n'
                'map RSQGUN "Gun stage" { sky1 = "RSQKEY" noautosavehint }\n')
    pk3 = os.path.join(tmp, 'rsqgun_stage.pk3')
    shutil.make_archive(pk3[:-4], 'zip', st)
    os.rename(pk3[:-4] + '.zip', pk3)
    return pk3


def read_code(im):
    code = 0
    for b in range(BITS):
        x = BX + b * BP + BS // 2
        y = BY + BS // 2
        r, g, bl = im.getpixel((x, y))[:3]
        if r > 128 and g > 128 and bl > 128:
            code |= 1 << b
    return code


def is_key(p):
    r, g, b = p[:3]
    return r > 120 and b > 120 and g < 0.55 * min(r, b)


def cut(im):
    """Key out the magenta and crop to the model inside the middle of the eye (the hands are low)."""
    w, h = im.size
    box = (int(w * 0.02), int(h * 0.15), int(w * 0.98), int(h * 0.72))
    sub = im.crop(box).convert('RGBA')
    px = sub.load()
    for y in range(sub.height):
        for x in range(sub.width):
            if is_key(px[x, y]):
                px[x, y] = (0, 0, 0, 0)
            else:
                r, g, b, a = px[x, y]
                # de-fringe: pull the key's tint out of edge pixels
                if r > g + 40 and b > g + 40:
                    m = min(r, b) - g
                    px[x, y] = (max(0, r - m), g, max(0, b - m), 255)
    bb = sub.getbbox()
    if not bb:
        return None
    pad = 6
    bb = (max(0, bb[0] - pad), max(0, bb[1] - pad), min(sub.width, bb[2] + pad), min(sub.height, bb[3] + pad))
    out = sub.crop(bb)
    k = min(512 / out.width, 256 / out.height, 1.0)
    if k < 1:
        out = out.resize((max(1, int(out.width * k)), max(1, int(out.height * k))), Image.LANCZOS)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--pk3s', required=True)
    ap.add_argument('--classes', default='')
    ap.add_argument('--out', default=os.path.join(ROOT, 'graphics', 'rsqui', 'guns'))
    ap.add_argument('--res', type=int, default=600)
    ap.add_argument('--hold', type=int, default=240, help='tics each gun is shown (eight views tried)')
    ap.add_argument('--secs', type=int, default=0, help='rig timeout (default: from the gun count)')
    ap.add_argument('--every', type=int, default=4)
    ap.add_argument('--keep', action='store_true', help='keep the temp folder (frames, stage)')
    a = ap.parse_args()
    rig = os.environ.get('RSQUI_RIG', '/home/claude/scratch/run17C.sh')
    classes = [c.strip() for c in a.classes.split(',') if c.strip()]
    tmp = tempfile.mkdtemp(prefix='rsqgun_')
    stage = build_stage(tmp, classes, a.hold)
    frames = os.path.join(tmp, 'frames')
    os.makedirs(frames)
    n = len(classes) or 40
    secs = a.secs or (100 + n * (a.hold // 35 + 1) * 5)
    env = dict(os.environ, PK3S=a.pk3s + ' ' + stage, QZ_RES=str(a.res), QZ_DUMP_EVERY=str(a.every),
               QZ_DUMP_DIR=frames)
    script = ('vr_hud_scale 1; screenblocks 12; bd_tips 0; wait 40; give all; wait 10; map RSQGUN')
    print('rig: %s, %d s, stage %s' % (rig, secs, stage))
    # the stage prints "RSQGUN done" after the last gun: stop the rig there instead of at its timeout
    logdir = os.environ.get('RSQUI_RIG_LOGS', '/home/claude/scratch/logs*')
    for lg in glob.glob(os.path.join(logdir, 'rsqgun.log')):
        os.remove(lg)
    proc = subprocess.Popen([rig, 'rsqgun', str(secs), script], env=env, start_new_session=True)
    import time
    while proc.poll() is None:
        time.sleep(3)
        if any('RSQGUN done' in open(lg, errors='replace').read() for lg in glob.glob(os.path.join(logdir, 'rsqgun.log'))):
            time.sleep(4)
            os.killpg(proc.pid, 15)
            proc.wait()
            break
    logs = glob.glob(os.path.join(logdir, 'rsqgun.log'))
    names = {}
    for lg in logs:
        for line in open(lg, errors='replace'):
            parts = line.split()
            if len(parts) == 3 and parts[0] == 'RSQGUN' and parts[1].isdigit():
                names[int(parts[1]) + 1] = parts[2]
    frames_by = {}
    for f in sorted(glob.glob(os.path.join(frames, '*.ppm'))):
        im = Image.open(f).convert('RGB')
        c = read_code(im)
        if c:
            frames_by[c] = f          # the last settled frame of each (gun, candidate)
    os.makedirs(a.out, exist_ok=True)
    guns = {}
    for c, f in frames_by.items():
        guns.setdefault(c & 127, []).append(f)
    done = 0
    for g, fs in sorted(guns.items()):
        name = names.get(g) or (classes[g - 1] if g - 1 < len(classes) else None)
        if not name:
            continue
        best, area = None, 0
        for f in fs:
            pic = cut(Image.open(f).convert('RGB'))
            if pic is None:
                continue
            n = sum(1 for p in pic.getchannel('A').getdata() if p)
            if n > area:
                best, area = pic, n
        if best is None:
            print('  %s: nothing on the stage (no model keyed on its first frames)' % name)
            continue
        best.save(os.path.join(a.out, name + '.png'))
        done += 1
        print('  %s: %dx%d' % (name, best.width, best.height))
    print('%d pictures in %s' % (done, a.out))
    if a.keep:
        print('kept', tmp)
    else:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    main()
