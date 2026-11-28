"""depot.py: where everything is. Every tool in tools/ finds its inputs here.

Each path is relative to this repository, or comes from an environment variable. Nothing points at a
folder outside the repo unless you set the variable. The names, defaults and meanings are listed in
docs/handbook/03_toolset.md ("Paths").
"""
import os

TOOLS = os.path.dirname(os.path.abspath(__file__))
DEPOT = os.path.dirname(TOOLS)


def _env(name, default):
    v = os.environ.get(name)
    return os.path.abspath(v if v else default)


# the set being worked on (its src/, its hand-fit data). Default: BD22 VR Weapons Q, which is its own repo
# (presidentkoopa/RS_Brutal22WeaponsQ) checked out beside this one. Sets are not kept in this repo since the
# merge into RS_ModelSwapper (2026-11-08): the finished ones are their own repos, the cards live in cards/.
SET = _env('RSQ_SET', os.path.join(DEPOT, '..', 'rs_brutal22weaponsq'))
SRC = _env('RSQ_SRC', os.path.join(SET, 'src'))
# BD22's own repo keeps them under tools/handfit/ (poses/, port/fits/); the Depot's copy of the set kept them under
# handfit/. Take whichever is there, so the defaults work against a plain checkout of RS_Brutal22WeaponsQ (2026-11-27:
# rebake.py check failed on the default path and passed on BD22's own, 30 poses, 0 MODELDEF mismatches).
def _first(*paths):
    for p in paths:
        if os.path.isdir(p):
            return p
    return paths[0]


POSES = _env('RSQ_POSES', _first(os.path.join(SET, 'handfit', 'poses'), os.path.join(SET, 'tools', 'handfit', 'poses')))		# solved hand poses as data
FITS = _env('RSQ_FITS_DIR', _first(os.path.join(SET, 'handfit', 'fits'), os.path.join(SET, 'tools', 'handfit', 'port', 'fits')))		# fit records, bakes, port logs

# the test rig (QuestZDoom 17.3). The engine binary is chosen by rig.py (B22_RIG, else tools/rig/bin).
RIG = os.path.join(TOOLS, 'rig')

# the hand-fitter core: its code (hands_tool) and the measured data it reads (one folder up from the code)
CORE = _env('RSQ_HANDS_LANE', os.path.join(TOOLS, 'handfit', 'core'))
HANDS_TOOL = _env('RSQ_HANDS_TOOL', os.path.join(CORE, 'hands_tool'))
# BD22Q 1.92, the owner's reference holds: an extracted pack (MODELDEF.bd.txt + models/).
# sh tools/rig/setup.sh checks out tag 1.92 here.
GUNPACK192 = _env('RSQ_GUNPACK', os.path.join(RIG, 'build', 'src', 'bd22q_192', 'src'))

# game data and the rig lock: the owner's files, never committed
GAMEDATA = _env('RSQ_GAMEDATA', os.path.join(DEPOT, '..', 'gamedata'))	# doom2.wad, brutal22test6.pk3, BD_VoxelPack.pk3
LOCK = _env('RSQ_RIGLOCK', os.path.join(DEPOT, '..', 'rig.lock'))		# one engine at a time: flock -o -x

# run output (gitignored): logs, frame dumps, sheets, scratch packs
WORK = _env('RSQ_WORK', os.path.join(DEPOT, 'work'))

# outside inputs that are never committed (licence or size). Empty = not set: the tool that needs one says so.
FBX = os.environ.get('RSQ_FBX', '') or os.path.join(os.path.dirname(os.path.abspath(__file__)), 'handfit', 'core', 'fbx_hand', 'hand_final.fbx')	# the FBX hand, in the repo (owner, 2026-10-28)
FBX_TEX = os.environ.get('RSQ_FBX_TEX', '') or (os.path.join(os.path.dirname(FBX), 'textures') if FBX else '')
ERMAC = os.environ.get('RSQ_ERMAC', '')			# Ermac's doom-force-unleashed_devbuild/models (hand/, ammo_hand/)
# the whole Rusted Legacy dev build (models/, modeldefs/, zscript/): what sets/rusted_legacy measures. Default: ERMAC's parent.
RL = os.environ.get('RSQ_RL', '') or (os.path.dirname(os.path.normpath(ERMAC)) if ERMAC else os.path.join(DEPOT, '..', 'rsq_rustedlegacy', 'src'))   # Rusted Legacy is its own repo (2026-11-08)
DOOMWORK = os.environ.get('RSQ_DOOMWORK', '')		# the owner's E:\DOOMWork (REMA, RS_VR_Reload): history tools only
MODELSWAPPER = _env('RSQ_MODELSWAPPER', DEPOT)		# this repo IS RS_ModelSwapper since the merge; the variable stays for the tools that read it
CARDS = _env('RSQ_CARDS', os.path.join(DEPOT, 'cards'))		# the card well: one folder per mesh (cards/README.md)


def need(path, what):
    """Stop with a clear message when an outside input is not set or not there."""
    if not path or not os.path.exists(path):
        raise SystemExit('%s not found (%r). Set the environment variable named in docs/handbook/03_toolset.md, "Paths".'
                         % (what, path))
    return path


def gp192(path):
    """A mesh path recorded against the 1.92 pack ('bd22q_192/models/...') -> the file in GUNPACK192."""
    if 'bd22q_192/' in path:
        return os.path.join(GUNPACK192, path.split('bd22q_192/', 1)[1])
    return path
