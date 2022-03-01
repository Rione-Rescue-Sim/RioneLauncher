import shellCommandClass as shell
import subprocess
import os

# shell.bash()
# shell.bash("")

killFilePath = None


def kill():
    if killFilePath != None:
        shell.sh(killFilePath + "/kill.sh")
    exit(1)


killFilePath = "/home/taka/git/rcrs-server" + "/boot"

kill()
