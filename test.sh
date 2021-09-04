# !/bin/bash
AGENT=rionerescue
KILL="rcrs-server/boot"


AGENT=$(find ~/ -name ${AGENT} -type d 2>/dev/null | grep -v "docker")
KILL=$(find ~/ -name boot -type d 2>/dev/null | grep "${KILL}")

echo "AGENT: $AGENT"
echo "AGENT: $KILL"

cd $KILL
pwd

