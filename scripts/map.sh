#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

#source $(dirname $0)/common.sh

REMOTE_FILE="/Joyent_Dev/public/minecraft/filip/server/world.tar.gz"

debug="yes please"

set -x trace

function runjob {
  world=$REMOTE_FILE
  if [ -z "$world" ]; then
    fatal "Missing server name (REMOTE_FILE)"
  fi
  init_script="https://raw.github.com/joyent/minecraft/master/scripts/prepare_render.sh?token=58699__eyJzY29wZSI6IlJhd0Jsb2I6am95ZW50L21pbmVjcmFmdC9tYXN0ZXIvc2NyaXB0cy9wcmVwYXJlX3JlbmRlci5zaCIsImV4cGlyZXMiOjEzODQ5MDgzODJ9--693c6e94b5c177c6304af5c8d29585a75795c7d1"
  #   --asset $map \
  manta_req_uuid=$(\
    mjob create \
      --init "curl $init_script | sh" \
      -m '/render.sh' \
  )
  echo $world | mjob addinputs $manta_req_uuid
  job_status=$(mjob watch $manta_req_uuid)
  if [ -n "$debug" ]; then
    echo "status:"
    json <<<${job_status}
  fi
  job_errors=$(mjob errors $manta_req_uuid)
  if [ -n "$job_errors" ]; then
    echo "errors:"
    json <<<$job_errors
    errobj=$(echo $job_errors | json stderr)
    if [ -n "$errobj" ]; then
      mget $errobj
    fi
  fi
}

runjob
