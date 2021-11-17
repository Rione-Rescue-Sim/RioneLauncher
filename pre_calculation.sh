#!/bin/bash

SERVER="rcrs-server"

AGENT="rionerescue"

KILL="rcrs-server/boot/"

MAP="maps/gml/test/map"


# /////////////////////////////////////////////////////////////////////////////////////////
# 以下処理コード

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
    cd $KILL; ./kill.sh
    kill -9 $(ps aux | grep "__pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill -9 $(ps aux | grep "pre_calculation.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    exit 1
}

errerbreak(){
    echo " 内部で何らかのエラーが発生しました。"
    echo " シミュレーションを終了します....(｡-人-｡) ｺﾞﾒｰﾝ"
    echo
    killcommand
    exit 1
}

kill_subwindow(){
    if [[ -f $LOCATION/.signal ]]; then
        last
    fi
}

original_clear(){
    for ((i=1;i<`tput lines`;i++))
    do
        echo ""
    done
    echo -e "\e[0;0H" #カーソルを0行目の0列目に戻す
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
            __pre_calculation.sh
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

# ユーザディレクトリまでのパスを取得
ROOT_PATH=$(cd; pwd)
SERVER=$(find ~/ -name $SERVER -typed d 2>/dev/null)
AGENT=$(find ~/ -name $AGENT -type d 2>/dev/null | grep -v "docker")
KILL=$(find ~/ -name boot -type d 2>/dev/null | grep "$KILL")


echo
echo
echo "  ● ディレクトリ検索中..."

#環境変数変更
IFS=$'\n'

#サーバーディレクトリの登録
if [[ -z $SERVER ]] || [[ $ChangeConditions -eq 1 ]] || [[ ! -f $SERVER/boot/start-comprun.sh ]]; then

    serverdirinfo=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep jars/rescuecore2.jar | sed 's@/jars/rescuecore2.jar@@g')) &>/dev/null

    original_clear

    if [ ${#serverdirinfo[@]} -eq 0 ]; then

        echo
        echo "サーバーが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
        echo
        exit 1

    fi

    if [ ! ${#serverdirinfo[@]} -eq 1 ]; then

        #サーバー名+ディレクトリ+文字数
        count=0
        for i in ${serverdirinfo[@]}; do

            mapname=$(echo $i | sed 's@/@ @g' | awk '{print $NF}')

            serverdirinfo[$count]=$mapname"+@+"$i"+@+"${#mapname}

            count=$(($count+1))

        done

        #文字数最大値取得
        maxservername=$(echo "${serverdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}')

        #ソート
        serverdirinfo=($(echo "${serverdirinfo[*]}" | sort -f))

        #エージェントリスト表示
        line=0

        echo
        echo "これは事前計算用スクリプトです"
        echo
        echo "▼ サーバーリスト"
        echo

        for i in ${serverdirinfo[@]}
        do

            servername=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $1}')
            serverdir=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $2}')

            printf "%3d  %s" $((++line)) $servername

            for ((space=$(($maxservername-${#servername}+5)); space>0; space--))
            do

                printf " "

            done

            printf "%s\n" $(echo $serverdir | sed "s@/home/$USER/@@g" | sed "s@$servername@@g")

        done

        echo
        echo "上のリストからサーバーを選択してください。"
        echo "(※ 0を入力するとデフォルトになります)"

        while true
        do

            read servernumber

            #入力エラーチェック
            if [ ! -z `expr "$servernumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $servernumber ] && [ $servernumber -le $line ]; then

                #アドレス代入
                SERVER=`echo ${serverdirinfo[$(($servernumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
                break

            elif [ ! -z `expr "$servernumber" : '\([0-9][0-9]*\)'` ] && [ $servernumber -eq 0 ]; then

                if [ -f $SERVER/boot/start-comprun.sh ]; then

                    break

                else

                    echo "デフォルトの設定が不正確です。0以外を入力してください。"

                fi

            else

                echo "もう一度入力してください。"

            fi

        done


    else

        SERVER=${serverdirinfo[0]}

    fi

fi

#エージェントディレクトリの登録
if [ -z $AGENT ] || [ $ChangeConditions -eq 1 ] || [ ! -f $AGENT/library/rescue/adf/adf-core.jar ]; then

    agentdirinfo=(`find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'`) &>/dev/null

    original_clear

    if [ ${#agentdirinfo[@]} -eq 0 ]; then

        echo
        echo "エージェントが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
        echo
        exit 1

    fi

    if [ ! ${#agentdirinfo[@]} -eq 1 ]; then

        #エージェント名+ディレクトリ+文字数
        count=0
        for i in ${agentdirinfo[@]}; do

            agentname=`echo $i | sed 's@/@ @g' | awk '{print $NF}'`

            agentdirinfo[$count]=$agentname"+@+"$i"+@+"${#agentname}

            count=$(($count+1))

        done

        #文字数最大値取得
        maxagentname=`echo "${agentdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

        #ソート
        agentdirinfo=(`echo "${agentdirinfo[*]}" | sort -f`)

        #エージェントリスト表示
        line=0

        echo
        echo "▼ エージェントリスト"
        echo

        for i in ${agentdirinfo[@]};do

            agentname=`echo ${i} | sed 's/+@+/ /g' | awk '{print $1}'`
            agentdir=`echo ${i} | sed 's/+@+/ /g' | awk '{print $2}'`

            printf "%3d  %s" $((++line)) $agentname

            for ((space=$(($maxagentname-${#agentname}+5)); space>0; space--))
            do

                printf " "

            done

            printf "%s\n" `echo $agentdir | sed "s@/home/$USER/@@g" | sed "s@$agentname@@g"`

        done

        echo
        echo "上のリストからエージェントを選択してください。"
        echo "(※ 0を入力するとデフォルトになります)"

        while true
        do

            read agentnumber

            #入力エラーチェック
            if [ ! -z `expr "$agentnumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $agentnumber ] && [ $agentnumber -le $line ]; then

                #アドレス代入
                AGENT=`echo ${agentdirinfo[$(($agentnumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
                break

            elif [ ! -z `expr "$agentnumber" : '\([0-9][0-9]*\)'` ] && [ $agentnumber -eq 0 ]; then

                if [ -f $AGENT/library/rescue/adf/adf-core.jar ]; then

                    break

                else

                    echo "デフォルトの設定が不正確です。0以外を入力してください。"

                fi

            else

                echo "もう一度入力してください。"

            fi

        done


    else

        AGENT=${agentdirinfo[0]}

    fi

fi

#マップディレクトリの登録
if [ ! -f $SERVER/$MAP/scenario.xml ] || [ $ChangeConditions -eq 1 ] || [ -z $MAP ]; then

    mapdirinfo=(`find $SERVER/maps -name scenario.xml | sed 's@scenario.xml@@g'`)

    original_clear

    #エラーチェック
    if [ ${#mapdirinfo[@]} -eq 0 ]; then

        echo
        echo "マップが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
        echo
        exit 1

    fi

    if [ ! ${#mapdirinfo[@]} -eq 1 ]; then

        #マップ名+ディレクトリ+文字数,不機能マップ除外
        count=0
        for i in ${mapdirinfo[@]}; do

        if [ -f $i/map.gml ]; then

            mapname=`echo ${mapdirinfo[$count]} | sed 's@/map/@@g' | sed 's@/@ @g' | awk '{print $NF}'`
            mapdir=`echo ${mapdirinfo[$count]} | sed "s@$SERVER/@@g"`

            mapdirinfo[$count]=$mapname"+@+"$mapdir"+@+"${#mapname}

        else

            unset mapdirinfo[$count]

        fi

        count=$((count+1))

        done

        #ソート
        mapdirinfo=(`echo "${mapdirinfo[*]}" | sort -f`)

        #マップ名最大値取得
        maxmapname=`echo "${mapdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

        #マップ表示
        line=1
        echo
        echo "▼ マップリスト"
        echo

        toalMapCount=0

        for i in ${mapdirinfo[@]}; do

            mapname=`echo $i | sed 's/+@+/ /g' | awk '{print $1}'`
            mapdir=`echo $i | sed 's/+@+/ /g' | awk '{print $2}'`

            printf "%3d  %s" $line $mapname

            for ((space=$(($maxmapname-${#mapname}+5)); space>0; space--)); do

                printf " "

            done

            printf "%s\n"  `echo $mapdir | sed 's@/map/@@g' | sed "s@$mapname@@g" | sed 's@//@/@g'`

            line=$(($line+1))
            toalMapCount=$(($toalMapCount+1))

        done
        echo
        echo "上のリストからマップ番号を選択してください(0を入力するとデフォルトを選択します)。"


        while true
        do

            read mapnumber
            doAllMap="false"

            #入力エラーチェック
            if [ ! -z `expr "$mapnumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $mapnumber ] && [ $mapnumber -le $line ]; then

                #アドレス代入
                MAP=`echo ${mapdirinfo[$(($mapnumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
                break

            elif [ ! -z `expr "$mapnumber" : '\([0-9][0-9]*\)'` ] && [ $mapnumber -eq 0 ]; then

                if [ -f $SERVER/$MAP/scenario.xml ]; then

                    break

                else

                    echo "デフォルトの設定が不正確です。0以外を入力してください。"

                fi

            else

                echo "もう一度入力してください。"
                echo ""
            fi

        done


    else

        MAP=`echo ${mapdirinfo[0]} | sed "s@$SERVER@@g"`

    fi

fi

server_start

cd $SERVER
cd "boot"


sleep 3

bash start-precompute.sh -m $SERVER/${MAP%/*}

MAP=${MAP%/*}
MAP=${MAP%/*}
echo "MAP: $MAP"

bash start-comprun.sh $SERVER/$MAP

