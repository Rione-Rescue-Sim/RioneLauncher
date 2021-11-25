import subprocess
from typing import Text
from errorClass import ERROR, criticalError


def getResult(cmd: str):
    # コマンドを実行し、出力を返す. エラーは無視する
    if len(cmd) <= 0:
        ERROR("コマンドが指定されていません")
        return

    cmdVal = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    return cmdVal.stdout.decode()


def run(cmd: str):
    # コマンドの実行を行う. 出力は返さない
    if len(cmd) <= 0:
        ERROR("コマンドが指定されていません")
        return

    error = subprocess.run(
        cmd, shell=True, stderr=subprocess.PIPE)
    if len(error.stderr) <= 1:
        ERROR("シェルコマンドがエラーを返しました")
        raise criticalError


def bash(scriptPath: str):
    if len(scriptPath) <= 0:
        ERROR("コマンドが指定されていません")
        return

    print(scriptPath)
    error = subprocess.run("bash " + scriptPath,
                           shell=True)


def sh(scriptPath: str):
    if len(scriptPath) <= 0:
        ERROR("コマンドが指定されていません")
        return

    subprocess.run(scriptPath,
                   shell=True)
