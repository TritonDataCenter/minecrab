#!/usr/bin/env bash

### Setup a Marlin zone to render Minecraft maps


#set -x trace


OS=$(uname -s)
MINECRAFT_VERSION="1.7.2"

echo $OS
case $(uname -s) in
  "Darwin" )
    echo "OS X"
    pip install numpy
    DEST="~/Library/Application Support/minecraft/versions/${MINECRAFT_VERSION}"
    ;;
  "SunOS" )
    echo "Solaris";
    if [ -z "$MANTA_USER" ]; then
      pkgin -y install numpy
    fi
    DEST="./minecraft/versions/${MINECRAFT_VERSION}"
    ;;
  * )
    echo "Unknown OS"
    exit 1
    ;;
esac

if [ ! -d "$DEST" ]; then
  wget https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/${MINECRAFT_VERSION}.jar -P $DEST/{$MINECRAFT_VERSION}.jar
fi

git clone git://github.com/overviewer/Minecraft-Overviewer.git overviewer

cd overviewer

# get PIL (may already exist in OS)
if [ ! -d "`pwd`/Imaging-1.1.7/libImaging" ]; then
  /usr/bin/curl -o imaging.tgz http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz
  tar xzf imaging.tgz
  rm imaging.tgz
fi
export PIL_INCLUDE_DIR="`pwd`/Imaging-1.1.7/libImaging"

# start with a clean place to work
python ./setup.py clean > /dev/null

# build MCO
python ./setup.py build #> /dev/null
