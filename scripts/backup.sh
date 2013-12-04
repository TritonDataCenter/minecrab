#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

BACKUP_FILE='/var/tmp/minecrab-backup.tar.gz'

rm $BACKUP_FILE
cd $MINECRAB_LOCATION
echo "Bundling $SERVER_NAME..."
console "save-all"
console "save-off"
tar -czf $BACKUP_FILE . \
    --exclude=coremods \
    --exclude=logs \
    --exclude=mods \
    --exclude=*.jar
console "save-on"
echo "Putting $BACKUP_FILE to $REMOTE_FILE"
mmkdir -p $(dirname $REMOTE_FILE)
mput -f $BACKUP_FILE $REMOTE_FILE
mput -f $MINECRAB_LOCATION/server.properties $REMOTE_LOCATION/server.properties
mput -f $MINECRAB_LOCATION/server.config $REMOTE_LOCATION/server.config
mput -f $MINECRAB_LOCATION/white-list.txt $REMOTE_LOCATION/white-list.txt
