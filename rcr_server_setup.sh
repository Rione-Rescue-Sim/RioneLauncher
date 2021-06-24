# !/bin/bash

original_clear(){
    for ((i=1;i<`tput lines`;i++))
    do
        echo ""
    done
    echo -e "\e[0;0H" #カーソルを0行目の0列目に戻す
}

ROOT_PATH=$(cd; pwd)

cd
echo 
echo "//////////////////////////////////////////////"
echo
gradle -v
echo 
echo "//////////////////////////////////////////////"
echo
echo "gradleがインストールされていることを確認してください"
echo "インストールされていない場合はCtrl+Cで中止してください"
echo "次に進む [ENTER]"
read 

original_clear
echo 
echo "//////////////////////////////////////////////"
echo
java -version
echo 
echo "//////////////////////////////////////////////"
echo
echo "javaのバージョンが11以上であることを確認してください"
echo "インストールされていない場合はCtrl+Cで中止してください"
echo "OpenJDK 11をインストールする場合は以下を実行してください"
echo
echo "sudo apt-get install openjdk-11-jdk"
echo
echo "次に進む [ENTER]"
read 

original_clear
echo 
echo "//////////////////////////////////////////////"
echo
echo "最新のrcrs_serverで必要な環境は"
echo
echo "gradle"
echo "OpenJDK Java 11+"
echo
echo "です"
echo "このシェルではインストールを行っても従来のrcrs-serverは上書きされません"
echo "これらを確認し、インストールを開始しますか？"
while true; do
    echo "インストールを開始-> confirm  |  中止-> n"
    echo -n ">"

    read canInstall

    if [[ $canInstall = "confirm" ]]; then
    
        canInstall="true"
        break

    elif [[ $canInstall = "n" ]]; then

        canInstall="no"
        break
    
    else

        echo "$canInstall　が入力されました"
        echo "再度入力してください"
    
    fi

done

if [[ $canInstall = "true" ]]; then

    cd
    cd git
    pwd
    mkdir temp
    cd temp

    git clone https://github.com/roborescue/rcrs-server.git
    cd rcrs-server
    ./gradlew clean
    ./gradlew completeBuild

    mv $ROOT_PATH/git/temp/rcrs-server/ $ROOT_PATH/git/rcrs-server_latest
    rm -rf $ROOT_PATH/git/temp

    echo "最新のrcrs-serverはrcrs-server_latestディレクトリ内に保存しました"
fi
