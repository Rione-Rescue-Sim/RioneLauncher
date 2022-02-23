#!/bin/bash

# レスキューの実行を行う
# エージェントやマップは引数として受け取る
# すべてを1ファイルで行うと行数が膨大になり、管理が大変になるので分割した

ROOT_PATH=$(
    cd
    pwd
)
CURRENT_PATH=$(pwd)

os=$(uname)
LOCATION=$(
    cd $(dirname $0)
    pwd
)
phase=0

if [[ ! -f $LOCATION/$(echo "$0") ]]; then
    echo 'スクリプトと同じディレクトリで実行してください。'
    exit 0
fi

#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

killcommand() {

    if [[ $phase -eq 1 ]]; then

        if [[ $defalutblockade = "false" ]]; then

            sed -i -e 's/true/false/g' $CONFIG

        else

            sed -i -e 's/false/true/g' $CONFIG

        fi

    fi

    if [[ -f $SERVER/boot/"backup-$START_LAUNCH" ]]; then

        rm $SERVER/boot/$START_LAUNCH
        cat $SERVER/boot/backup-$START_LAUNCH >$SERVER/boot/$START_LAUNCH
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
    while :; do
        if [[ $(jobs | grep 'update' | awk '{print $2}') = '実行中' ]]; then
            continue
        fi
        break
    done

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
        if [ $os = "Linux" ]; then

            # gnome-terminal --tab -x bash -c "
            gnome-terminal -x bash -c "

                echo -n 'serverStart' > dockerServerLog.txt

                #[C+ctrl]検知
                trap 'last2' {1,2,3}
                last2(){
                    echo -en "\x01" > $LOCATION/.signal
                    exit 1
                }

                bash $START_LAUNCH -m ../$MAP/ -c ../$(echo $CONFIG | sed "s@$SERVER/@@g" | sed 's@collapse.cfg@@g') 2>&1 | tee $LOCATION/server.log

                read waitserver

            " &

        else

            bash $START_LAUNCH -m ../$MAP/ -c ../$(echo $CONFIG | sed "s@$SERVER/@@g" | sed 's@collapse.cfg@@g') >$LOCATION/server.log &

        fi

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
    echo "  ※ 以下にエラーが出ることがありますが無視して構いません"

    while true; do

        if [ ! $(grep -c "waiting for misc to connect..." $LOCATION/server.log) -eq 0 ]; then

            sleep 3

            break

        fi

    done
    sleep 3
}

kill_docker_gnome-terminal(){
    # ターミナルに関するプロセスをすべてkill
    # pgrepなどを使わずに回りくどい書き方をしているのはkillの対象がターミナルなのでフィルタを厳密にするため
    local temp_kill_pid=$(ps -au | grep "dbus" | grep ${DOCKER_USER_NAME} | grep -v "grep"| awk '{print $2}')
    if [[ -n ${temp_kill_pid} ]]; then

        kill ${temp_kill_pid}

    fi
    # temp_kill_pid=$(ps -ef | grep gvfsd | grep ${DOCKER_USER_NAME} | awk '{print $2}')
    # if [[ -n ${temp_kill_pid} ]]; then

    #     kill ${temp_kill_pid}

    # fi
    # temp_kill_pid=$(ps -ef | grep dconf-service | grep ${DOCKER_USER_NAME} | awk '{print $2}')
    # if [[ -n ${temp_kill_pid} ]]; then

    #     kill ${temp_kill_pid}

    # fi
    # temp_kill_pid=$(ps -ef | grep gnome-terminal-server | grep ${DOCKER_USER_NAME} | awk '{print $2}')
    # if [[ -n ${temp_kill_pid} ]]; then

    #     kill ${temp_kill_pid}

    # fi

    sleep 5
    unset temp_kill_pid
}

