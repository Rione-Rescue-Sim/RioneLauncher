# !/bin/bash
DOCKER_SERVER_LOG=dockerServerLog.txt

rm ${DOCKER_SERVER_LOG}
touch ${DOCKER_SERVER_LOG}

gnome-terminal -x bash -c "

	echo -n "serverStart" > ${DOCKER_SERVER_LOG}

	#[C+ctrl]検知
	trap 'last2' {1,2,3}
	last2(){
		echo -en "\x01" > $LOCATION/.signal
		exit 1
	}

"
sleep 1

if [[ ! -z $(cat ${DOCKER_SERVER_LOG} | grep "serverStart") ]]; then
	echo
	echo "server done"
	echo
else
	echo "server error"
fi

