#!/bin/bash

set -e

ARG=$1

bash rioneLauncher_setup.sh $ARG

bash rioneLauncher_settingCheck.sh setting.txt

bash rioneLauncher_exec.sh