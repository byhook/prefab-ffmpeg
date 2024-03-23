#!/bin/sh


#当前目录-一般是在Library目录下
currentDir=$(pwd)
buildDir=$currentDir/build
sourceCodeDir=$buildDir/ffmpeg
#最终构建的目录-一般是在父目录
targetBuildDir=$currentDir/../build
buildPrefix=$targetBuildDir/build-prefix

echo "setup-dirs-env====================================>"
echo "currentDir="$currentDir
echo "buildDir="$buildDir
echo "buildPrefix="$buildPrefix
echo "targetBuildDir="$targetBuildDir
echo "<====================================setup-dirs-env"

CURRENT_DIR=$(pwd)
BUILD_DIR=$CURRENT_DIR/build
SOURCE_CODE_DIR=$BUILD_DIR/ffmpeg

TARGET_BUILD_DIR=$CURRENT_DIR/../build

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

function build_library_with_all {
    ABI=$1
    HOST=$2

    mkdir -p $TARGET_BUILD_DIR

    ./configure \
    --prefix=$TARGET_BUILD_DIR \
    --bindir=$TARGET_BUILD_DIR/bin \
    --libdir=$TARGET_BUILD_DIR/libs/$ABI \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs=-lpthread \
    --extra-libs=-lm \
    --disable-asm \
    --enable-cross-compile \
    --enable-static \
    --enable-shared \
    --enable-gpl \
    --enable-libfdk_aac \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-cross-compile \
    --cross-prefix=$TOOL_NAME_BASE- \
    --target-os=android \
    --arch=$ABI \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --nm=$NM \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic -DVK_ENABLE_BETA_EXTENSIONS=0 $OPTIMIZE_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS"

    make clean
    #构建并安装
    make -j4 install
}


# 目前在M1的

ABI_LIST="arm64-v8a armeabi-v7a x86_64 x86"
abiArray=(${ABI_LIST// / })

for currentAbi in ${abiArray[@]}
do
   echo $currentAbi
   source $CURRENT_DIR/../setup-ndk-env.sh $currentAbi

   build_library_with_all $currentAbi $TOOL_NAME_BASE
done