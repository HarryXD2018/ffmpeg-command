#!/bin/bash

# 获取所有输入文件名
inputs=("$@")

# 设置输出文件名
output="output.mp4"

# 获取第一个视频的高度
height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 ${inputs[0]})

# 缩放所有视频
for (( i=1; i<${#inputs[@]}; i++))
do
  ffmpeg -i ${inputs[$i]} -vf "scale=-1:$height" "scaled$i.mp4"
done

# 构造拼接滤镜
filter="[0:v]"
for (( i=1; i<${#inputs[@]}; i++))
do
  filter="$filter""[$i:v]"
done
filter="$filter""hstack=${#inputs[@]}"

# 拼接所有视频
ffmpeg -i ${inputs[0]} $(for (( i=1; i<${#inputs[@]}; i++)); do echo "-i scaled$i.mp4"; done) -filter_complex "$filter" -c:v libx264 -crf 23 -preset veryfast $output

# 删除中间文件
for (( i=1; i<${#inputs[@]}; i++))
do
  rm "scaled$i.mp4"
done
