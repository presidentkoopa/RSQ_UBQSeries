# tools/rig17 — the real QuestZDoom 17.3 engine, headless, for testing (never ships)

Built 2026-10-26 in a cloud session so every mod here could be compiled and run on
the owner's actual engine: `emawind84/gzdoom` at the **qzd17.3 tag `9afc750`**
(QZDoom 4.14.3), wrapper `emawind84/questzdoom` `a85c819`. Before this, every rig
test ran on an older 4.12 build.

`build_engine.sh` is the recipe exactly as it ran. It reuses the RSQ_WeaponDepot
rig's engine build (`tools/rig/engine`: Linux glue standing in for OpenXR, poses
from `qz_hmd` / `qz_rhand` / `qz_lhand` cvars, frame dumps) and adds what that box
could not install from package mirrors, built or fetched from GitHub into a local
prefix:

- SDL2 2.30 (libsdl-org/SDL), libvpx 1.14.1 (webmproject/libvpx, generic C target)
- EGL / KHR / GLES2 / GLES3 headers (KhronosGroup EGL-Registry, OpenGL-Registry)
- OpenAL headers (kcat/openal-soft), and an empty `GLES3/gl3ext.h` (an Android NDK stub)

Paths inside the scripts are the session's (`/home/claude/g9`, `/home/claude/scratch`);
adjust them to rebuild elsewhere.

- `run17.sh <name> <secs> "<console script>"` — one run, loading `$PK3S`.
- `runall17.sh` — all four packs, both load orders, menus opened, a fight; fails on
  any script error.
