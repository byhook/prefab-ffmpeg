#!/bin/bash

#同步镜像源代码
source ../setup-source-env.sh \
     fdk-aac-stable 2.0.3 \
     https://github.com/open-source-mirrors/fdk-aac.git

cd $sourceCodeDir

#修正编译报错
mkdir -p libSBRdec/include/log/
echo "void android_errorWriteLog(int i, const char *string){}" > libSBRdec/include/log/log.h

function build_library {
    #目标abi
    targetAbi=$1

    ./configure \
    --prefix="$buildPrefix" \
    --bindir="$buildPrefix/bin" \
    --libdir=$buildPrefix/libs/$targetAbi \
    --includedir=$buildPrefix/include \
    --host=$TOOLCHAIN_BASE \
    --enable-strip \
    --enable-static \
    --enable-shared

    make clean
    make -j4 install

    pushd $buildPrefix/libs/$targetAbi
    rm -r libfdk-aac.la
    # rm -r libfdk-aac.so.2
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
   build_library $targetAbi
done
