#!/bin/bash

AGENT="/home/taka/git/rionerescue"

KILL="rcrs-server/boot/kill.sh"

cd $AGENT

bash compile.sh ; bash launch.sh -t 1,0,1,0,1,0 -h localhost -pre 1 & APID=$! ; sleep 120 ; kill $APID

ps -ef | grep `cd .. && pwd`| grep -v 'pre_calculation_1.sh' | awk '{print "kill -9",$2}' | sh >/dev/null 2>&1


sleep 1

bash launch.sh -all