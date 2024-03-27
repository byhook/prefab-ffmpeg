#!/bin/sh

#例如："arm64-v8a armeabi-v7a x86_64 x86"
targetAbi=$1

#当前目录-一般是在Library目录下
currentDir=$(pwd)
buildDir=$currentDir/build
sourceCodeDir=$buildDir/lame-3.100
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
    git clone https://github.com/open-source-mirrors/lame.git -b 3.100 $sourceCodeDir
else
    echo "$sourceCodeDir is not empty"
fi

cd $sourceCodeDir

function build_library {
    targetAbi=$1

    mkdir -p $buildPrefix

    make clear

    ./configure \
    --host=$TOOL_NAME_BASE \
    --prefix=$buildPrefix \
    --bindir=$buildPrefix/bin \
    --libdir=$buildPrefix/libs/$targetAbi \
    --disable-frontend \
    --enable-shared=yes \
    --enable-static=yes

    make clean
    #构建并安装
    make -j4 install
    #去掉符号信息
    $STRIP -s $buildPrefix/libs/$targetAbi/libmp3lame.so
    #删减多余的文件
    pushd $buildPrefix/libs/$targetAbi
    rm -r libmp3lame.la
    popd
}

#targetAbiList="arm64-v8a armeabi-v7a x86_64 x86"
targetAbiList=$1
echo "========================>"$targetAbiList
abiArray=(${targetAbiList// / })

for targetAbi in ${abiArray[@]}
do
   echo $targetAbi
   source $currentDir/../setup-ndk-env.sh $targetAbi
   build_library $targetAbi $TOOL_NAME_BASE
done