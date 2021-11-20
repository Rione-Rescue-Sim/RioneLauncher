import subprocess
import errorClass as ERROR


def shell(cmd: str):
    if not cmd:
        ERROR("コマンドが指定されていません")
    cmdVal = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

    if cmdVal.returncode != 0:
        ERROR
        exit(1)

    return cmdVal.stdout.decode()
