#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

echo
echo 'WARNING: Do not ctrl-c or you will shut down your minecraft server.'
echo 'Use ctrl-b d to exit (let go of ctrl-b before hitting d).'
echo
echo -n 'Press any key to continue'
read -n 1 -r
sudo -u minecraft tmux attach -t minecraft
