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

MINECRAFT_LOCATION="/opt/minecraft/server"

function fatal {
    echo "$(basename $0): fatal error: $*" >&2
    exit 1
}

function find_server {
    local NAME=$1
    SERV_RES=$(sdc-listmachines --tag minecraft=$NAME)
    IP=$(echo "$SERV_RES" | json -ga primaryIp)
    ID=$(echo "$SERV_RES" | json -ga id)
}

function server_console {
    local CONSOLE_CMD=$1
    server_execute "sudo -u minecraft tmux send -t minecraft c-m \"$CONSOLE_CMD\" c-m"
}

function server_execute {
    local COMMAND=$1
    #Since these will start and stop a lot, there's the possibility that we'll
    # get the same ip address with multiple launches and shutdowns.
    RESULT=$(ssh -o LogLevel=quiet -o StrictHostKeyChecking=no -o \
	     UserKnownHostsFile=/dev/null -A root@$IP $COMMAND)
}
