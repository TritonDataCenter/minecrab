#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

BACKUP_FILE='/var/tmp/minecraft-backup.tar.gz'

tar -xzf $MINECARFT_LOCATION $BACKUP_FILE
mmkdir -p $(dirname $REMOTE_FILE)
mput -f $BACKUP_FILE $REMOTE_FILE
