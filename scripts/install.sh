#!/usr/bin/bash

set -e

. $(dirname $0)/common.sh

echo "Installing dependencies..."
pkgin -y in openjdk7 tmux

echo "Preparing environment..."
mkdir -p ${MINECRAFT_LOCATION}
id -g minecraft >/dev/null || groupadd minecraft
id -u minecraft >/dev/null || useradd -s /bin/sh -d ${MINECRAFT_LOCATION} -g minecraft minecraft
svccfg import $(dirname $0)/../svc/manifest/minecraft.xml
grep -q /opt/minecraft/bin /root/.profile || \
  cat - >>/root/.profile <<'EOF'

# Add path to minecraft tools
PATH=$PATH:/opt/minecraft/bin:/opt/local/sdc/bin
EOF
. /root/.profile

. $(dirname $0)/../bin/minecraft-server-env

cd ${MINECRAFT_LOCATION}
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
cd ${OLDPWD}

echo "Restoring a backup from Manta..."
if ! $(dirname $0)/restore.sh; then
  echo "New world will be initialized."
  cp -p $(dirname $0)/../misc/server.properties $(dirname $0)/../server/
fi

chown -R minecraft:minecraft ${MINECRAFT_LOCATION}

echo "Starting server for the first time..."
svcadm enable -s minecraft
