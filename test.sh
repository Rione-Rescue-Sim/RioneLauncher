# !/bin/bash
pwd

# dev
array=()
array=("1" "2" "3" "4" "5")
echo "{#array[@]}: ${#array[@]}"

for i in ${array[@]}; do
    echo "array: $i"
done    

unset array[1]
unset array[2]

echo
loop=0
for i in ${array[@]}; do
    echo "array: $i"
    array[$loop]=$i
    let loop++
done 

for ((i = 0; i < 2; i++)) {
    declare -i num=${#array[@]}-1
    array=("${array[@]:0:$num}")
}


echo "{#array[@]}: ${#array[@]}"
for ((i = 0; i < ${#array[@]}; i++)) {
    echo "array[$i] = ${array[i]}"
}