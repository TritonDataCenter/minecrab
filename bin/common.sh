#!/usr/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

#set -o xtrace
set -o pipefail

: ${MANTA_USER:?"MANTA_USER environment variable is missing"}
: ${MANTA_URL:?"MANTA_URL environment variable is missing"}
: ${MANTA_KEY_ID:?"MANTA_KEY_ID environment variable is missing"}
: ${SDC_URL:?"SDC_URL environment variable is missing"}
: ${SDC_ACCOUNT:?"SDC_ACCOUNT environment variable is missing"}
: ${SDC_KEY_ID:?"SDC_KEY_ID environment variable is missing"}

#Remove any trailing slash from manta url
case "${MANTA_URL}" in
    */) MANTA_URL=${MANTA_URL%/};;
esac

MINECRAB_LOCATION="/opt/minecrab/server"
MANTA_LOCATION="/$MANTA_USER/public/minecrab"
SERVERS_LOCATION="$MANTA_LOCATION/servers"
STATUS_LOCATION="$MANTA_URL$MANTA_LOCATION/index.html"
ME_LOCATION=$(dirname $(dirname ${BASH_SOURCE[0]}))

function fatal {
    echo -e "$(basename $0): fatal error: $*" >&2
    exit 1
}

function upload_website {
    mmkdir -p $MANTA_LOCATION
    ls $ME_LOCATION/webpage | \
        xargs -n 1 -I {} mput $MANTA_LOCATION/{} -f $ME_LOCATION/webpage/{}
}

function find_server {
    local SERVER_NAME=$1

    #First what's in manta...
    IN_MANTA=$(mls "$SERVERS_LOCATION/$SERVER_NAME" 2>/dev/null)
    if [ ! -z "$IN_MANTA" ]; then
        MAP_IN_MANTA="$SERVERS_LOCATION/$SERVER_NAME/map/view/index.html"
        MAP_URL="http://us-east.manta.joyent.com$SERVERS_LOCATION/$SERVER_NAME/map/view/index.html"
        MAP_FOUND=$(mls $MAP_IN_MANTA 2>/dev/null)
        if [ -z "$MAP_FOUND" ]; then
            MAP_URL="(not generated)"
        fi
        MANTA_OBJECT="$SERVERS_LOCATION/$SERVER_NAME/server/world.tar.gz"
        WHITELIST_OBJECT="$SERVERS_LOCATION/$SERVER_NAME/server/white-list.txt"
    fi

    #Now see if the server is running...
    SERVER_RES=$(sdc-listmachines --tag minecrab=$SERVER_NAME | json -ga)
    if [ ! -z "$SERVER_RES" ]; then
        STATUS="online"
        IP=$(echo "$SERVER_RES" | json primaryIp)
        ID=$(echo "$SERVER_RES" | json id)
        NAME=$(echo "$SERVER_RES" | json name)
        IMAGE=$(echo "$SERVER_RES" | json image)
        MEMORY=$(echo "$SERVER_RES" | json memory)
        DISK=$(echo "$SERVER_RES" | json disk)
        DATASET=$(echo "$SERVER_RES" | json dataset)
    elif [ ! -z "$IN_MANTA" ]; then
        STATUS="offline"
    else
        STATUS="notfound"
    fi
}

function server_console {
    local CONSOLE_CMD=$1
    server_execute "sudo -u minecraft tmux send -t minecraft c-m \"$CONSOLE_CMD\" c-m"
}

function server_execute {
    local COMMAND=$1
    if [ -z "$IP" ]; then
        fatal "No ip address.  Did you find_server?"
    fi
    #Since these will start and stop a lot, there's the possibility that we'll
    # get the same ip address with multiple launches and shutdowns.
    RESULT=$(ssh -o LogLevel=quiet -o StrictHostKeyChecking=no -o \
       UserKnownHostsFile=/dev/null -A root@$IP $COMMAND)
    if [[ $? -ne 0 ]]; then
        fatal "Failed to execute $COMMAND on $IP"
    fi
}

function server_execute_nofatal {
    local COMMAND=$1
    if [ -z "$IP" ]; then
        fatal "No ip address.  Did you find_server?"
    fi
    #Since these will start and stop a lot, there's the possibility that we'll
    # get the same ip address with multiple launches and shutdowns.
    RESULT=$(ssh -o LogLevel=quiet \
             -o StrictHostKeyChecking=no \
             -o UserKnownHostsFile=/dev/null \
             -o ConnectTimeout=5 \
             -A root@$IP $COMMAND)
    return $?
}

#http://stackoverflow.com/questions/3685970/bash-check-if-an-array-contains-a-value
function contains {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}
