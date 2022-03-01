#!/bin/bash

set -euo pipefail

SETTING_FILE_NAME=$1

function ErrorCheck(){
	read temp
	if [[ -z ${temp} ]]; then

		echo
		echo [ERROR] $1
		echo

    	exit 1
	fi
}

echo $SETTING_FILE_NAME | ErrorCheck $LINENO

SERVER=$(grep SERVER ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
echo $SERVER | ErrorCheck $LINENO


AGENT=$(grep AGENT ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
echo $AGENT | ErrorCheck $LINENO


MAP=$(grep MAP ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
echo $MAP | ErrorCheck $LINENO


BROCKADE=$(grep BROCKADE ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
echo $BROCKADE | ErrorCheck $LINENO

LOOP=$(grep LOOP ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
echo $LOOP | ErrorCheck $LINENO