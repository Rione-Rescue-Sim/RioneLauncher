#!/bin/bash

#使用するサーバーを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) SERVER="/home/$USER/git/rcrs-server"
#SERVER="/home/$USER/git/rcrs-server-master"
SERVER=$(find ~/ -name 'rcrs-server-1.5' -type d)

#使用するエージェントを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) AGENT="/home/migly/git/sample"
AGENT=$(find ~/ -name 'adf-sample-agent-java-1.1' -type d)

#使用するマップを固定したい場合は、例のようにmapsディレクトリからのパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) MAP="maps/gml/Kobe2013/map"
MAP="maps/gml/test/map"

#瓦礫の有無。固定する場合はtrue(瓦礫あり)もしくはfalse(瓦礫なし)を指定してください。
#固定したくない場合は空白で大丈夫です。
#brockade=false
brockade=true

#ループ数。何回同じ条件で実行するかを1以上の数字で指定してください。
#固定したくない場合は空白で大丈夫です。
##例) LOOP=10
LOOP=1

#１回のシミュレーションでのサイクル上限数。デフォルトは0。
#デバッグ用（一応使える）
LIMIT_CYCLE=0

#更新箇所
#何も出力がない場合、*** Time: ****を上書きする。true(上書き)もしくはfalse(従来通り)
OVERWRITING=true

# シャットダウンの設定
# true: シャットダウンが選択可能　false: 選択項目を表示しない
SHUTDOUW=false

# 自動アップデート有効: true, 無効: false
UPDATE=false


#/////////////////////////////////////////////////////////////
#ここから先は改変しないでくだせぇ動作が止まっても知らないゾ？↓

DEBUG_FLAG=false

# コンテナのユーザ名
# コンテナ内でgnome-terminalのkillで使用
DOCKER_USER_NAME=RDocker

SETTING_FILE_NAME=setting.txt

ROOT_PATH=$(
    cd
    pwd
)
CURRENT_PATH=$(pwd)

CurrentVer=2.2.2
os=$(uname)
LOCATION=$(
    cd $(dirname $0)
    pwd
)
phase=0
master_url="https://raw.githubusercontent.com/Rione-Rescue-Sim/RioneLauncher/main/rioneLauncher_2.2.2.sh"

echo $0
echo $LOCATION

if [[ ! -f $LOCATION/$(echo "$0") ]]; then
    echo 'スクリプトと同じディレクトリで実行してください。'
    exit 0
fi

#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

original_clear() {
    for ((i = 1; i < $(tput lines); i++)); do
        echo ""
    done
    echo -e "\e[0;0H" #カーソルを0行目の0列目に戻す
}


###########################################################################################################

original_clear

echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"
echo " □                                                                 □"
echo " □ 　Rione Launcher ($os)                                        □"
echo " □ 　　- レスキューシミュレーション起動補助スクリプト　Ver.$CurrentVer -  □"
echo " □                                                                 □"
echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"

#条件変更シグナル
ChangeConditions=0

if [[ ! -z $1 ]]; then
    if [[ $1 == 'debug' ]]; then
        DEBUG_FLAG='true'
        if [[ -z $2 ]]; then
            ChangeConditions=0
        else
            ChangeConditions=1
        fi
    else
        ChangeConditions=1
    fi
fi
if [[ $UPDATE == "true" ]]; then
    if [[ $DEBUG_FLAG == 'false' ]]; then
        update &
    fi
fi

echo
echo
echo "  ● ディレクトリ検索中..."

#環境変数変更
IFS=$'\n'

