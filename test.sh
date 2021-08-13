# !/bin/bash
ROOT_PATH=$(
    cd
    pwd
)
CURRENT_PATH=$(pwd)

temp1=1\n2\n3
temp2=9

echo temp1: $temp1
echo temp2: $temp2

temp1=${temp1}\n${temp2}
echo temp1: $temp1
