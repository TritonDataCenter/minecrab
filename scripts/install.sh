#!/usr/bin/env bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

set -e

# Source for the first time, but respect SERVER_FLAVOR that might be passed on
. $(dirname $0)/common.sh
unset SERVER_FLAVOR

echo "Installing dependencies..."
pkgin -y in openjdk7 tmux >/dev/null

echo "Preparing environment..."
mkdir -p ${MINECRAFT_LOCATION}
id -g minecraft >/dev/null 2>&1 || groupadd minecraft 2>/dev/null
id -u minecraft >/dev/null 2>&1 || useradd -s /bin/sh -d ${MINECRAFT_LOCATION} -g minecraft minecraft 2>/dev/null
svccfg import $(dirname $0)/../svc/manifest/minecraft.xml
grep -q /opt/minecraft/bin /root/.profile || \
  cat - >>/root/.profile <<'EOF'

# Add path to minecraft tools
PATH=$PATH:/opt/minecraft/scripts:/opt/local/sdc/bin
EOF
. /root/.profile

echo "Restoring a backup from Manta..."
if ! $(dirname $0)/restore.sh; then
  echo "New world will be initialized."
  cp -p $(dirname $0)/../misc/server.properties $(dirname $0)/../server/
fi

if [[ -e $(dirname $0)/../server/server.config ]]; then
  . $(dirname $0)/../server/server.config
fi

# Use $1 for the preferred server flavor, unless set already
: ${SERVER_PREFERRED:=$1}

# Need to include again, so set the download variables
. $(dirname $0)/common.sh

SERVER_VERSION=${SERVER_FLAVOR#*-}
[[ ${SERVER_VERSION} == ${SERVER_FLAVOR} ]] && unset SERVER_VERSION

case ${SERVER_FLAVOR} in
  minecraft*)
    : ${SERVER_VERSION:=$(curl https://s3.amazonaws.com/Minecraft.Download/versions/versions.json 2>/dev/null|json latest.release)}
    SERVER_URL="https://s3.amazonaws.com/Minecraft.Download/versions/${SERVER_VERSION}/minecraft_server.${SERVER_VERSION}.jar"
  ;;
  craftbukkit*)
    : ${SERVER_VERSION:=latest}
    if [[ ${SERVER_VERSION} == "latest" ]]; then
      SERVER_URL="$(curl -I http://dl.bukkit.org/downloads/craftbukkit/get/latest-rb/craftbukkit.jar 2>/dev/null|sed -e 's/[[:cntrl:]]//'|awk '/^Location/{print $2}')"
      SERVER_VERSION="$(basename ${SERVER_URL}|sed 's/craftbukkit-//; s/\.jar$//')"
    fi
    SERVER_URL="http://repo.bukkit.org/content/groups/public/org/bukkit/craftbukkit/${SERVER_VERSION}/craftbukkit-${SERVER_VERSION}.jar"
  ;;
  ftb-ultimate*)
    : ${SERVER_VERSION:=1.1.2}
    SERVER_URL="http://www.creeperrepo.net/direct/FTB2/387719c04c0475b57ac038546cd8db7c/modpacks%5EUltimate%5E${SERVER_VERSION//\./_}%5EUltimate_Server.zip"
  ;;
  voltz*)
    : ${SERVER_VERSION:=2.0.4}
    SERVER_URL="http://mirror.technicpack.net/Technic/servers/voltz/Voltz_Server_v${SERVER_VERSION}.zip"
  ;;
  *)
    echo "Undefined Minecraft server flavor!"
    exit 1
  ;;
esac

echo "Downloading the Minecraft server..."
cd ${MINECRAFT_LOCATION}
case ${SERVER_URL} in
  *.jar)
    curl -k -o ${SERVER_JAR} ${SERVER_URL} 2>/dev/null
  ;;
  *.zip)
    curl -k -o /var/tmp/${SERVER_URL##*/} ${SERVER_URL} 2>/dev/null
    if [ -e server.properties ]; then cp -p server.properties{,.bak}; fi
    unzip /var/tmp/${SERVER_URL##*/}
    if [ -e server.properties.bak ]; then cp -p server.properties{.bak,}; fi
    rm -f /var/tmp/${SERVER_URL##*/}
  ;;
esac
cd ${OLDPWD}

cat - >${MINECRAFT_LOCATION}/server.config <<EOF
SERVER_PREFERRED="${SERVER_FLAVOR}"
SERVER_JAR="${SERVER_JAR}"
JAVA_OPTS="${JAVA_OPTS}"
EOF

chown -R minecraft:minecraft ${MINECRAFT_LOCATION}

echo "Starting server for the first time..."
svcadm enable -s minecraft
