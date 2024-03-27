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

#参考：https://mp.weixin.qq.com/s/W4SWneo3ARuHoDq_h4hPiw
function configure_need() {
    ./configure \
        --prefix=$PREFIX \ # 编译之后的保存位置 \
        --disable-encoders \ # 禁用所有编码器 \
        --disable-decoders \ # 禁用所有解码器 \
        --disable-doc \ # 禁用文档 \
        --disable-htmlpages \
        --disable-manpages \
        --disable-podpages \
        --disable-txtpages \
        --disable-ffmpeg \ # 禁用 ffmpeg 可执行程序构建 \
        --disable-ffplay \ # 禁用 ffplay 可执行程序构建 \
        --disable-ffprobe \ # 禁用 ffprobe 可执行程序构建 \
        --disable-symver \
        --disable-shared \ # 禁用共享链接 \
        --disable-asm \
        --disable-x86asm \
        --disable-avdevice \ # 禁用libavdevice构建 \
        --disable-postproc \ # 禁用libpostproc构建 \
        --disable-cuvid \ # 禁用Nvidia Cuvid \
        --disable-nvenc \ # 禁用Nvidia视频编码 \
        --disable-vaapi \ # 禁用视频加速API代码[Unix/Intel] \
        --disable-vdpau \ # 禁用禁用Nvidia解码和API代码[Unix] \
        --disable-videotoolbox \ # 禁用ios和macos的多媒体处理框架videotoolbox \
        --disable-audiotoolbox \ # 禁用ios和macos的音频处理框架audiotoolbox \
        --disable-appkit \ # 禁用苹果 appkit framework \
        --disable-avfoundation \ 禁用苹果 avfoundation framework \
        --enable-static \ # 启用静态链接 \
        --enable-nonfree \ # 启用非免费的组件 \
        --enable-gpl \ # 启用公共授权组件 \
        --enable-version3 \
        --enable-pic \
        --enable-pthreads \ # 启用多线程
        --enable-encoder=bmp \
        --enable-encoder=flv \
        --enable-encoder=gif \
        --enable-encoder=mpeg4 \
        --enable-encoder=rawvideo \
        --enable-encoder=png \
        --enable-encoder=mjpeg \
        --enable-encoder=yuv4 \
        --enable-encoder=aac \
        --enable-encoder=pcm_s16le \
        --enable-encoder=subrip \
        --enable-encoder=text \
        --enable-encoder=srt \
        --enable-libx264 \ # 启用支持h264
        --enable-encoder=libx264 \
        --enable-libfdk-aac \ # 启用支持fdk-aac
        --enable-encoder=libfdk_aac \
        --enable-decoder=libfdk_aac \
        --enable-libmp3lame \ # 启用支持mp3lame
        --enable-encoder=libmp3lame \
        --enable-libopencore-amrnb \ # 启用支持opencore-amrnb
        --enable-encoder=libopencore_amrnb \
        --enable-decoder=libopencore_amrnb \
        --enable-libopencore-amrwb \ # 启用支持opencore-amrwb
        --enable-decoder=libopencore_amrwb \
        --enable-mediacodec \ # 启用支持mediacodec
        --enable-encoder=h264_mediacodec \
        --enable-encoder=hevc_mediacodec \
        --enable-decoder=h264_mediacodec \
        --enable-decoder=hevc_mediacodec \
        --enable-decoder=mpeg4_mediacodec \
        --enable-decoder=vp8_mediacodec \
        --enable-decoder=vp9_mediacodec \
        --enable-decoder=bmp \
        --enable-decoder=flv \
        --enable-decoder=gif \
        --enable-decoder=mpeg4 \
        --enable-decoder=rawvideo \
        --enable-decoder=h264 \
        --enable-decoder=png \
        --enable-decoder=mjpeg \
        --enable-decoder=yuv4 \
        --enable-decoder=aac \
        --enable-decoder=aac_latm \
        --enable-decoder=pcm_s16le \
        --enable-decoder=mp3 \
        --enable-decoder=flac \
        --enable-decoder=srt \
        --enable-decoder=xsub \
        --enable-small \
        --enable-neon \
        --enable-hwaccels \
        --enable-jni \
        --enable-cross-compile \
        --cross-prefix=$CROSS_PREFIX \
        --target-os=android \
        --arch=$COMPILE_ARCH \
        --cpu=$ANDROID_CUP \
        --cc=$CC \
        --cxx=$CXX \
        --nm=$NM \
        --ar=$AR \
        --as=$AS \
        --strip=$STRIP \
        --ranlib=$RANLIB \
        --sysroot=$SYSROOT \
        --extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS"
}

function build_library {
    targetAbi=$1

    mkdir -p $targetBuildDir

    ./configure \
    --prefix=$targetBuildDir \
    --bindir=$targetBuildDir/bin \
    --libdir=$targetBuildDir/libs/$targetAbi \
    --disable-encoders \
    --disable-decoders \
    --disable-asm \
    --disable-shared \
    --enable-cross-compile \
    --enable-static \
    --enable-small \
    --enable-version3 \
    --enable-pic \
    --enable-pthreads \
    --enable-encoder=bmp \
    --enable-encoder=flv \
    --enable-encoder=gif \
    --enable-encoder=mpeg4 \
    --enable-encoder=png \
    --enable-encoder=mjpeg \
    --enable-encoder=yuv4 \
    --enable-cross-compile \
    --cross-prefix=$TOOL_NAME_BASE- \
    --target-os=android \
    --arch=$targetAbi \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --nm=$NM \
    --strip=$STRIP \
    --ranlib=$RANLIB \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic -DVK_ENABLE_BETA_EXTENSIONS=0 $OPTIMIZE_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS"

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