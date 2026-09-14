#!/usr/bin/env bash
screen_name=tiktok

set -eo pipefail


# Detect Docker, although variable should have been already set by Dockerfile
if [ -f /.dockerenv ] || grep -qa docker /proc/1/cgroup >/dev/null 2>&1;
then
  IN_DOCKER=1
fi

# Warn here rather than in start.sh, whose output ends up in the screen logfile
if [ -z "$IN_DOCKER" ] && [ -z "$STY" ]
then
    if { [ -z "${WEB_UI_USERNAME}" ] || [ -z "${WEB_UI_PASSWORD}" ]; } && [ ! -f ./.web_ui_auth ]
    then
        echo "WARNING: the Web UI on port 8000 will be UNAUTHENTICATED"
        echo "         export WEB_UI_USERNAME and WEB_UI_PASSWORD before running this script,"
        echo "         or create a .web_ui_auth file containing one line username:password"
    fi
fi

# If not in Docker and not already in screen → re-exec in screen
if [ -z "$IN_DOCKER" ] && [ -z "$STY" ]
then
    # we are not running in screen
    exec screen -dm -S ${screen_name} -L -Logfile ${screen_name}_$(date '+%d_%m_%Y_%H_%M_%S').log /bin/bash "$0";
    
else
    # we are running in screen or in Docker, provide commands to execute
    ./start.sh PROD "${CONFIG_FILE:-streamers_config.json}"
fi


