# -*- coding: utf-8 -*-

from signal import signal
import serverClass
import shellCommandClass as shell
import subprocess
# ファイル検索
import glob
import signal
# 行番号
import os
import time
import errorClass as ERROR

killFilePath = None


def setup():
    serverList = subprocess.run(
        "find ~/ -type f -name '/boot/kill.sh' ", shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)


def kill(signum, frame):
    if killFilePath != None:
        shell.sh(killFilePath + "/kill.sh")
    exit(1)
    # subprocess.call(["bash", killFile])


def main():
    signal.signal(signal.SIGINT, kill)
    print("st")

    try:
        server = serverClass.ServerClass()
        server.serverSelect()

        server.agentSelect()
        server.mapSelect()
        killFilePath = server.getServerPath() + "/boot/"
        server.start()

    except:
        kill()


if __name__ == "__main__":
    main()
    exit(0)
