from os import read
import shellComanndClass as shell


class ServerClass:

    # サーバのリストを検索し、サーバ名を取得
    def __serverSearch(self) -> str:
        serverList = shell.shell(
            "find ~/ -maxdepth 4 -type d -name '.*' -prune -o -type f -print  | grep jars/rescuecore2.jar").split(sep="\n")
        # サーバ名のみを抜き出し
        for i in range(len(serverList)):
            serverList[i] = serverList[i].replace("/jars/rescuecore2.jar", "")
            serverList[i] = serverList[i][len(
                serverList[i]) - len(serverList[i].split(sep="/")[-1]):]

        return serverList[:-1]

    def serverSelect(self) -> str:
        serverList = self.__serverSearch()
        print(serverList)
        for i, servername in enumerate(serverList):
            print(str(i+1) + "\t" + servername)

        print("上のリストからサーバを選択してください\n>", end="")

        while 1:
            temp = str(input())
            if not str.isdecimal(temp):
                print("もう一度入力してください\n>", end="")
                continue

            if int(temp) >= 1 and int(temp) <= len(serverList):
                break

            else:
                print("もう一度入力してください\n>", end="")

            continue

        return str(serverList[int(temp)-1])
