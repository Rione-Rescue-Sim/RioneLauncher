# !/bin/bash
pwd

# dev
str=hoge
echo "str: $str, ${#str}"

str=0
echo "str: $str, ${#str}"

str=""
echo "str: $str, ${#str}"

ROOT_PATH=$(cd; pwd)
echo $ROOT_PATH
