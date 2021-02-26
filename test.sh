# !/bin/bash
pwd

branch_array=()
branch_array=("${branch_array[@]}" "hoge1")
branch_array=("${branch_array[@]}" "hoge2")
branch_array=("${branch_array[@]}" "hoge3")
branch_array=("${branch_array[@]}" "hoge4")

i=0
for e in ${branch_array[@]}; do
    echo "array[$i] = ${e}"
    let i++
done