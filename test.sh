#!/bin/bash

LOCATION=$(cd; pwd)
echo "$0"
echo "$LOCATION"

PATH_SCORE="/score.csv"
PATH_GDRIVE="/gdrive/remote/"

ROOT_PATH=$(cd; pwd)
PATH_SCORE=${ROOT_PATH}${PATH_SCORE}
PATH_GDRIVE=${ROOT_PATH}${PATH_GDRIVE}

echo "PATH_SCORE: $PATH_SCORE"
echo "PATH_GDRIVE: $PATH_GDRIVE"

cd "${PATH_GDRIVE%/*}"
pwd