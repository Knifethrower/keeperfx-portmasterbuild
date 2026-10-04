#!/bin/bash
# Dependencies KeeperFX needs that the bullseye sysroot lacks or that differ between CFWs, for
# ARCH=aarch64 (default) or x86_64. Static: ffmpeg (Smacker only), curl + mbedTLS (matchmaking
# wss), enet6, spng, astronomy, centijson. Shared (shipped): OpenAL Soft.
# Installs into ~/kfx-build/$ARCH/prefix. Run in WSL as root.
set -e
export HOME=/home/andersen ARCH=${ARCH:-aarch64}
T=/mnt/c/Claude/KeeperFX/tools-src
B=$HOME/kfx-build/$ARCH
P=$B/prefix
TC="$T/bullseye.cmake"
if [ "$ARCH" = x86_64 ]; then S=$HOME/chroot-bullseye-amd64; M=-march=x86-64; else S=$HOME/chroot-bullseye; M=-march=armv8-a; fi
CC="clang --target=$ARCH-linux-gnu --sysroot=$S $M"
mkdir -p "$B/src" "$P/lib" "$P/include"
SRC=$HOME/kfx-build/src; mkdir -p "$SRC"; cd "$SRC"

fetch() { [ -d "$2" ] || git clone -q --depth 1 -b "$3" "$1" "$2"; }
cm() { # cmake build: src dir, args...
    local d=$1; shift
    rm -rf "$B/build-$d"
    cmake -S "$d" -B "$B/build-$d" -G Ninja -DCMAKE_TOOLCHAIN_FILE="$TC" -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$P" -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF "$@" >/dev/null
    cmake --build "$B/build-$d" >/dev/null
    cmake --install "$B/build-$d" >/dev/null
}

# ffmpeg: Smacker demuxer + decoders and swresample, nothing else
fetch https://git.ffmpeg.org/ffmpeg.git ffmpeg n7.1.2
rm -rf "$B/build-ffmpeg" && mkdir -p "$B/build-ffmpeg" && cd "$B/build-ffmpeg"
"$SRC/ffmpeg/configure" --prefix="$P" --enable-cross-compile --arch=$ARCH --target-os=linux \
    --cc="$CC" --cxx="${CC/clang/clang++}" --ar=llvm-ar --ranlib=llvm-ranlib --nm=llvm-nm \
    --enable-static --disable-shared --enable-pic --disable-programs --disable-doc --disable-x86asm \
    --disable-everything --disable-autodetect --disable-network --disable-iconv \
    --disable-avdevice --disable-avfilter --disable-swscale \
    --enable-protocol=file --enable-demuxer=smacker --enable-decoder=smacker,smackaud >/dev/null
make -j"$(nproc)" >/dev/null && make install >/dev/null
cd "$SRC"

# mbedTLS (release tarball has the generated sources) + curl with websockets
[ -d mbedtls-3.6.7 ] || curl -sL https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-3.6.7/mbedtls-3.6.7.tar.bz2 | tar xj
cm mbedtls-3.6.7 -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DUSE_SHARED_MBEDTLS_LIBRARY=OFF -DUSE_STATIC_MBEDTLS_LIBRARY=ON
fetch https://github.com/curl/curl.git curl curl-8_22_0
cm curl -DCURL_USE_MBEDTLS=ON -DCURL_USE_OPENSSL=OFF -DHTTP_ONLY=ON -DBUILD_CURL_EXE=OFF -DBUILD_TESTING=OFF \
    -DBUILD_LIBCURL_DOCS=OFF -DBUILD_MISC_DOCS=OFF -DENABLE_CURL_MANUAL=OFF -DCURL_DISABLE_INSTALL_DOCS=ON \
    -DCURL_USE_LIBPSL=OFF -DUSE_LIBIDN2=OFF -DCURL_ZLIB=OFF -DCURL_BROTLI=OFF -DCURL_ZSTD=OFF -DUSE_NGHTTP2=OFF \
    -DCURL_USE_LIBSSH2=OFF -DCURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt -DCURL_CA_PATH=/etc/ssl/certs

# enet6 (IPv6 enet fork used by KeeperFX multiplayer)
fetch https://github.com/SirLynix/enet6.git enet6 v6.1.4
cm enet6 -DENET_STATIC=ON -DENET_SHARED=OFF -DENET_TEST=OFF

# spng
fetch https://github.com/randy408/libspng.git libspng v0.7.4
cm libspng -DSPNG_SHARED=OFF -DSPNG_STATIC=ON -DBUILD_EXAMPLES=OFF -DENABLE_OPT=ON

# OpenAL Soft, shared, ALSA + PulseAudio backends (both dlopen'd)
fetch https://github.com/kcat/openal-soft.git openal-soft 1.24.3
cm openal-soft -DBUILD_SHARED_LIBS=ON -DALSOFT_UTILS=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_TESTS=OFF -DALSOFT_EAX=OFF \
  -DALSOFT_BACKEND_PIPEWIRE=OFF -DALSOFT_BACKEND_JACK=OFF -DALSOFT_BACKEND_SNDIO=OFF \
  -DALSOFT_BACKEND_OSS=OFF -DALSOFT_BACKEND_PORTAUDIO=OFF -DALSOFT_BACKEND_SDL2=OFF \
  -DALSOFT_BACKEND_WAVE=OFF -DALSOFT_REQUIRE_ALSA=ON -DALSOFT_REQUIRE_PULSEAUDIO=ON

# astronomy (moon phase) and centijson: single C sources
fetch https://github.com/cosinekitty/astronomy.git astronomy v2.1.19
$CC -O2 -fPIC -c astronomy/source/c/astronomy.c -o "$B/astronomy.o"
llvm-ar rcs "$P/lib/libastronomy.a" "$B/astronomy.o"
cp astronomy/source/c/astronomy.h "$P/include/"
[ -d centijson ] || { git clone -q https://github.com/mity/centijson.git && git -C centijson checkout -q 8c7a5fb42d9f55044d60592809288164adb4ca95; }
for f in json value json-dom json-ptr; do $CC -O2 -fPIC -c centijson/src/$f.c -o "$B/cj-$f.o"; done
llvm-ar rcs "$P/lib/libjson.a" "$B"/cj-*.o
cp centijson/src/{json,value,json-dom,json-ptr}.h "$P/include/"
echo "deps done: $P"
