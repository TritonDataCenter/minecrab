#!/usr/bin/bash

set -e

echo "Installing dependencies..."
pkgin -y in openjdk7 tmux

echo "Preparing environment..."
mkdir -p /opt/minecraft/server
id -g minecraft >/dev/null || groupadd minecraft
id -u minecraft >/dev/null || useradd -s /bin/sh -d /opt/minecraft/server -g minecraft minecraft
cp -p $(dirname $0)/../misc/server.properties $(dirname $0)/../server/
chown -R minecraft:minecraft /opt/minecraft/server
svccfg import $(dirname $0)/../svc/manifest/minecraft.xml
grep -q /opt/minecraft/bin /root/.profile || \
  echo "PATH=$PATH:/opt/minecraft/bin" >> /root/.profile

. $(dirname $0)/../bin/minecraft-server-env

cd /opt/minecraft/server
echo "Downloading the Minecraft server..."
case ${MC_SOURCE} in
  *.jar)
    curl -k -O ${MC_SOURCE} 2>/dev/null
  ;;
  *.zip)
    curl -k -o /var/tmp/${MC_SOURCE##*/} ${MC_SOURCE} 2>/dev/null
    unzip /var/tmp/${MC_SOURCE##*/}
    rm -f /var/tmp/${MC_SOURCE##*/}
  ;;
esac

echo "Starting server for the first time..."
svcadm enable -s minecraft
