# !/bin/bash
pwd

# mergetest
# hoge

canBranchChange="true"
branch_array=()
branch_array=("${branch_array[@]}" "master")
branch_array=("${branch_array[@]}" "feature/21_PF_beforehand")
branch_array=("${branch_array[@]}" "feature/dev/31_PF_taskeset")
branch_array=("${branch_array[@]}" "feature/28_review_extinguishing")

# /////////////////////////////////////////////////////////////////////////////////

branch_array_end_idx=0
branch_array_current_idx=0
for e in ${branch_array[@]}; do
    echo "array[$i]: ${e}"
    let branch_array_end_idx++
done

echo "array[0]: ${branch_array[0]}"

while true; do

    if [[ $canBranchChange = true ]] && [[ $branch_array_current_idx -lt $branch_array_end_idx ]]; then

        echo "branch_array[$branch_array_current_idx]: ${branch_array[$branch_array_current_idx]}"
        let branch_array_current_idx++
        
    else

        echo "canBranchChange: $canBranchChange"
        break

    fi

done
