#!/bin/bash

USER="taka"

AGENT="/home/$USER/git/rionerescue"

KILL="/home/$USER/git/rcrs-server/boot/"

# /////////////////////////////////////////////////////////////////////////////////////////////
# 以下処理部分

LOCATION=$(cd $(dirname $0); pwd)


cd $AGENT

#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

killcommand(){

    if [[ $phase -eq 1 ]]; then

        if [[ $defalutblockade = "false" ]]; then

            sed -i -e 's/true/false/g' $CONFIG

        else

            sed -i -e 's/false/true/g' $CONFIG

        fi

    fi

    if [[ -f $SERVER/boot/"backup-$START_LAUNCH" ]]; then

        rm $SERVER/boot/$START_LAUNCH
        cat $SERVER/boot/backup-$START_LAUNCH > $SERVER/boot/$START_LAUNCH
        rm $SERVER/boot/"backup-$START_LAUNCH"

    fi

    kill $(ps aux | grep "start.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start-comprun.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start-precompute.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "collapse.jar" | awk '{print $2}') &>/dev/null
    sleep 0.5
    kill $(ps aux | grep "compile.sh" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start.sh -1 -1 -1 -1 -1 -1 localhost" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "$SERVER" | awk '{print $2}') &>/dev/null

    rm $LOCATION/.history_date &>/dev/null
    rm $LOCATION/.signal &>/dev/null

    #updateスレッドが落ちるまで待機
    while :
    do
        if [[ `jobs | grep 'update' | awk '{print $2}'` = '実行中' ]]; then
            continue
        fi
        break
    done

}

last(){
    echo
    echo
    echo " 事前計算を中断します...Σ(ﾟДﾟﾉ)ﾉ"
    echo
    cd $KILL
    ./kill.sh
    kill -9 $(ps aux | grep "pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill -9 $(ps aux | grep "__pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    killcommand
    sleep 2
    exit 1
}

echo "起動完了"

sleep 5

bash compile.sh ; bash launch.sh -t 1,0,1,0,1,0 -h localhost -pre 1 & APID=$! ; sleep 120 ; kill $APID
# bash compile.sh ; bash launch.sh -t 1,0,1,0,1,0 -h localhost -pre 1 & APID=$! ; sleep 10 ; kill $APID
echo "killのエラーは仕様です"
cd $KILL
./kill.sh

sleep 15

cd $AGENT
bash launch.sh -all