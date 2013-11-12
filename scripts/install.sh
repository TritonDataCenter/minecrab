#!/usr/bin/bash

echo "Installing dependencies..."
pkgin -y in openjdk7 tmux

echo "Preparing environment..."
mkdir -p /opt/minecraft/server
id -g minecraft >/dev/null || groupadd minecraft
id -u minecraft >/dev/null || useradd -s /bin/sh -d /opt/minecraft/server -g minecraft minecraft
chown -R minecraft:minecraft /opt/minecraft/server
svccfg import $(dirname $0)/../svc/manifest/minecraft.xml

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
