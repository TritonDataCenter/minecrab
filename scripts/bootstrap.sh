#!/bin/bash

/opt/local/bin/pkgin -y in scmgit-base
cd /opt
/opt/local/bin/git clone https://github.com/joyent/minecrab.git
