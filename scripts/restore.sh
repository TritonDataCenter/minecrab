#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

BACKUP_FILE='/var/tmp/minecraft-backup.tar.gz'

if mget -o $BACKUP_FILE $REMOTE_FILE 2>/dev/null; then
  cd $MINECRAFT_LOCATION
  tar -xzf $BACKUP_FILE
  chown -R minecraft:minecraft $MINECRAFT_LOCATION
else
  echo "Couldn't fetch backup from Manta."
  exit 1
fi
