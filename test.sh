# !/bin/bash
function server_start(){
    touch agent.log
    touch server.log

    local DOCKER_SERVER_LOG=dockerServerLog.txt
    error_cnt=0

    # gnome-terminalが起動しない場合があるため、確実に起動を行う
    while true; do
        rm ${DOCKER_SERVER_LOG} 2>/dev/null
        touch ${DOCKER_SERVER_LOG}

        #サーバー起動
		# gnome-terminal --tab -x bash -c "
		gnome-terminal -x bash -c "

			echo -n 'serverStart' > ${DOCKER_SERVER_LOG}

			sleep 1

			#[C+ctrl]検知
			trap 'last2' {1,2,3}
			last2(){
				echo -en "\x01" > $LOCATION/.signal
				exit 1
			}

		" &


        if [[ $error_cnt -gt 10 ]]; then

            last

        fi

        sleep 1

        if [[ ! -z $(cat ${DOCKER_SERVER_LOG} | grep "serverStart") ]]; then

            # gnome-terminalの起動確認
            break

        else

			echo "ターミナルの起動ができませんでした"
			echo "再起動します"
            error_cnt=$error_cnt+1
            sleep 3
            continue

        fi

    done
}

server_start

