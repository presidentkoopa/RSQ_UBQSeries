#!/bin/bash
# G9: build the real qzd17.3 engine (9afc750) as the Linux rig, into /home/claude/g9/rig.
# Uses the WeaponDepot rig's build recipe (copied, not modified) + SDL2 built from source
# (the apt mirrors are not reachable from this box).
set -e
G=/home/claude/g9; R=/home/claude/rsq_weapondepot/tools/rig
cd $G
if ! pkg-config --exists sdl2 2>/dev/null && [ ! -f /usr/local/lib/libSDL2.so ]; then
  [ -d SDL ] || git clone -q --depth 1 --branch release-2.30.x https://github.com/libsdl-org/SDL SDL
  mkdir -p SDL/build && cd SDL/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DSDL_TEST=OFF > cmake.log 2>&1 && make -j$(nproc) > make.log 2>&1 && make install > inst.log 2>&1 && ldconfig; cd $G
fi
export PKG_CONFIG_PATH=$G/prefix/lib/pkgconfig:$PKG_CONFIG_PATH CMAKE_PREFIX_PATH=$G/prefix:$CMAKE_PREFIX_PATH CPATH=$G/prefix/include LIBRARY_PATH=$G/prefix/lib
if [ ! -f $G/prefix/lib/libvpx.a ]; then
  [ -d libvpx ] || git clone -q --depth 1 --branch v1.14.1 https://github.com/webmproject/libvpx libvpx
  ( cd libvpx && ./configure --prefix=$G/prefix --target=generic-gnu --enable-pic --disable-examples --disable-tools --disable-docs --disable-unit-tests > vpx_conf.log 2>&1 && make -j$(nproc) > vpx_make.log 2>&1 && make install > vpx_inst.log 2>&1 )
fi
echo "libvpx: $(pkg-config --modversion vpx 2>/dev/null || ls $G/prefix/lib/libvpx* 2>/dev/null)"
echo "SDL2: $(pkg-config --modversion sdl2 2>/dev/null || ls /usr/local/lib/libSDL2*.so 2>/dev/null)"
fetch() { [ -d "$1/.git" ] || { git init -q "$1"; git -C "$1" remote add origin "$2"; }; [ "$(git -C "$1" rev-parse HEAD 2>/dev/null)" = "$3" ] || { git -C "$1" fetch -q --depth 1 origin "$3"; git -C "$1" checkout -q -f FETCH_HEAD; }; }
fetch $G/src/qzd https://github.com/emawind84/gzdoom 9afc750917bf54870f2d16b7ba0d00f2b77e6fb5
git -C $G/src/qzd submodule update -q --init --depth 1 2>/dev/null || true
fetch $G/src/qzw https://github.com/emawind84/questzdoom a85c81947219a5602df64694cb9e80c09380a3a4
mkdir -p $G/rig && cp -a $R/engine/. $G/rig/
QGZ=$G/src/qzd JNI=$G/src/qzw/Projects/Android/jni bash $G/rig/build.sh
echo "G9 BUILD DONE"
