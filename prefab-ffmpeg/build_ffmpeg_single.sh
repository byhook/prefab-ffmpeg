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

function merge_shared_library() {
    # 假设你的NDK安装在 /path/to/ndk
    NDK_PATH=/path/to/ndk
    TOOLCHAIN_PATH=${NDK_PATH}/toolchains/llvm/prebuilt/darwin-x86_64
    AR_TOOL=${TOOLCHAIN_PATH}/bin/llvm-ar
    RANLIB_TOOL=${TOOLCHAIN_PATH}/bin/llvm-ranlib

    # 创建一个目录来存放合并后的静态库
    mkdir merged_libs

    # 合并静态库
    ${AR_TOOL} x lib1.a
    ${AR_TOOL} x lib2.a
    ${AR_TOOL} x lib3.a
    ${AR_TOOL} c libmerged.a lib1.a lib2.a lib3.a
    ${RANLIB_TOOL} libmerged.a

    # 使用你的C++编译器和链接器生成.so文件
    # 假设你的C++ stdlib 是 libc++_static
    ${CXX} -shared -o libmerged.so --sysroot=${NDK_PATH}/sysroot -stdlib=libc++_static -L./merged_libs -lmerged
}

function merge_static_library() {
    # 设置NDK路径
    NDK_ROOT=/path/to/your/ndk

    # 创建输出文件夹
    OUT_DIR=output
    mkdir -p $OUT_DIR

    # 合并静态库
    llvm-ar -M <<EOF > $OUT_DIR/merged_library.a
    creating $OUT_DIR/merged_library.a
    add lib1.a
    add lib2.a
    add lib3.a

    # 如果需要，可以使用ranlib来为合并后的库创建索引
    ${NDK_ROOT}/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ranlib $OUT_DIR/merged_library.a
}

