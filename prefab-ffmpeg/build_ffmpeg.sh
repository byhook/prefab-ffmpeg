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

if [ "`ls -A $sourceCodeDir`" = "" ]; then
    echo "$sourceCodeDir is empty"
    rm -rf $sourceCodeDir
    mkdir -p $sourceCodeDir
    # 克隆代码到build目录下
    git clone https://github.com/open-source-mirrors/ffmpeg.git -b 6.0.1 $sourceCodeDir
else
    echo "$sourceCodeDir is not empty"
fi

cd $sourceCodeDir

#注意事项
#https://blog.csdn.net/humadivinity/article/details/111086563

function build_library {
    targetAbi=$1

    mkdir -p $targetBuildDir

    ./configure \
    --prefix=$targetBuildDir \
    --bindir=$targetBuildDir/bin \
    --libdir=$targetBuildDir/libs/$targetAbi \
    --disable-asm \
    --disable-shared \
    --enable-cross-compile \
    --enable-static \
    --enable-small \
    --enable-cross-compile \
    --cross-prefix=$TOOL_NAME_BASE- \
    --target-os=android \
    --arch=$targetAbi \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --nm=$NM \
    --ranlib=$RANLIB \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic -DVK_ENABLE_BETA_EXTENSIONS=0 $OPTIMIZE_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS"

    #--strip=$STRIP \

    make clean
    #构建并安装
    make -j4 install
}

# 目前在M1的

#ABI_LIST="arm64-v8a armeabi-v7a x86_64 x86"
ABI_LIST="arm64-v8a"
abiArray=(${ABI_LIST// / })

for currentAbi in ${abiArray[@]}
do
   echo $currentAbi
   source $currentDir/../setup-ndk-env.sh $currentAbi
   build_library $currentAbi
done