import subprocess
from typing import Text
import errorClass as ERROR


def shell(cmd: str):
    if not cmd:
        ERROR("コマンドが指定されていません")

    cmdVal = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    return cmdVal.stdout.decode()
