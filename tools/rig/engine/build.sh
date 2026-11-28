#!/bin/bash
# qzlinux17: Linux x86_64 headless test build of QuestZDoom 17.x
#   engine : emawind84/gzdoom branch questzdoom  ($QGZ)
#   wrapper: emawind84/questzdoom Projects/Android/jni ($JNI)  (headers + VrInput*.cpp + math)
# Engine sources = exactly mobile/Android_src.mk, compiled unmodified with the Android defines
# (USE_OPENXR, __MOBILE__, __ANDROID__, NO_SWRENDERER, -fsigned-char ...). The OpenXR/JNI layer
# (QzDoom_OpenXR.cpp, TBXR_Common.cpp, OpenXrInput.cpp) is replaced by glue/qz_linux_glue.cpp.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
QGZ=${QGZ:?set QGZ to the engine source (setup.sh build does)}
JNI=${JNI:?set JNI to questzdoom Projects/Android/jni (setup.sh build does)}
JOBS=${JOBS:-$(nproc)}
D="$HERE/deps"
cd "$HERE"; mkdir -p "$D"

# 1) ZMusic: emawind84/ZMusic at the commit the app repo pins (shared lib, like Android)
ZMC=$(git -C "$JNI/../../.." ls-tree HEAD Projects/Android/jni/SupportLibs/ZMusic | awk '{print $3}')
if [ ! -f "$D/zmusic-install/lib/libzmusic.so" ] && [ ! -f "$D/zmusic-install/lib64/libzmusic.so" ]; then
  [ -d "$D/zmusic/.git" ] || { git init -q "$D/zmusic"; git -C "$D/zmusic" remote add origin https://github.com/emawind84/ZMusic; }
  git -C "$D/zmusic" fetch -q --depth 1 origin "$ZMC" && git -C "$D/zmusic" checkout -q FETCH_HEAD
  mkdir -p "$D/zmusic-build"
  ( cd "$D/zmusic-build" && cmake ../zmusic -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_INSTALL_PREFIX="$D/zmusic-install" > cmake.log && make -j"$JOBS" > make.log && make install > inst.log )
fi
ZLIB=$(ls -d "$D"/zmusic-install/lib*/ | head -1)

# 2) small static libs from the engine tree (lzma, bzip2, webp, zwidget) via upstream CMake
if [ ! -f "$D/libbuild/.done" ]; then
  mkdir -p "$D/libbuild"
  ( cd "$D/libbuild" && cmake "$QGZ" -DCMAKE_BUILD_TYPE=Release -DZMusic_DIR="${ZLIB}cmake/ZMusic" \
      -DCMAKE_PREFIX_PATH="$D/zmusic-install" -DNO_GTK=ON -DHAVE_VULKAN=OFF -DHAVE_GLES2=OFF > cmake.log 2>&1 || { tail -30 cmake.log; exit 1; } )
  ( cd "$D/libbuild" && make -j"$JOBS" lzma webp zwidget > make.log 2>&1 || { tail -30 make.log; exit 1; } )
  touch "$D/libbuild/.done"
fi

# 3) engine pk3s (Android layout: res/gzdoom.pk3 etc. -- see version.h BASEWAD)
mkdir -p res
mkpk3() { [ -f "$2" ] || ( cd "$1/static" && zip -q -r -X -9 "$2" . ); }
# DATA FIX (not engine code): wadsrc/static/language.0 at qzd17 HEAD (commit 25cecc097) has a row with
# one column fewer than the header (JOYMNU_INVERTDIGITALAXISBUTTONS); FStringTable::ParseLanguageCSV
# indexes row[col] unchecked and segfaults on glibc. We pad short rows in a staged copy.
stage_wadsrc() {
  rm -rf "$D/wadsrc_stage"; cp -r "$QGZ/wadsrc" "$D/wadsrc_stage"
  python3 -I "$HERE/tools/pad_csv.py" "$D"/wadsrc_stage/static/language.*
}
[ -f "$HERE/res/qzdoom.pk3" ] || stage_wadsrc
mkpk3 "$D/wadsrc_stage" "$HERE/res/$(sed -n 's/^#define BASEWAD "\(res\/\)\?\(.*\)"/\2/p' "$QGZ/src/version.h" | head -1)"
mkpk3 "$QGZ/wadsrc_extra" "$HERE/res/$(sed -n 's/^#define OPTIONALWAD "\(res\/\)\?\(.*\)"/\2/p' "$QGZ/src/version.h" | head -1)"
mkpk3 "$QGZ/wadsrc_lights" "$HERE/lights.pk3"
mkpk3 "$QGZ/wadsrc_bm" "$HERE/brightmaps.pk3"
[ -d "$QGZ/wadsrc_widepix" ] && mkpk3 "$QGZ/wadsrc_widepix" "$HERE/game_widescreen_gfx.pk3"

# 4) source + include lists from the Android makefile
python3 - "$QGZ/mobile/Android_src.mk" "$QGZ" "$JNI" "$D/zmusic-install/include" > sources.mk <<'PY'
import sys,re
mk,qgz,jni,zinc=sys.argv[1:5]
txt=open(mk).read().replace('\\\n',' ')
txt=re.sub(r'#[^\n]*','',txt)
vars={}
for m in re.finditer(r'^([A-Z_]+)\s*[:+]?=\s*(.*)$',txt,re.M):
    vars.setdefault(m.group(1),[]).extend(m.group(2).split())
src=[]
for v in ['ANDROID_SRC_FILES','PLAT_POSIX_SOURCES','PLAT_NOSDL_SOURCES','FASTMATH_SOURCES','PCH_SOURCES']: src+=vars[v]
src+=[s for s in vars['LOCAL_SRC_FILES'] if not s.startswith('$(')]
qz=[s.replace('../../QzDoom/','') for s in vars['QZDOOM_SRC'] if any(k in s for k in ('VrInputCommon','VrInputDefault','mathlib.c','matrixlib.c'))]
seen=set(); out=[]
for s in src:
    if s not in seen: seen.add(s); out.append(s)
inc=[]
for i in vars['LOCAL_C_INCLUDES']:
    i=i.replace('$(GZDOOM_TOP_PATH)',qgz+'/').replace('${TOP_DIR}',jni).replace('$(TOP_DIR)',jni)
    if '$(SUPPORT_LIBS)' in i:
        if 'openal' in i: i='/usr/include/AL'
        elif 'ZMusic' in i: i=zinc
        else: continue      # jpeg8d / libvpx: system headers
    inc.append('-I'+re.sub('/+','/',i))
print('ENGINE_SRC := '+' '.join(out))
print('QZ_SRC := '+' '.join(qz))
print('ENGINE_INC := '+' '.join(inc))
cf=' '.join(vars['LOCAL_CFLAGS']); cpp=' '.join(vars['LOCAL_CPPFLAGS'])
print('ANDROID_CFLAGS := '+cf.replace('"','\\"'))
print('ANDROID_CPPFLAGS := '+cpp)
PY

# verbatim copy of the pose->angles math from TBXR_Common.cpp (used by VrInputDefault.cpp)
awk '/^ovrMatrix4f ovrMatrix4f_CreateFromQuaternion/{on=1} on{print} on&&/^void QuatToYawPitchRoll/{q=1} q&&/^}/{exit}' \
  "$JNI/QzDoom/TBXR_Common.cpp" > glue/tbxr_math.inc

make -j"$JOBS" -f "$HERE/Makefile" QGZ="$QGZ" JNI="$JNI" ZLIB="$ZLIB" DEPS="$D" "$@"
ln -sf /usr/lib/x86_64-linux-gnu/libGLESv2.so.2 "$HERE/libGLESv3.so"
echo "built $HERE/qzdoom"
