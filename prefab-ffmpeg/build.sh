#!/bin/bash


#sysroot/usr/include/vulkan/vulkan.h:89:10: fatal error: 'vulkan_beta.h' file not found #include "vulkan_beta.h"
#sudo apt install libvulkan-dev


#配置NDK路径
NDK=/Users/xyq/Desktop/tool/SDKandNDK/android-ndk-r26
#配置toolchain路径
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
#配置交叉编译环境的根路径
SYSROOT=$TOOLCHAIN/sysroot
#NDK新版本使用llvm-ar, llvm-nm, llvm-strip等
CROSS_PREFIX_LLVM=$TOOLCHAIN/bin/llvm-

#arm64-v8a
API=30
ARCH=arm64
CPU=armv8-a
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
CROSS_PREFIX_CLANG="$TOOLCHAIN/bin/aarch64-linux-android$API"
OPTIMIZE_CFLAGS="-march=$CPU"
OUTPUT=/Users/xyq/Desktop/ffmpeg-demo-res/ffmpeg-6.0/android/$CPU

#armeabi-v7a
#API=30
#ARCH=arm
#CPU=armv7-a
#CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-
#CROSS_PREFIX_CLANG="$TOOLCHAIN/bin/armv7a-linux-androideabi$API"
#OPTIMIZE_CFLAGS="-march=$CPU"
#OUTPUT=/Users/xyq/Desktop/ffmpeg-demo-res/ffmpeg-6.0/android/$CPU

fun build
{
    ./configure \
    --prefix=$OUTPUT \
    --target-os=android \
    --arch=$ARCH \
    --cpu=$CPU \
    --enable-neon \
    --enable-cross-compile \
    --enable-shared \
    --enable-jni \
    --enable-mediacodec \
    --enable-decoder=h264_mediacodec \
    --enable-decoder=hevc_mediacodec \
    --enable-decoder=mpeg4_mediacodec \
    --disable-vulkan \
    --disable-static \
    --disable-asm \
    --disable-doc \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-symver \
    --disable-ffmpeg \
    --disable-avdevice \
    --disable-debug \
    --disable-postproc \
    --sysroot=$SYSROOT \
    --cross-prefix=$CROSS_PREFIX \
    --cross_prefix_clang=$CROSS_PREFIX_CLANG- \
    --cross_prefix_llvm=$CROSS_PREFIX_LLVM \
    --extra-cflags="-Os -fpic -DVK_ENABLE_BETA_EXTENSIONS=0 $OPTIMIZE_CFLAGS"

    make clean all
    make -j24
    make install
}
build