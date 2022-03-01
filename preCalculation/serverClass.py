# from os import sendfile, times, kill
import os
import signal
import subprocess
from errorClass import ERROR, criticalError
import shellCommandClass as shell
from multiprocessing import Process, process
import time


class ServerClass:

    __serverPath = None
    __agentPath = None
    __mapPath = None

    # サーバのリストを検索し、サーバ名を取得
    def __serverSearch(self) -> str:
        serverList = shell.getResult(
            "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print  | grep jars/rescuecore2.jar").split(sep="\n")

        if len(serverList) <= 0:
            ERROR("サーバを発見できませんでした")
            raise criticalError

        # サーバのパスを取得
        for i in range(len(serverList)):
            serverList[i] = serverList[i].replace("/jars/rescuecore2.jar", "")

        return serverList[: -1]

    def serverSelect(self) -> str:
        serverList = self.__serverSearch()
        print("\n▼ サーバーリスト\n")

        for i, servername in enumerate(serverList):
            print(str(i+1) + "\t" + self.toName(servername))

        print("\n上のリストからサーバを選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(serverList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__serverPath = str(serverList[int(temp)-1])
        return self.__serverPath

    def getServerPath(self) -> str:
        return str(self.__serverPath)

    def toName(self, path: str):
        path = str(path)
        splitName = path.split("/")
        if len(splitName) > 0 and splitName[-1] != None:
            return splitName[-1]
        else:
            ERROR("パスから名前の抽出にエラー")
            raise criticalError

    def __agentSearch(self) -> str:
        agentList = shell.getResult(
            "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'").split(sep="\n")

        if len(agentList) <= 0:
            ERROR("エージェントを発見できませんでした")
            raise criticalError

        # エージェント名のみを抜き出し
        for i in range(len(agentList)):
            agentList[i] = agentList[i].replace("/jars/rescuecore2.jar", "")

        return agentList[: -1]

    def agentSelect(self) -> str:
        agentList = self.__agentSearch()
        print("\n▼ エージェントリスト\n")

        for i, servername in enumerate(agentList):
            print(str(i+1) + "\t" + self.toName(servername))

        print("\n上のリストからエージェントを選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(agentList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__agentPath = str(agentList[int(temp)-1])
        return self.__agentPath

    def getAgentPath(self) -> str:
        return str(self.__agentPath)

    def __mapSearch(self) -> str:
        if self.getServerPath == None:
            ERROR("サーバが指定されていません")
            raise criticalError

        mapList = shell.getResult(
            "find " + self.getServerPath() + "/maps -name scenario.xml | sed 's@scenario.xml@@g'").split(sep="\n")

        if len(mapList) <= 1:
            ERROR("マップを発見できませんでした")
            raise criticalError

        # マップ名のみを抜き出し
        for i in range(len(mapList)):
            mapList[i] = mapList[i].replace(
                "/jars/rescuecore2.jar", "").replace("/map/", "")

        return mapList[: -1]

    def mapSelect(self) -> str:
        mapList = self.__mapSearch()
        print("\n▼ マップリスト\n")

        for i, servername in enumerate(mapList):
            print(str(i+1) + "\t" + self.toName(servername))

        print("\n上のリストからマップ番号を選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(mapList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__mapPath = str(mapList[int(temp)-1])
        return self.__mapPath

    def getMapPath(self) -> str:
        return str(self.__mapPath)

    def start(self):
        print(self.getServerPath() + " " +
              self.toName(self.getMapPath()) + " " + self.getAgentPath())
        shell.bash("pre_calculation.sh " + self.getServerPath() +
                   " " + self.toName(self.getMapPath()) + " " + self.getAgentPath())


def subServerProcess(args: tuple):
    serverPath = args[0]
    agentPath = args[1]
    print("サブプロセス起動")

    shell.bash("chmod u+x gradlew")
    shell.bash(agentPath + "/compile.sh")
    shell.bash(agentPath +
               "/launch.sh -t 1,0,1,0,1,0 -h localhost -pre 1 ")
    APID = shell.getResult("$!")

    time.sleep(10)

    os.kill(int(APID), signal.SIGKILL)

    time.sleep(15)

    shell.sh(serverPath + "/kill.sh")

    shell.bash("chmod u+x gradlew")
    shell.bash(agentPath + "/launch.sh - all")
