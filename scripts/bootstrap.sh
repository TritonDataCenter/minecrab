#!/bin/bash

/opt/local/bin/pkgin -y in scmgit-base
cd /opt
/opt/local/bin/git clone git@github.com:joyent/minecrab.git
