#!/bin/bash

CURRENT_DIR=$(pwd)
BUILD_DIR=$CURRENT_DIR/build
SOURCE_CODE_DIR=$BUILD_DIR/yasm

TARGET_BUILD_DIR=$CURRENT_DIR/../build
BUILD_CACHE=$TARGET_BUILD_DIR/build-cache

if [ "`ls -A $SOURCE_CODE_DIR`" = "" ]; then
    echo "$SOURCE_CODE_DIR is empty"
    rm -rf $SOURCE_CODE_DIR
    mkdir -p $SOURCE_CODE_DIR
    # 克隆代码到build目录下
    git clone https://github.com/open-source-mirrors/yasm.git -b 1.3.0 $SOURCE_CODE_DIR
else
    echo "$SOURCE_CODE_DIR is not empty"
fi


cd $SOURCE_CODE_DIR

./autogen.sh
./configure \
    --prefix=$BUILD_CACHE \
    --bindir="$BUILD_DIR/bin" \

make clean all
make -j4 install

