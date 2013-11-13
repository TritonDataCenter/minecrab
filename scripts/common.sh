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

MINECRAFT_LOCATION="/opt/minecraft/server"
MANTA_PREFIX="/$MANTA_USER/public/minecraft"

function fatal {
    echo "$(basename $0): fatal error: $*" >&2
    exit 1
}

function manta_location {
    local SERVER_NAME=$1
    MANTA_LOCATION="$MANTA_PREFIX/$SERVER_NAME"
}
