#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

BACKUP_FILE='/var/tmp/minecraft-backup.tar.gz'

if mget -o $BACKUP_FILE $REMOTE_FILE 2>/dev/null; then
  #Unpack what we pulled down first.
  cd $MINECRAFT_LOCATION
  tar -xzf $BACKUP_FILE

  #Now download the other files on top of what we got- we treat those as the
  # latest.
  if mls $REMOTE_LOCATION/server.properties; then
    mget -o $MINECRAFT_LOCATION/server.properties $REMOTE_LOCATION/server.properties
  fi
  if mls $REMOTE_LOCATION/server.config; then
    mget -o $MINECRAFT_LOCATION/server.config $REMOTE_LOCATION/server.config
  fi
  if mls $REMOTE_LOCATION/white-list.txt; then
    mget -o $MINECRAFT_LOCATION/white-list.txt $REMOTE_LOCATION/white-list.txt
  fi
  chown -R minecraft:minecraft $MINECRAFT_LOCATION
else
  echo "Couldn't fetch backup from Manta."
  exit 1
fi