last() {
    if [[ $phase -eq 1 ]]; then
        echo
        echo
        echo " シミュレーションを中断します...Σ(ﾟДﾟﾉ)ﾉ"
        echo
        if [[ -f $SERVER/boot/logs/kernel.log ]] && [[ ! -z $(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}') ]]; then
            echo
            echo "◆　これまでのスコア : "$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')
            echo
        fi
    fi
    killcommand
    exit 1
}

errerbreak() {
    echo " 内部で何らかのエラーが発生しました。"
    echo " シミュレーションを終了します....(｡-人-｡) ｺﾞﾒｰﾝ"
    echo
    killcommand
    exit 1
}

kill_subwindow() {
    if [[ -f $LOCATION/.signal ]]; then
        last
    fi
}

original_clear() {
    for ((i = 1; i < $(tput lines); i++)); do
        echo ""
    done
    echo -e "\e[0;0H" #カーソルを0行目の0列目に戻す
}

###########################################################################################################

currentMapIdx=0

while true; do

    #読み込み最大値取得
    #環境変数変更
    IFS=$' \n'

    #エージェント
    scenariolist=($(cat $SERVER/$MAP/scenario.xml))

    line_count=1
    before_comment=0
    after_comment=0

    for line in ${scenariolist[@]}; do

        if [ $(echo $line | grep '<!--') ]; then

            before_comment=$line_count

        fi

        if [ $(echo $line | grep '\-->') ]; then

            after_comment=$line_count

        fi

        if [ ! $before_comment = 0 ] && [ ! $after_comment = 0 ]; then

            for ((i = before_comment; i <= $after_comment; i++)); do

                unset scenariolist[$(($i - 1))]

            done

            before_comment=0
            after_comment=0

        fi

        line_count=$(($line_count + 1))

    done

    #////////////////////////////////////////////////////////////////////////////////////////////////////

    echo
    IFS=$'\n'

    civilian_max=$(echo "${scenariolist[*]}" | grep -c "civilian")
    policeforce_max=$(echo "${scenariolist[*]}" | grep -c "policeforce")
    firebrigade_max=$(echo "${scenariolist[*]}" | grep -c "firebrigade")
    ambulanceteam_max=$(echo "${scenariolist[*]}" | grep -c "ambulanceteam")

    road_max=$(grep -c "rcr:road gml:id=" $SERVER/$MAP/map.gml)
    building_max=$(grep -c "rcr:building gml:id=" $SERVER/$MAP/map.gml)

    # マップの最大サイクル数を取得
    map_time=$(grep -a -C 0 'kernel.timesteps:' $SERVER/$MAP/../config/kernel.cfg | awk '{print $2}')

    #エラーチェック
    maxlist=($building_max $road_max $civilian_max $ambulanceteam_max $firebrigade_max $policeforce_max)

    errerline=0

    for l in ${maxlist[@]}; do

        if [ $l -eq 0 ]; then

            maxlist[$errerline]=-1

        fi

        errerline=$((errerline + 1))

    done

    #環境変数変更
    IFS=$' \t\n'

    # /////////////////////////////////////////////////////////////////////////////////////
    # 各マップ実行時の変数初期化部

    phase=1
    total_score=0
    scores=()
    MaxDigitScore=0 #スコアの桁数の最大値を保存

    # ///////////////////////////////////////////////////////////////////////////////////////////
    # マップ内ループ
    # レスキューシミュレーションの実行フラグ　デバッグ用
    canExeSimuration="true"
    rm server.log &>/dev/null
    rm agent.log &>/dev/null
    if [[ $canExeSimuration = "true" ]]; then

        for ((loop = 0; loop < $LOOP; loop++)); do

            #設定書き込み
            if [ $brockade = "false" ]; then

                sed -i -e 's/true/false/g' $CONFIG
                brockademenu="なし"

            else

                sed -i -e 's/false/true/g' $CONFIG
                brockademenu="あり"

            fi

            original_clear

            touch agent.log
            touch server.log

            echo
            echo "########## $(($loop + 1)) / $LOOP Start ##################"
            echo

            cd $SERVER/boot/

            if [ $(grep -c "trap" start.sh) -eq 1 ]; then

                START_LAUNCH="start.sh"

            else

                START_LAUNCH="start-comprun.sh"

            fi

            cp $START_LAUNCH "backup-$START_LAUNCH"

            sed -i "s/$(cat $START_LAUNCH | grep 'startKernel')/startKernel --nomenu --autorun/g" $START_LAUNCH
            sed -i "s/$(cat $START_LAUNCH | grep 'startSims')/startSims --nogui/g" $START_LAUNCH


            server_start

            original_clear

            echo
            echo " ▼ 以下の環境を読み込んでいます..."
            echo
            echo "      サーバー ："$(echo $SERVER | sed 's@/@ @g' | awk '{print $NF}')
            echo "  エージェント ："$(echo $AGENT | sed 's@/@ @g' | awk '{print $NF}')
            echo "        マップ ："$(echo $MAP | sed 's@/map/@@g' | sed 's@/maps@maps@g')
            echo "  　　　　瓦礫 ：$brockademenu"
            echo "  　　ブランチ ：$current_branch"

            if [[ $doAllMap == "true" ]]; then

                echo "マップサイクル ：$(($loop + 1)) / $LOOP loops | $(($currentMapIdx + 1)) / $toalMapCount Maps"

            else

                echo "マップサイクル ：$(($loop + 1)) / $LOOP loops"

            fi

            #エージェント起動
            cd $AGENT

            if [[ $loop -eq 0 ]]; then
                echo
                echo -n "  コンパイル中..."
                bash compile.sh >$LOCATION/agent.log 2>&1
                echo "$LINENO gnome-terminal: $?"
            else
                echo
                echo -n "  Ready..."
                echo 'Done.' >$LOCATION/agent.log
            fi

            if [[ -f 'start.sh' ]]; then

                bash start.sh -1 -1 -1 -1 -1 -1 localhost >>$LOCATION/agent.log 2>&1 &

            else

                bash ./launch.sh -all -local >>$LOCATION/agent.log 2>&1 &

            fi

            cd $LOCATION

            lording_ber() {

                if [ $1 -le 0 ] && [ $2 -eq 0 -o $2 -eq 1 ]; then

                    echo "　 サーバーから読み込むことができませんでした。　"

                else

                    for ((ber = 1; ber <= $(($1 / 2)); ber++)); do

                        echo -e "\e[106m "

                    done

                    for ((ber = 1; ber <= $((50 - $1 / 2)); ber++)); do

                        echo -e "\e[107m "

                    done

                fi

            }

            proportion() {

                if [ ! $1 -lt 0 ]; then

                    echo -n $1"%"

                fi

            }

            #エラーチェック
            if [ -f agent.log ]; then

                #errer
                if [ $(grep -c "Failed." agent.log) -eq 1 ]; then

                    echo " エラー"
                    echo
                    echo
                    echo " ＜エラー内容＞"
                    echo
                    cat agent.log
                    echo
                    echo " コンパイルエラー...開始できませんでした...ｻｰｾﾝ( ・ω ・)ゞ"
                    echo

                    killcommand

                    exit 1

                fi

                #sucsess
                if [ $(grep -c "Done." agent.log) -ge 1 ]; then

                    echo "(*'-')b"
                    echo

                fi

            fi

            while true; do

                kill_subwindow

                #ログ読み込み
                if [ $(grep -c "trap" $SERVER/boot/start.sh) -eq 1 ]; then

                    building_read=-1
                    road_read=-1

                else

                    building_read=$(grep -c "floor:" server.log)
                    road_read=$(grep -c "Road " server.log)

                fi

                ambulanceteam_read=$(grep -c "PlatoonAmbulance@" agent.log)
                firebrigade_read=$(grep -c "PlatoonFire@" agent.log)
                policeforce_read=$(grep -c "PlatoonPolice@" agent.log)
                civilian_read=$(($(cat server.log | grep "INFO launcher : Launching instance" | awk '{print $6}' | sed -e 's/[^0-9]//g' | awk '{if (max<$1) max=$1} END {print max}') - 1))

                if [ $civilian_read -lt 0 ]; then

                    civilian_read=0

                fi

                # ロード絶対100%に修正する
                if [ $(($building_read * 100 / ${maxlist[0]})) -eq 100 ]; then

                    if [ ! $ambulanceteam_read -eq 0 ] || [ ! $firebrigade_read -eq 0 ] || [ ! $policeforce_read -eq 0 ] || [ ! $civilian_read -eq 0 ]; then

                        if [ ! $road_max -eq 0 ]; then

                            road_read=${maxlist[1]}

                        fi
                    fi

                fi

                #進行度表示
                # str_Civilian="      Civilian | `proportion $(($civilian_read*100/${maxlist[2]}))`"
                # str_AmbulanceTeam=" AmbulanceTeam | `proportion $(($ambulanceteam_read*100/${maxlist[3]}))`"
                # str_FireBrigade="   FireBrigade | `proportion $(($firebrigade_read*100/${maxlist[4]}))`"
                # str_PoliceForce="   PoliceForce | `proportion $(($policeforce_read*100/${maxlist[5]}))`"

                # echo -e "\e[12;0H" #カーソルを12行目の0列目に戻す
                # echo -e "$str_Civilian\n$str_AmbulanceTeam\n$str_FireBrigade\n$str_PoliceForce\c"

                #  色付き進捗バーは非常に重いので廃止。一応残してある
                echo -e "\e[11;0H" #カーソルを11行目の0列目に戻す
                echo -e "\e[K\c"
                echo -e "      Civilian |"$(lording_ber $(($civilian_read * 100 / ${maxlist[2]})) 2) "\e[m|" $(proportion $(($civilian_read * 100 / ${maxlist[2]})))
                echo

                echo -e "\e[K\c"
                echo -e " AmbulanceTeam |"$(lording_ber $(($ambulanceteam_read * 100 / ${maxlist[3]})) 3) "\e[m|" $(proportion $(($ambulanceteam_read * 100 / ${maxlist[3]})))
                echo

                echo -e "\e[K\c"
                echo -e "   FireBrigade |"$(lording_ber $(($firebrigade_read * 100 / ${maxlist[4]})) 4) "\e[m|" $(proportion $(($firebrigade_read * 100 / ${maxlist[4]})))
                echo

                echo -e "\e[K\c"
                echo -e "   PoliceForce |"$(lording_ber $(($policeforce_read * 100 / ${maxlist[5]})) 5) "\e[m|" $(proportion $(($policeforce_read * 100 / ${maxlist[5]})))
                echo

                if [ $(grep -c "Loader is not found." agent.log) -eq 1 ]; then

                    echo "[ERROR] $LINENO"
                    errerbreak

                fi

                if [ ! $(grep -c "Done connecting to server" agent.log) -eq 0 ]; then

                    if [ $(cat agent.log | grep "Done connecting to server" | awk '{print $6}' | sed -e 's/(//g') -gt 0 ]; then

                        if [[ $START_LAUNCH = "start.sh" ]]; then

                            [ ! $(grep -c "failed: No more agents" server.log) -eq 1 ] && continue

                        fi

                        echo
                        echo

                        break

                    fi

                fi

                sleep 1

            done

            #agent.logの読み込み
            lastline=$(grep -e "FINISH" -n agent.log | sed -e 's/:.*//g' | awk '{if (max<$1) max=$1} END {print max}')

            #コンフィグのサイクル数読み込み
            config_cycle=$(cat $(echo $CONFIG | sed s@collapse.cfg@kernel.cfg@g) | grep "timesteps:" | awk '{print $2}')

            # ゼロで初期化するとゼロ除算が発生する
            next_cycle=1

            start_time=$(date +%s)

            while true; do

                dis_time=$(date +%s)

                kill_subwindow

                cycle=$(cat $SERVER/boot/logs/traffic.log | grep -a "Timestep" | grep -a "took" | awk '{print $5}' | tail -n 1)

                expr $cycle + 1 >/dev/null 2>&1

                [ $? -eq 2 ] && continue

                [ -z $cycle ] && cycle=0

                # temp_lastline=0

                # サイクル数が更新されたか？           ↓サイクル数が0でも表示を行う例外処理
                if [[ $next_cycle -eq $cycle ]] || [[ $next_cycle -eq 1 ]]; then

                    # echo -n "**** Time: $cycle / $map_time*************************"
                    # echo -n " "
                    # 表示がかぶることがあるので結合して出力を行う
                    str_cycle="**** Time: ${cycle} / $map_time　*************************"
                    echo -n "$str_cycle"

                fi

                # tail -n $((`wc -l agent.log | awk '{print $1}'` - $lastline)) agent.log
                isOut=$(($(wc -l agent.log | awk '{print $1}') - $lastline))
                if [[ isOut -gt 0 ]]; then
                    echo
                    echo
                    tail -n $(($(wc -l agent.log | awk '{print $1}') - $lastline)) agent.log
                    echo
                fi

                temp_lastline=$lastline
                lastline=$(wc -l agent.log | awk '{print $1}')

                # プログラムからの標準出力がない場合は表示の上書きを行う
                if [[ $temp_lastline -eq $lastline ]] && [[ $OVERWRITING = "true" ]]; then
                    # サイクルの更新があった場合
                    if [[ $next_cycle -eq $cycle ]]; then

                        # echo temp: $temp_lastline
                        # echo lastline: $lastline
                        end_time=$(date +%s)
                        run_time=$(($end_time - $start_time))
                        # echo "run: $run_time"
                        # 少数計算　scaleは小数点以下の精度
                        # 経過時間/サイクル
                        run_time=$(echo "scale=5; $run_time / $next_cycle" | bc)
                        # echo "run: $run_time"
                        # ループを含む残りサイクル数
                        rem_cycle=$(echo "scale=5; ($map_time - $cycle) + ($map_time * ($LOOP - $loop - 1))" | bc)
                        # echo "rem: $rem_cycle"
                        # 予測時間
                        exp_time_m=$(echo "scale=1; ($rem_cycle * $run_time) / 60" | bc)
                        if [[ $(echo "$exp_time_m > 60" | bc) == 1 ]]; then

                            exp_time_h=$(echo "$exp_time_m / 60" | bc)
                            exp_time_m=$(echo "$exp_time_m % 60" | bc)
                            str_exp=" | ${exp_time_h}h ${exp_time_m}m    "

                        else

                            str_exp=" | ${exp_time_m}m    "

                        fi

                        echo -e "\r\c"　#カーソルを先頭に戻し、改行しない→上書き
                        echo -e "$str_cycle $str_exp\r\c"

                    # サイクルの更新がなかった場合
                    else

                        echo -e "\r\c"　#カーソルを先頭に戻し、改行しない→上書き
                        echo -e "$str_cycle $str_exp\r\c"

                    fi

                fi

                # 次のサイクル数を計算しておくことでサイクルの更新を検知できる
                next_cycle=$(($cycle + 1))

                if [[ ! $LIMIT_CYCLE -eq 0 ]] && [[ $cycle -ge $LIMIT_CYCLE ]] || [[ $cycle -ge $config_cycle ]]; then

                    echo
                    echo
                    echo "● シミュレーション終了！！"
                    echo
                    echo -e "スコア取得中\r\c"

                    # while [[ -z `echo $score | grep "^-\?[0-9]\+\.\?[0-9]*$"` ]]; do
                    #     score=$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')
                    # done

                    sleep 2
                    sync
                    cd
                    score=$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')
                    # そのマップにおけるスコアの桁数の最大値が求められていない場合
                    if [[ $MaxDigitScore -eq 0 ]]; then
                        # 少なくとも5回は桁数の最大値を更新する
                        for ((i = 0; i < 5; i++)); do
                            score=$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')
                            if [[ $MaxDigitScore -lt ${#score} ]]; then
                                MaxDigitScore=${#score}
                            fi
                            sleep 1
                        done
                    fi

                    # スコア取得
                    # 10回を上限に桁数チェックを行いスコア取得を行う
                    loop_cnt=0
                    temp_score=0
                    while true; do
                        score=$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')
                        # socreの桁数が事前に取得した検査用の精度を満たす場合
                        if [[ ${MaxDigitScore} -le ${#score} ]]; then
                            # 取得したスコアの精度が検査用の精度以上のとき
                            if [[ ${MaxDigitScore} -lt ${#score} ]]; then
                                MaxDigitScore=${#score}
                            fi
                            break
                        else
                            # スコアが一定精度以下&&一時保存した精度以上の場合は一時保存のスコアを更新
                            # 精度を満たさない場合でもできるだけ高い精度を出力したい
                            if [[ ${#temp_score} -lt ${#score} ]]; then
                                temp_score=$score
                            fi
                        fi
                        # 規定回数スコアを取得しても規定の精度を満たさない場合
                        # 一時保存していた最大精度のスコアを出力
                        if [[ $loop_cnt -gt 10 ]]; then
                            echo -e "スコアを正常に取得できませんでした"
                            echo "MaxDigitScore: $MaxDigitScore"
                            echo "score: $temp_score"
                            score=$temp_score
                            break
                        fi
                        let loop_cnt++
                        sleep 1
                    done

                    scores+=($score)

                    echo -e "◆ 最終スコアは"$score"でした。"

                    temp_path=$(pwd)
                    cd $CURRENT_PATH

                    [ ! -f score.csv ] && echo 'Date, Score, Server, Agent, Map, Blockade' >score.csv
                    [ $brockademenu = 'あり' ] && is_blockade_exit=yes
                    [ $brockademenu = 'なし' ] && is_blockade_exit=no

                    echo "$(date +%Y/%m/%d_%H:%M), $score, $(echo $SERVER | sed "s@/home/$USER/@@g"), $(echo $AGENT | sed "s@/home/$USER/@@g"), $(echo $MAP | sed 's@/map/@@g' | sed 's@/map@@g' | sed 's@/maps@maps@g'), $is_blockade_exit" >>score.csv
                    echo
                    echo "スコアは'score.csv'に記録しました。"
                    echo

                    cd $temp_path
                    temp_path=0

                    total_score=$(echo $total_score + $score | bc -l)

                    killcommand

                    break

                fi

                sleep 1

            done

            echo
            echo "########## $(($loop + 1)) / $LOOP Finish ##################"
            echo

            sleep 3
            killcommand
            sync
            sleep 5

        done

    fi

    echo
    echo "●  シミュレーション完全終了！！"
    echo
    echo "◆  全スコア一覧"
    echo

    for ((i = 0; i < $LOOP; i++)); do
        echo " $(($i + 1)) : ${scores[$i]}"
    done

    echo
    echo "スコア平均 : $(echo $total_score / $LOOP | bc -l)"
    echo

    # すべてのマップ実行時
    if [[ ${doAllMap} == "true" ]]; then

        currentMapIdx=$(($currentMapIdx + 1))

        # すべてのマップを実行したとき
        if [ ${currentMapIdx} -ge ${toalMapCount} ]; then

            # 未実行のブランチが存在する場合
            if [[ $canBranchChange == "true" ]] && [[ $branch_array_current_idx -lt $branch_array_end_idx ]]; then

                echo "branch_array[$branch_array_current_idx]: ${branch_array[$branch_array_current_idx]}"
                # git checkout ${branch_array[$branch_array_current_idx]}
                let branch_array_current_idx++
                currentMapIdx=0

            else

                # 終了
                break

            fi

        # 実行していないマップが残っている場合
        else

            echo
            echo "########## $(($currentMapIdx + 1)) / $toalMapCount Maps ##################"
            echo
            MAP=$(echo ${mapdirinfo[$(($currentMapIdx))]} | sed 's/+@+/ /g' | awk '{print $2}')

            cd $SERVER/$MAP
            cd ..

            # マップ変更のため再設定
            #configディレクトリ
            if [ -e $(pwd)/config/collapse.cfg ]; then #configファイルの存在を確認

                CONFIG=$(pwd)/config/collapse.cfg

            else

                if [ -e $SERVER/boot/config/collapse.cfg ]; then

                    CONFIG=$SERVER/boot/config/collapse.cfg

                else

                    echo
                    echo "マップコンフィグが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
                    echo
                    exit 1

                fi

            fi

            cd $LOCATION
            sleep 3

        fi

    # 単一マップ実行時
    else

        break

    fi

done