#サーバーディレクトリの登録
if [[ ${DEBUG_FLAG} == 'false' ]]; then

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

                count=$(($count + 1))

            done

            #文字数最大値取得
            maxservername=$(echo "${serverdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}')

            #ソート
            serverdirinfo=($(echo "${serverdirinfo[*]}" | sort -f))

            #エージェントリスト表示
            line=0

            echo
            echo "▼ サーバーリスト"
            echo

            for i in ${serverdirinfo[@]}; do

                servername=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $1}')
                serverdir=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $2}')

                printf "%3d  %s" $((++line)) $servername

                for ((space = $(($maxservername - ${#servername} + 5)); space > 0; space--)); do

                    printf " "

                done

                printf "%s\n" $(echo $serverdir | sed "s@/home/$USER/@@g" | sed "s@$servername@@g")

            done

            echo
            echo "上のリストからサーバーを選択してください。"
            echo "(※ 0を入力するとデフォルトになります)"

            while true; do

                read servernumber

                #入力エラーチェック
                if [ ! -z $(expr "$servernumber" : '\([0-9][0-9]*\)') ] && [ 0 -lt $servernumber ] && [ $servernumber -le $line ]; then

                    #アドレス代入
                    SERVER=$(echo ${serverdirinfo[$(($servernumber - 1))]} | sed 's/+@+/ /g' | awk '{print $2}')
                    break

                elif [ ! -z $(expr "$servernumber" : '\([0-9][0-9]*\)') ] && [ $servernumber -eq 0 ]; then

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

fi


#エージェントディレクトリの登録
if [[ ${DEBUG_FLAG} == 'false' ]]; then
    if [ -z $AGENT ] || [ $ChangeConditions -eq 1 ] || [ ! -f $AGENT/library/rescue/adf/adf-core.jar ]; then

        agentdirinfo=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g')) &>/dev/null

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

                agentname=$(echo $i | sed 's@/@ @g' | awk '{print $NF}')

                agentdirinfo[$count]=$agentname"+@+"$i"+@+"${#agentname}

                count=$(($count + 1))

            done

            #文字数最大値取得
            maxagentname=$(echo "${agentdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}')

            #ソート
            agentdirinfo=($(echo "${agentdirinfo[*]}" | sort -f))

            #エージェントリスト表示
            line=0

            echo
            echo "▼ エージェントリスト"
            echo

            for i in ${agentdirinfo[@]}; do

                agentname=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $1}')
                agentdir=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $2}')

                printf "%3d  %s" $((++line)) $agentname

                for ((space = $(($maxagentname - ${#agentname} + 5)); space > 0; space--)); do

                    printf " "

                done

                printf "%s\n" $(echo $agentdir | sed "s@/home/$USER/@@g" | sed "s@$agentname@@g")

            done

            echo
            echo "上のリストからエージェントを選択してください。"
            echo "(※ 0を入力するとデフォルトになります)"

            while true; do

                read agentnumber

                #入力エラーチェック
                if [ ! -z $(expr "$agentnumber" : '\([0-9][0-9]*\)') ] && [ 0 -lt $agentnumber ] && [ $agentnumber -le $line ]; then

                    #アドレス代入
                    AGENT=$(echo ${agentdirinfo[$(($agentnumber - 1))]} | sed 's/+@+/ /g' | awk '{print $2}')
                    break

                elif [ ! -z $(expr "$agentnumber" : '\([0-9][0-9]*\)') ] && [ $agentnumber -eq 0 ]; then

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
fi

#マップディレクトリの登録
if [[ ${DEBUG_FLAG} == 'false' ]]; then
    if [ ! -f $SERVER/$MAP/scenario.xml ] || [ $ChangeConditions -eq 1 ] || [ -z $MAP ]; then

        mapdirinfo=($(find $SERVER/maps -name scenario.xml | sed 's@scenario.xml@@g'))

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

                    mapname=$(echo ${mapdirinfo[$count]} | sed 's@/map/@@g' | sed 's@/@ @g' | awk '{print $NF}')
                    mapdir=$(echo ${mapdirinfo[$count]} | sed "s@$SERVER/@@g")

                    mapdirinfo[$count]=$mapname"+@+"$mapdir"+@+"${#mapname}

                else

                    unset mapdirinfo[$count]

                fi

                count=$((count + 1))

            done

            #ソート
            mapdirinfo=($(echo "${mapdirinfo[*]}" | sort -f))

            #マップ名最大値取得
            maxmapname=$(echo "${mapdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}')

            #マップ表示
            line=1
            echo
            echo "▼ マップリスト"
            echo

            toalMapCount=0

            for i in ${mapdirinfo[@]}; do

                mapname=$(echo $i | sed 's/+@+/ /g' | awk '{print $1}')
                mapdir=$(echo $i | sed 's/+@+/ /g' | awk '{print $2}')

                printf "%3d  %s" $line $mapname

                for ((space = $(($maxmapname - ${#mapname} + 5)); space > 0; space--)); do

                    printf " "

                done

                printf "%s\n" $(echo $mapdir | sed 's@/map/@@g' | sed "s@$mapname@@g" | sed 's@//@/@g')

                line=$(($line + 1))
                toalMapCount=$(($toalMapCount + 1))

            done
            echo " 99  すべてのマップ"
            echo
            echo "上のリストからマップ番号を選択してください(0を入力するとデフォルトを選択します)。"

            while true; do

                read mapnumber
                doAllMap="false"

                #入力エラーチェック
                if [ ! -z $(expr "$mapnumber" : '\([0-9][0-9]*\)') ] && [ 0 -lt $mapnumber ] && [ $mapnumber -le $line ]; then

                    #アドレス代入
                    MAP=$(echo ${mapdirinfo[$(($mapnumber - 1))]} | sed 's/+@+/ /g' | awk '{print $2}')
                    break

                elif [ ! -z $(expr "$mapnumber" : '\([0-9][0-9]*\)') ] && [ $mapnumber -eq 0 ]; then

                    if [ -f $SERVER/$MAP/scenario.xml ]; then

                        break

                    else

                        echo "デフォルトの設定が不正確です。0以外を入力してください。"

                    fi

                elif [ $mapnumber -eq 99 ]; then

                    echo "testを除くマップで実行します"
                    doAllMap="true"
                    #アドレス代入
                    MAP=$(echo ${mapdirinfo[0]} | sed 's/+@+/ /g' | awk '{print $2}')
                    break

                else

                    echo "もう一度入力してください。"
                    echo ""
                fi

            done

        else

            MAP=$(echo ${mapdirinfo[0]} | sed "s@$SERVER@@g")

        fi

    fi
fi

cd $SERVER/$MAP
cd ..

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

#瓦礫有無選択
defalutblockade=$(cat $CONFIG | grep "collapse.create-road-blockages" | awk '{print $2}')
if [[ ${DEBUG_FLAG} == 'false' ]]; then
    if [ ! $brockade = "false" ] && [ ! $brockade = "true" ] || [ $ChangeConditions -eq 1 ]; then

        original_clear

        echo
        echo "瓦礫を配置しますか？(y/n)"

        while true; do
            read brockadeselect

            #エラー入力チェック
            if [ $brockadeselect = "n" ]; then

                brockade="false"
                break

            fi

            if [ $brockadeselect = "y" ]; then

                brockade="true"
                break

            fi

            echo "もう一度入力してください。"

        done

        original_clear

    else

        if [ -z $brockade ]; then

            brockade=$defalutblockade

        fi

    fi
fi
#設定書き込み
if [ $brockade = "false" ]; then

    sed -i -e 's/true/false/g' $CONFIG
    brockademenu="なし"

else

    sed -i -e 's/false/true/g' $CONFIG
    brockademenu="あり"

fi

#ループ回数選択
if [[ ${DEBUG_FLAG} == "false" ]]; then
    if [ $LOOP -le 0 ] || [ -z $LOOP ] || [ $ChangeConditions -eq 1 ]; then

        original_clear

        echo
        echo "何回実行しますか？(1以上)"

        while true; do
            read loopselect

            #エラー入力チェック
            if [[ -z $(echo "$loopselect" | grep "^[0-9]\+$") ]]; then
                echo '数字を入力してください。'
                continue
            fi

            if [ $loopselect -le 0 ]; then
                echo '1以上の数字を入力してください。'
                continue
            fi

            LOOP=$loopselect
            break

        done

        original_clear

    fi
fi

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

# ブランチ取得
temp_path=$(pwd)
echo "temp_path: $temp_path"
cd $AGENT
current_branch="$(git status | grep 'ブランチ' | awk '{print $2}')"
cd $temp_path
temp_path=0

#環境変数変更
IFS=$' \t\n'

touch ${SETTING_FILE_NAME}
cat /dev/null > ${SETTING_FILE_NAME}
echo SERVER=${SERVER} >> ${SETTING_FILE_NAME}
echo AGENT=${AGENT} >> ${SETTING_FILE_NAME}
echo MAP=${MAP} >> ${SETTING_FILE_NAME}
echo BROCKADE=${brockade} >> ${SETTING_FILE_NAME}
echo LOOP=${LOOP} >> ${SETTING_FILE_NAME}