#!/bin/bash
# Fill release/keeperfx from the official 1.4.0 package (upstream/kfx140, Windows files left out),
# the aarch64 and x86_64 builds and their licenses. Port files (README, port.json, gameinfo.xml,
# images) are kept. Run in WSL as root after build_keeperfx.sh for both arches.
set -e
K=/mnt/c/Claude/KeeperFX; U=$K/upstream/kfx140; D=$K/release/keeperfx
H=/home/andersen; SRC=$H/kfx-build/src; DOC=$H/chroot-bullseye/usr/share/doc

for d in campgns creatrs data fxdata ldata levels mods multiplayer music sound; do
  rm -rf "$D/$d"; cp -r "$U/$d" "$D/"
done
cp "$U/keeperfx_readme.txt" "$D/"
# Controller-friendly defaults from the previous port: vsync-rate drawing, drag tagging
sed -e 's/^FRAMES_PER_SECOND=0/FRAMES_PER_SECOND=AUTO 0/' -e 's/^DEFAULT_TAG_MODE=SINGLE/DEFAULT_TAG_MODE=DRAG/' \
  "$U/keeperfx.cfg" > "$D/keeperfx.cfg"
rm -f "$D/_keeperfx.cfg" "$D/multiplayer_readme.txt"

for a in aarch64 x86_64; do
  cp "$H/kfx-build/$a/keeperfx.$a" "$D/"
  rm -rf "$D/libs.$a"; mkdir -p "$D/libs.$a"
  cp -L "$H/kfx-build/$a/prefix/lib/libopenal.so.1" "$D/libs.$a/libopenal.so.1"
done

L=$D/licenses; rm -rf "$L"; mkdir -p "$L"
cp "$K/tools-src/keeperfx/LICENSE"          "$L/LICENSE.keeperfx.txt"
cp "$SRC/openal-soft/COPYING"               "$L/LICENSE.openal-soft.txt"
cp "$SRC/ffmpeg/COPYING.LGPLv2.1"           "$L/LICENSE.ffmpeg.txt"
cp "$SRC/curl/COPYING"                      "$L/LICENSE.curl.txt"
cp "$SRC/mbedtls-3.6.7/LICENSE"             "$L/LICENSE.mbedtls.txt"
cp "$SRC/enet6/LICENSE"                     "$L/LICENSE.enet6.txt"
cp "$SRC/libspng/LICENSE"                   "$L/LICENSE.spng.txt"
cp "$SRC/astronomy/LICENSE"                 "$L/LICENSE.astronomy.txt"
cp "$SRC/centijson/LICENSE.md"              "$L/LICENSE.centijson.txt"
cp "$DOC/libluajit-5.1-2/copyright"         "$L/LICENSE.luajit.txt"
cp "$DOC/libminiupnpc17/copyright"          "$L/LICENSE.miniupnpc.txt"
cp "$DOC/libnatpmp1/copyright"              "$L/LICENSE.libnatpmp.txt"
cp "$DOC/libminizip1/copyright"             "$L/LICENSE.minizip.txt"
echo staged
