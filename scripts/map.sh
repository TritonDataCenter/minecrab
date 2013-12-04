#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

source $(dirname $0)/common.sh

JOB_NAME="minecrab-map-$SERVER_NAME"

#if [ -z "$1" ]; then
#  REMOTE_FILE="/$MANTA_USER/public/minecrab/servers/$1/server/world.tar.gz"
#fi

#debug="yes please"

#set -x trace

function checkjob {
  JOB_ID=$(mjob list -s running -n "$JOB_NAME" | tr -d "/")
  if [ ! -z "$JOB_ID" ]; then
    fatal "Job already running with id $JOB_ID..."
  fi
}

function runjob {
  world=$REMOTE_FILE
  if [ -z "$world" ]; then
    fatal "Missing server name (REMOTE_FILE)"
  fi
  #TODO: Change back once the repo is public...
  #init_script="https://raw.github.com/joyent/minecrab/master/scripts/prepare_render.sh"
  init_script="https://us-east.manta.joyent.com/Joyent_Dev/public/minecrab_scripts/prepare_render.sh"
  #   --asset $map \
  echo "Kicking off job..."
  manta_req_uuid=$(\
    echo "$world" | mjob create \
      --memory=4096 \
      --init "curl $init_script | sh | tee /init.log" \
      --name "$JOB_NAME" \
      -m '/render.sh | tee /render.log' \
  )

  echo "Job $manta_req_uuid running!"
  if [ ! -n "$debug" ]; then
      exit 0
  fi

  job_status=$(mjob watch $manta_req_uuid)
  echo "==================================================="
  echo "status:"
  json <<<${job_status}

  job_outputs=$(mjob outputs $manta_req_uuid)
  if [ -n "$job_outputs" ]; then
    echo "==================================================="
    echo "outputs:"
    echo $job_outputs
    mget $job_outputs
    #json <<<$job_outputs
    #errobj=$(echo $job_outputs | json stderr)
    #if [ -n "$stdout_obj" ]; then
      #mget $stdout_obj
    #fi
  fi

  job_errors=$(mjob errors $manta_req_uuid)
  if [ -n "$job_errors" ]; then
    echo "==================================================="
    echo "errors:"
    json <<<$job_errors
    errobj=$(echo $job_errors | json stderr)
    if [ -n "$errobj" ]; then
      mget $errobj
    fi
  fi
}

checkjob
runjob
