from os import read
from errorClass import ERROR
import shellComanndClass as shell


class ServerClass:

    __selectedServer = None

    # サーバのリストを検索し、サーバ名を取得
    def __serverSearch(self) -> str:
        serverList = shell.shell(
            "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print  | grep jars/rescuecore2.jar").split(sep="\n")

        if len(serverList) <= 0:
            ERROR("サーバを発見できませんでした")
            exit(1)

        # サーバ名のみを抜き出し
        for i in range(len(serverList)):
            serverList[i] = serverList[i].replace("/jars/rescuecore2.jar", "")
            serverList[i] = serverList[i][len(
                serverList[i]) - len(serverList[i].split(sep="/")[-1]):]

        return serverList[:-1]

    def serverSelect(self) -> str:
        serverList = self.__serverSearch()
        print("\n▼ サーバーリスト\n")

        for i, servername in enumerate(serverList):
            print(str(i+1) + "\t" + servername)

        print("\n上のリストからサーバを選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(serverList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__selectedServer = str(serverList[int(temp)-1])
        return self.__selectedServer

    def getServer(self) -> str:
        return self.__selectedServer


class agentClass:

    __selectedAgent = None

    def __agentSearch(self) -> str:
        agentList = shell.shell(
            "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'").split(sep="\n")

        if len(agentList) <= 0:
            ERROR("エージェントを発見できませんでした")
            exit(1)

        # エージェント名のみを抜き出し
        for i in range(len(agentList)):
            agentList[i] = agentList[i].replace("/jars/rescuecore2.jar", "")
            agentList[i] = agentList[i][len(
                agentList[i]) - len(agentList[i].split(sep="/")[-1]):]

        return agentList[:-1]

    def agentSelect(self) -> str:
        agentList = self.__agentSearch()
        print("\n▼ エージェントリスト\n")

        for i, servername in enumerate(agentList):
            print(str(i+1) + "\t" + servername)

        print("\n上のリストからエージェントを選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(agentList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__selectedAgent = str(agentList[int(temp)-1])
        return self.__selectedAgent

    def getAgent(self) -> str:
        return self.__selectedAgent


class mapClass:
    __selectedMap = None

    def __mapSearch(self) -> str:
        mapList = shell.shell(
            "find $SERVER/maps -name scenario.xml | sed 's@scenario.xml@@g'").split(sep="\n")

        if len(mapList) <= 0:
            ERROR("マップを発見できませんでした")
            exit(1)

        # マップ名のみを抜き出し
        for i in range(len(mapList)):
            mapList[i] = mapList[i].replace("/jars/rescuecore2.jar", "")
            mapList[i] = mapList[i][len(
                mapList[i]) - len(mapList[i].split(sep="/")[-1]):]

        return mapList[:-1]

    def mapSelect(self) -> str:
        mapList = self.__mapSearch()
        print("\n▼ マップリスト\n")

        for i, servername in enumerate(mapList):
            print(str(i+1) + "\t" + servername)

        print("\n上のリストからマップ番号を選択してください\n>", end="")

        while 1:
            temp = str(input())
            if str.isdecimal(temp):
                if int(temp) >= 1 and int(temp) <= len(mapList):
                    break

            print("もう一度入力してください\n>", end="")

        self.__selectedMap = str(mapList[int(temp)-1])
        return self.__selectedMap

    def getAgent(self) -> str:
        return self.__selectedMap
