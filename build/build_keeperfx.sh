#!/bin/bash
# Cross-build KeeperFX (tools-src/keeperfx, tag v1.4.0 + patches/) for ARCH=aarch64 (default) or
# x86_64 with upstream's linux.mk; flags and deps are overridden on the make command line.
# Run build_deps.sh first. Output: ~/kfx-build/$ARCH/keeperfx.$ARCH (stripped)
set -e
export HOME=/home/andersen ARCH=${ARCH:-aarch64}
T=/mnt/c/Claude/KeeperFX/tools-src
B=$HOME/kfx-build/$ARCH
P=$B/prefix
W=$B/keeperfx
if [ "$ARCH" = x86_64 ]; then S=$HOME/chroot-bullseye-amd64; M="-march=x86-64"; else S=$HOME/chroot-bullseye; M="-march=armv8-a -fsigned-char"; fi
BUILD_NUMBER=5136   # git rev-list --count v1.4.0, as upstream's release workflow sets it

rm -rf "$W" && mkdir -p "$W"
git -c safe.directory="*" -C "$T/keeperfx" archive v1.4.0 | tar x -C "$W"
for p in "$T"/patches/*.patch; do [ -e "$p" ] && patch -d "$W" -p1 -s < "$p"; done
cd "$W"

# Put the prebuilt deps where linux.mk expects them; old dummy tarballs stop it downloading
mkdir -p deps/astronomy/include deps/centijson/include deps/enet6/include deps/libcurl/lib deps/libcurl/include
touch -d 2000-01-01 deps/{astronomy,centijson,enet6,libcurl}-lin64.tar.gz
cp "$P"/include/astronomy.h deps/astronomy/include/
cp "$P"/include/{json,value,json-dom,json-ptr}.h deps/centijson/include/
cp -r "$P"/include/enet6 deps/enet6/include/
cp -r "$P"/include/curl deps/libcurl/include/
cp "$P"/lib/libcurl.a deps/libcurl/lib/
touch deps/*/include/* deps/enet6/include/enet6/* deps/libcurl/include/curl/* deps/libcurl/lib/libcurl.a

CC="clang --target=$ARCH-linux-gnu --sysroot=$S"
CXX="clang++ --target=$ARCH-linux-gnu --sysroot=$S"
WARN="-Wall -Wextra -Wno-unused-parameter -Wno-unknown-pragmas -Wno-sign-compare"
INC="-Ideps/centitoml -Ideps/centijson/include -Ideps/astronomy/include -Ideps/enet6/include \
 -Ideps/libcurl/include -I$S/usr/include/luajit-2.1 -I$S/usr/include/SDL2 -I$P/include -D_REENTRANT"
OPT="-O3 $M -DDEBUG -DBFDEBUG_LEVEL=0"
LIBS="-L$P/lib -lastronomy -ljson -lenet6 \
 -lSDL2 -lSDL2_mixer -lSDL2_net -lSDL2_image \
 -lavformat -lavcodec -lswresample -lavutil -lopenal \
 -l:libluajit-5.1.a -l:libspng_static.a -l:libminizip.a -l:libminiupnpc.a -l:libnatpmp.a \
 -lcurl -lmbedtls -lmbedx509 -lmbedcrypto -lz -lpthread -ldl -lm"

make -f linux.mk -j"$(nproc)" CC="$CC" CXX="$CXX" BUILD_NUMBER=$BUILD_NUMBER VER_SUFFIX=Portmaster \
  KFX_CFLAGS="$OPT $INC $WARN -Wno-absolute-value -Wno-format-truncation" \
  KFX_CXXFLAGS="$OPT $INC $WARN -Wno-format-truncation" \
  TOML_CFLAGS="-O3 $M -Ideps/centijson/include" \
  KFX_LDFLAGS="-fuse-ld=lld -rdynamic -Wl,--as-needed $LIBS"
llvm-strip -o "$B/keeperfx.$ARCH" bin/keeperfx
echo "built $B/keeperfx.$ARCH"
