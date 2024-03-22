#!/bin/bash

#同步镜像源代码
source ../setup-source-env.sh \
     x264-stable

if [ "`ls -A $sourceCodeDir`" = "" ]; then
    echo "$sourceCodeDir is empty"
    rm -rf $sourceCodeDir
    mkdir -p $sourceCodeDir
    # 克隆代码到build目录下
    git clone --branch stable --depth 1 https://code.videolan.org/videolan/x264.git $sourceCodeDir
else
    echo "$sourceCodeDir is not empty"
fi

cd $sourceCodeDir

function build_library {
    #目标abi
    targetAbi=$1

    mkdir -p $targetBuildDir/include/x264

    ./configure \
    --prefix="$buildPrefix" \
    --bindir="$buildPrefix/bin" \
    --libdir=$buildPrefix/libs/$targetAbi \
    --includedir=$buildPrefix/include/x264 \
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

    pushd $buildPrefix/libs/$targetAbi
    rm -r libx264.so
    mv libx264.so.* libx264.so
    popd
}


ABI_LIST="arm64-v8a armeabi-v7a x86_64 x86"
abiArray=(${ABI_LIST// / })

for targetAbi in ${abiArray[@]}
do
   echo $targetAbi
   source $currentDir/../setup-ndk-env.sh $targetAbi
   build_library $targetAbi $TOOL_NAME_BASE
done