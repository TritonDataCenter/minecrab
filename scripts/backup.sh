#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

BACKUP_FILE='/var/tmp/minecrab-backup.tar.gz'

function up {
    mput -f $1 $2
    if [[ $? -ne 0 ]]; then
        fatal "Failed to upload $1 to $2"
    fi
}

rm $BACKUP_FILE
cd $MINECRAB_LOCATION
echo "Bundling $SERVER_NAME..."
console "save-all"
console "save-off"
tar -czf $BACKUP_FILE . \
    --exclude=coremods \
    --exclude=logs \
    --exclude=mods \
    --exclude-from <(find . -maxdepth 1 -type f -path "*.jar")
console "save-on"
echo "Putting $BACKUP_FILE to $REMOTE_FILE"
mmkdir -p $(dirname $REMOTE_FILE)
up $BACKUP_FILE $REMOTE_FILE
up $MINECRAB_LOCATION/server.properties $REMOTE_LOCATION/server.properties
up $MINECRAB_LOCATION/server.config $REMOTE_LOCATION/server.config
if [[ -f $MINECRAB_LOCATION/white-list.txt ]]; then
    up $MINECRAB_LOCATION/white-list.txt $REMOTE_LOCATION/white-list.txt
fi
if [[ -f $MINECRAB_LOCATION/white-list.txt.converted ]]; then
    up $MINECRAB_LOCATION/white-list.txt.converted $REMOTE_LOCATION/white-list.txt.converted
fi
if [[ -f $MINECRAB_LOCATION/whitelist.json ]]; then
    up $MINECRAB_LOCATION/whitelist.json $REMOTE_LOCATION/whitelist.json
fi
