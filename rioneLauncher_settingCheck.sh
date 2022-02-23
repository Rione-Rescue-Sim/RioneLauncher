#!/bin/bash

set -euo pipefail

SETTING_FILE_NAME=$1

if [[ -z $(find ./ -name ${SETTING_FILE_NAME} -type f ) ]]; then

    echo
    echo [ERROR] $LINENO
    echo -e "\t設定ファイルを見つけられません"
    echo   
    exit 1

fi

SERVER=$(grep SERVER ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
if [[ -z ${SERVER} ]]; then

    echo
    echo [ERROR] $LINENO
    echo   
    exit 1

fi

AGENT=$(grep AGENT ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
if [[ -z ${AGENT} ]]; then

    echo
    echo [ERROR] $LINENO
    echo   
    exit 1

fi

MAP=$(grep MAP ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
if [[ -z ${MAP} ]]; then

    echo
    echo [ERROR] $LINENO
    echo   
    exit 1

fi

BROCKADE=$(grep BROCKADE ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
if [[ -z ${BROCKADE} ]]; then

    echo
    echo [ERROR] $LINENO
    echo   
    exit 1

fi

LOOP=$(grep LOOP ${SETTING_FILE_NAME} | awk -F'=' '{print $2}')
if [[ -z ${LOOP} ]] || [[ ${LOOP} -le 0 ]]; then

    echo
    echo [ERROR] $LINENO
    echo   
    exit 1

fi