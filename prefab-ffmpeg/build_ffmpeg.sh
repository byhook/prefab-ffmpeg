#!/bin/sh

CURRENT_DIR=$(pwd)
BUILD_DIR=$CURRENT_DIR/build
SOURCE_CODE_DIR=$BUILD_DIR/ffmpeg

if [ "`ls -A $SOURCE_CODE_DIR`" = "" ]; then
    echo "$SOURCE_CODE_DIR is empty"
    rm -rf $SOURCE_CODE_DIR
    mkdir -p $SOURCE_CODE_DIR
    # 克隆代码到build目录下
    git clone https://github.com/open-source-mirrors/ffmpeg.git -b 6.0.1 $SOURCE_CODE_DIR
else
    echo "$SOURCE_CODE_DIR is not empty"
fi

cd $SOURCE_CODE_DIR

function build_library {
    ABI=$1
    HOST=$2

    BUILD_DIR=$CURRENT_DIR/../build/
    mkdir -p $BUILD_DIR

    export CFLAGS="-fPIE -fPIC"
    export LDFLAGS="-pie"

    ./configure \
    --prefix=$BUILD_DIR \
    --enable-postproc \
    --enable-debug \
    --disable-asm \
    --enable-symver \
    --enable-static \
    --enable-shared \
    --enable-neon \
    --enable-hwaccels \
    --enable-jni \
    --enable-mediacodec \
    --enable-decoder=h264_mediacodec \
    --enable-decoder=hevc_mediacodec \
    --enable-decoder=mpeg4_mediacodec \
    --cross-prefix=$TOOL_NAME_BASE- \
    --disable-doc \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffmpeg \
    --disable-avdevice \
    --target-os=android \
    --arch=$ABI \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$TOOLCHAIN/bin/llvm-ar \
    --nm=$TOOLCHAIN/bin/llvm-nm \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --enable-cross-compile \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic -DVK_ENABLE_BETA_EXTENSIONS=0 $OPTIMIZE_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS"

    make clean all
    #构建并安装
    make -j4 install
    #去掉符号信息
    #$STRIP -s $BUILD_DIR/libs/$ABI/libmp3lame.so
}

# 目前在M1的

ABI_LIST=("arm64-v8a")
HOST_LIST=("aarch64-linux-android")
# "armeabi-v7a" "x86_64" "x86"
# "armv7a-linux-androideabi" "x86_64-linux-android" "i686-linux-android"

# ABI_LIST=("x86_64")
# HOST_LIST=("x86_64-linux-android")

for((index=0;index<${#ABI_LIST[@]};index++));
do
    source $CURRENT_DIR/../setup-ndk-env.sh ${ABI_LIST[index]}
    build_library ${ABI_LIST[index]} ${HOST_LIST[index]}
    echo $index ${ABI_LIST[index]}
done