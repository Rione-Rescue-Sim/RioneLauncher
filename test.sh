# !/bin/bash

function ErrorCheck(){
	read temp
	if [[ -z ${temp} ]]; then

		echo
		echo [ERROR] $1
		echo

    	exit 1
	fi
}

hoge="$(whoami)"
hoge=$(cat /dev/null)
echo $hoge | ErrorCheck $LINENO
