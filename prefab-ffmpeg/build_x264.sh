#!/bin/bash

CURRENT_DIR=$(pwd)
BUILD_DIR=$CURRENT_DIR/build
SOURCE_CODE_DIR=$BUILD_DIR/x264-stable

TARGET_BUILD_DIR=$CURRENT_DIR/../build
BUILD_PREFIX=$TARGET_BUILD_DIR/build-prefix

if [ "`ls -A $SOURCE_CODE_DIR`" = "" ]; then
    echo "$SOURCE_CODE_DIR is empty"
    rm -rf $SOURCE_CODE_DIR
    mkdir -p $SOURCE_CODE_DIR
    # 克隆代码到build目录下
    git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git $SOURCE_CODE_DIR
else
    echo "$SOURCE_CODE_DIR is not empty"
fi

cd $SOURCE_CODE_DIR

function build_library {
    TARGET_ABI=$1

    mkdir -p $TARGET_BUILD_DIR/include/x264

    ./configure \
    --prefix="$BUILD_PREFIX" \
    --bindir="$TARGET_BUILD_DIR/bin" \
    --libdir=$TARGET_BUILD_DIR/libs/$TARGET_ABI \
    --includedir=$TARGET_BUILD_DIR/include/x264 \
    --enable-static \
    --enable-shared \
    --enable-pic \
    --enable-strip \
    --disable-asm \
    --disable-cli \
    --host=$TOOLCHAIN_BASE \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic" \
    --extra-ldflags=""

    make clean
    make -j4 install
}


ABI_LIST="arm64-v8a armeabi-v7a x86_64 x86"
abiArray=(${ABI_LIST// / })

for currentAbi in ${abiArray[@]}
do
   echo $currentAbi
   source $CURRENT_DIR/../setup-ndk-env.sh $currentAbi
   build_library $currentAbi $TOOL_NAME_BASE
done