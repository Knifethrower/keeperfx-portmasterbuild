## Building keeperfx.aarch64 / keeperfx.x86_64

Source: upstream https://github.com/dkfans/keeperfx tag `v1.4.0` (build number 5136) with `patches/`:

- `0001-streamed-sample-volume-null-check.patch`: from the previous port, don't touch a NULL
  streamed sample (sound off / nothing playing).
- `0002-controller-skips-movies.patch`: Start, A or B skip movies. The startup intro plays before
  the controller bindings are loaded, so a controller could not skip it before.

The scripts cross-compile with host clang/lld (WSL Ubuntu 24.04) against Debian bullseye
sysroots (glibc 2.31): `~/chroot-bullseye` (arm64) and `~/chroot-bullseye-amd64`, with
`libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-image-dev libluajit-5.1-dev
libminiupnpc-dev libnatpmp-dev libminizip-dev zlib1g-dev libasound2-dev libpulse-dev` installed.
Paths at the top of each script point at the author's checkout; adjust them.

1. `ARCH=aarch64 ./build_deps.sh` (and `ARCH=x86_64`): static ffmpeg (Smacker only),
   curl + mbedTLS (matchmaking), enet6, spng, astronomy, centijson; shared OpenAL Soft.
2. `ARCH=aarch64 ./build_keeperfx.sh` (and `ARCH=x86_64`): upstream `linux.mk` with flags and
   deps overridden on the make command line.
3. `./stage_release.sh`: copies the official 1.4.0 package data, both binaries, OpenAL and the
   license files into `keeperfx/`.
