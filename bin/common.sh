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

function find_ip {
    local NAME=$1
    IP=$(sdc-listmachines --tag minecraft=$NAME | json -ga primaryIp)
}

function server_console {
    local CONSOLE_CMD=$1
    server_execute "tmux send -t minecraft c-m \"$CONSOLE_CMD\" c-m"
}

function server_execute {
    local COMMAND=$1
    ssh -A root@$IP $COMMAND
}
