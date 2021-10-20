
#!bin/sh
# str=/home/luna/Desktop/Software/softHLA/HLAreporter.v103/HLAreporter.sh
# file=${str##*/}
# filename=${file%.*}
# suffix=${file##*.}
# echo $file, $filename, $suffix
for file in ./raw/*
do
    tp=${file%.*}
    tp=${tp##*.}
    tp=${tp##*/}
    sudo protoc --descriptor_set_out ./pb/$tp.pb ./raw/$tp.proto
    echo generate from ./pb/$tp.proto to ./pb/$tp.pb
    # if test -f $file
    # then
    #     echo $file 是文件
    # fi
    # if test -d $file
    # then
    #     echo $file 是目录
    # fi
done