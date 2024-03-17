#!/bin/sh

function merge_library_old_version() {
    $LD \
    -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib \
        -L$PREFIX/lib \
        -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
        $PREFIX/libffmpeg.so \
        $FDK_LIB/libfdk-aac.a \
        $X264_LIB/libx264.a \
        libavcodec/libavcodec.a \
        libavfilter/libavfilter.a \
        libavresample/libavresample.a \
        libswresample/libswresample.a \
        libavformat/libavformat.a \
        libavutil/libavutil.a \
        libswscale/libswscale.a \
        libpostproc/libpostproc.a \
        libavdevice/libavdevice.a \
        -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker $TOOLCHAIN/lib/gcc/$TOOLNAME_BASE/4.9/libgcc.a
}


function merge_shared2() {
    cd ~/androidProjects/prefab-ffmpeg/build/libs/arm64-v8a
    $LD -shared -o libffmpeg.so libavcodec.so libswscale.so libavdevice.so libavfilter.so libavformat.so libswresample.so
}

function merge_shared() {
    cd ~/androidProjects/prefab-ffmpeg/build/libs/arm64-v8a
    libs=`ls *.a`
    for lib in $libs; do
    	$AR x $lib
    done
    #$AR rc libffmpeg.a *.o
    $AR -r libffmpeg.so *.o
}

function merge_shared_library() {
    # 创建一个目录来存放合并后的静态库
    cd ~/androidProjects/prefab-ffmpeg/build/libs/arm64-v8a
    mkdir merged_libs
    # 合并静态库
#     ${AR} x lib1.a
#     ${AR} x lib2.a
#     ${AR} x lib3.a
#     ${AR} c libmerged.a lib1.a lib2.a lib3.a
    ${RANLIB} libffmpeg.a

    # 使用你的C++编译器和链接器生成.so文件
    # 假设你的C++ stdlib 是 libc++_static
    ${CXX} -shared -o libffmpeg.so --sysroot=${NDK_ROOT}/sysroot -L./merged_libs -lffmpeg
}

function merge_static_library() {
    # 设置NDK路径
    NDK_ROOT=/path/to/your/ndk

    # 创建输出文件夹
    OUT_DIR=output
    mkdir -p $OUT_DIR

    # 合并静态库
    # llvm-ar -M <<EOF > $OUT_DIR/merged_library.a
    creating $OUT_DIR/merged_library.a
    add lib1.a
    add lib2.a
    add lib3.a

    # 如果需要，可以使用ranlib来为合并后的库创建索引
    ${NDK_ROOT}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ranlib $OUT_DIR/merged_library.a
}

# ndk25 合并多个静态库合并为一个静态库文件

function merge_static_library2() {
    # 设置NDK路径
    export NDK_PATH=/path/to/your/ndk

    # 合并静态库的工具路径（根据你的NDK版本和操作系统选择正确的路径）
    AR_TOOL=${NDK_PATH}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar

    # 目标静态库文件
    OUTPUT_LIB=merged_library.a

    # 第一个要合并的静态库
    LIBRARY1=library1.a

    # 第二个要合并的静态库
    LIBRARY2=library2.a

    # 使用llvm-ar合并静态库
    ${AR_TOOL} x ${LIBRARY1}
    ${AR_TOOL} x ${LIBRARY2}
    ${AR_TOOL} r ${OUTPUT_LIB} *.o
    ${AR_TOOL} d ${OUTPUT_LIB} "__.SYMDEF SORTED.*"
    ${AR_TOOL} s ${OUTPUT_LIB}
}

CURRENT_DIR=$(pwd)
source $CURRENT_DIR/../setup-ndk-env.sh arm64-v8a
merge_shared