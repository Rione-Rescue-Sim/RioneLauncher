#!/bin/bash

AGENT="/home/taka/git/rionerescue"

KILL="rcrs-server/boot/kill.sh"

cd $AGENT

bash compile.sh ; bash launch.sh -t 1,0,1,0,1,0 -h localhost -pre 1 & APID=$! ; sleep 120 ; kill $APID

bash ../$KILL

echo "pre_calculation_1 の実行を[Ctrl + C]で終了してください"

bash launch.sh -all