#!/bin/bash

CURRENT_DIR=$(pwd)
BUILD_DIR=$CURRENT_DIR/build
SOURCE_CODE_DIR=$BUILD_DIR/nasm


if [ "`ls -A $SOURCE_CODE_DIR`" = "" ]; then
    echo "$SOURCE_CODE_DIR is empty"
    rm -rf $SOURCE_CODE_DIR
    mkdir -p $SOURCE_CODE_DIR
    # 克隆代码到build目录下
    git clone https://github.com/open-source-mirrors/nasm.git -b 2.15.05 $SOURCE_CODE_DIR
else
    echo "$SOURCE_CODE_DIR is not empty"
fi

cd $SOURCE_CODE_DIR

./autogen.sh
./configure \
    --prefix=$BUILD_DIR/cache \
    --bindir="$BUILD_DIR/bin" \

make clean all
make -j4 install

