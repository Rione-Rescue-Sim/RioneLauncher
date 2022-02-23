#!/bin/bash

set -eo pipefail

ARG=$1

bash rioneLauncher_setup.sh $ARG

bash rioneLauncher_settingCheck.sh setting.txt

bash rioneLauncher_exec.sh