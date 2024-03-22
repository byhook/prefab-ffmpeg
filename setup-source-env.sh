#!/bin/bash

#源代码需要克隆的目录名
sourceCodeName=$1
sourceCodeBranch=$2
sourceCodeUrl=$3
#当前目录-一般是在Library目录下
currentDir=$(pwd)
buildDir=$currentDir/build
sourceCodeDir=$buildDir/$sourceCodeName
#最终构建的目录-一般是在父目录
targetBuildDir=$currentDir/../build
buildPrefix=$targetBuildDir/build-prefix

echo "setup-dirs-env====================================>"
echo "currentDir="$currentDir
echo "buildDir="$buildDir
echo "buildPrefix="$buildPrefix
echo "targetBuildDir="$targetBuildDir
echo "sourceCodeName="$sourceCodeName
echo "sourceCodeDir="$sourceCodeDir
echo "sourceCodeBranch="$sourceCodeBranch
echo "sourceCodeUrl="$sourceCodeUrl
echo "<====================================setup-dirs-env"

if [ $sourceCodeName != "" ] && [ $sourceCodeBranch != "" ] && [ $sourceCodeUrl != "" ]; then
    if [ "`ls -A $sourceCodeDir`" = "" ]; then
          echo "$sourceCodeDir is empty"
          rm -rf $sourceCodeDir
          mkdir -p $sourceCodeDir
          # 克隆代码到build目录下
          # git clone --depth 1 https://github.com/mstorsjo/fdk-aac
          git clone $sourceCodeUrl -b $sourceCodeBranch $sourceCodeDir
    else
        echo "$sourceCodeDir is not empty"
    fi
else
    echo "fetch source code ignore"
fi