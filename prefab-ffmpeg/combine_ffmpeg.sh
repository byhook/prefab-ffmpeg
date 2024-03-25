#!/bin/sh


CURRENT_DIR=$(pwd)
source $CURRENT_DIR/../setup-ndk-env.sh arm64-v8a

TOOLCHAIN=/Users/handyzhou/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64
HOST=aarch64-linux-android
PREFIX=/Users/handyzhou/Documents/androidProjects/prefab-ffmpeg/build/libs/arm64-v8a
#SYSROOT=/Users/handyzhou/Library/Android/sdk/ndk/21.4.7075529/platforms/android-21/arch-arm64
SYSROOT=/Users/handyzhou/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
API=21
LD=/Users/handyzhou/Library/Android/sdk/ndk/21.4.7075529/toolchains/llvm/prebuilt/darwin-x86_64/$HOST/bin/ld

$LD \
    -rpath-link=$SYSROOT/usr/lib/$HOST/$API \
    -L$SYSROOT/usr/lib/$HOST/$API \
    -L$TOOLCHAIN/lib/gcc/$HOST/4.9.x \
    -L$PREFIX/lib -soname libffmpeg-org.so \
    -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $PREFIX/libffmpeg-org.so \
    $PREFIX/libavcodec.a \
    $PREFIX/libavdevice.a \
    $PREFIX/libavfilter.a \
    $PREFIX/libswresample.a \
    $PREFIX/libavformat.a \
    $PREFIX/libavutil.a \
    $PREFIX/libswscale.a \
    -lc -lm -lz -ldl -llog -landroid --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/$HOST/4.9.x/libgcc_real.a


$STRIP -s $PREFIX/libffmpeg-org.so