import shellCommandClass as shell
import subprocess
import os

# shell.bash()
# shell.bash("")
shell.bash(os.getcwd() + "/test.sh")
print(os.getcwd())
