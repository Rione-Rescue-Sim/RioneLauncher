#!/bin/bash


#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

last(){
    echo
    echo
    echo " 事前計算を中断します...Σ(ﾟДﾟﾉ)ﾉ"
    echo
    cd $KILL; ./kill.sh
    kill -9 $(ps aux | grep "__pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill -9 $(ps aux | grep "pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    exit 1
}


kill_subwindow(){
    if [[ -f $LOCATION/.signal ]]; then
        last
    fi
}


kill_docker_gnome-terminal(){
    # ターミナルに関するプロセスをすべてkill
    # pgrepなどを使わずに回りくどい書き方をしているのはkillの対象がターミナルなのでフィルタを厳密にするため
    local temp_kill_pid=$(ps -au | grep "dbus" | grep ${DOCKER_USER_NAME} | grep -v "grep"| awk '{print $2}')
    if [[ -n ${temp_kill_pid} ]]; then

        kill ${temp_kill_pid}

    fi

    sleep 5
    unset temp_kill_pid
}

server_start(){
    touch agent.log
    touch server.log

    local DOCKER_SERVER_LOG=dockerServerLog.txt
    error_cnt=0

    # gnome-terminalが起動しない場合があるため、確実に起動を行う
    while true; do
        rm ${DOCKER_SERVER_LOG} 2>/dev/null
        touch ${DOCKER_SERVER_LOG}
        sleep 1

        #サーバー起動
        gnome-terminal -x bash -c "
            echo -n 'serverStart' > dockerServerLog.txt
            bash __pre_calculation.sh
        "&

        if [[ $error_cnt -gt 10 ]]; then

            echo "[ERROR] $LINENO"
            echo "サーバが起動できませんでした"
            last

        fi

        sleep 1

        if [[ ! -z $(cat ${DOCKER_SERVER_LOG} | grep "serverStart") ]]; then

            # gnome-terminalの起動確認
            break

        else
            echo "[ERROR] $LINENO"
            echo "サーバを再起動します"
            kill_docker_gnome-terminal
            error_cnt=$error_cnt+1
            sleep 3
            continue

        fi

    done

    #サーバー待機
    echo " ▼ サーバー起動中..."
    echo

    sleep 3
}

ChangeConditions=1

SERVER_PATH=$1
MAP_NAME=$2

server_start

cd $SERVER_PATH
cd "boot"

sleep 3

bash start-precompute.sh -m $SERVER_PATH/${MAP%/*}

echo "MAP: $MAP_NAME"

bash start-comprun.sh $SERVER_PATH/$MAP_NAME

