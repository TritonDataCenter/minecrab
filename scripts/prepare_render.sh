#!/usr/bin/env bash

### Setup a Marlin zone to render Minecraft maps


#set -x trace
set -o errexit


OS=$(uname -s)
MINECRAFT_VERSION="1.7.2"

echo $OS
case $(uname -s) in
  "Darwin" )
    echo "OS X"
    pip install numpy
    DEST="./minecraft/versions/${MINECRAFT_VERSION}"
    ;;
  "SunOS" )
    echo "Solaris";
    DEST="./minecraft/versions/${MINECRAFT_VERSION}"
    if [ -z "$MANTA_USER" ]; then
      # Not on Manta
      pkgin -y install numpy
    fi
    ;;
  * )
    echo "Unknown OS"
    exit 1
    ;;
esac

if [ ! -d "$DEST" ]; then
  wget --no-check-certificate https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/${MINECRAFT_VERSION}.jar -P $DEST
fi

git clone git://github.com/overviewer/Minecraft-Overviewer.git overviewer

cd overviewer

# Python Image Tools
#
# get PIL (may already exist in OS and Manta)
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

cd ..

# Create config.py
cat > ./minecraft/cfg.py <<EOCONFIG
worlds['world1'] = './minecraft/worlds/world1/world'
outputdir = "./minecraft/render/world1"
# Try "smooth_lighting" over "lighting" for even better looking maps!
rendermode = "smooth_lighting"
texturepath = "./minecraft/versions/${MINECRAFT_VERSION}/${MINECRAFT_VERSION}.jar"
renders["render1"] = {
  'world': 'world1',
  'title': 'The world',
}
EOCONFIG

cat > ./render.sh <<EOF
mkdir -p ./minecraft/worlds/world1
mkdir -p ./minecraft/render/world1
tar xzf \$MANTA_INPUT_FILE --directory ./minecraft/worlds/world1
ls -l ./minecraft/worlds/world1
./overviewer/overviewer.py --config=./minecraft/cfg.py --simple-output -v -v

#OUTPUT_PATH="/$MANTA_USER/public/minecraft/filip/map/view"
OUTPUT_PATH=\$(dirname \$(dirname \$MANTA_INPUT_FILE))/map/view

./mputr ./minecraft/render/world1 "\${OUTPUT_PATH}"
EOF
chmod 755 ./render.sh

cat > ./mputr <<EOF
mputr () {
  owd=\$(pwd)
  local=\$1
  remote=\$2
  if [ -z "\$remote" ]; then
    echo "[ERROR] \$0: missing required options"
    exit 1
  fi
  cd "\$local"
  mmkdir -p "\$remote"
  # directories
  find . -type d | sort | xargs -n 1 -I {} mmkdir \$remote/{} || return 1
  # files
  find . -type f | xargs -n 1 -I {} mput -q \$remote/{} -f {} || return 1
  cd "\$owd"
  return 0
}
EOF
chmod 755 ./mputr
