# -*- coding: utf-8 -*-

from signal import signal
import shellComanndClass as shell
import subprocess
# ファイル検索
import glob
import signal
# 行番号
import os
import time
import errorClass as ERROR

global killFilePath


def setup():
    serverList = subprocess.run(
        "find ~/ -type f -name '/boot/kill.sh' ", shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)


def kill(signum, frame):

    # if killFile.count <= 0:
    #     print(location)

    print(killFile)
    exit(1)
    # subprocess.call(["bash", killFile])


def serarchServerDir():
    serverList = shell.shell(
        "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print  | grep jars/rescuecore2.jar").split(sep="\n")
    print(serverList)
    # サーバ名のみを抜き出し
    for i in range(len(serverList)):
        serverList[i] = serverList[i].replace("/jars/rescuecore2.jar", "")
        serverList[i] = serverList[i][len(
            serverList[i]) - len(serverList[i].split(sep="/")[-1]):]

    print(serverList)


def main():
    signal.signal(signal.SIGINT, kill)
    serarchServerDir()


if __name__ == "__main__":
    main()
    exit(0)
