# -*- coding: utf-8 -*-

from signal import signal
import serverClass
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


def main():
    signal.signal(signal.SIGINT, kill)
    server = serverClass.ServerClass()
    print(server.serverSelect())


if __name__ == "__main__":
    main()
    exit(0)
