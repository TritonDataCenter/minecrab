## How to migrate your personal or other server world to Minecrab

Until we have an automagic command, here are the steps you need to take to
migrate your personal Minecraft world, or a world you have on another server,
to Minecrab.

First, you need to locate where the world files are for your server.  On Mac
OS X, these can be found at

```
$ ls -l "/Users/$USER/Library/Application Support/minecraft/saves/"
total 0
drwxr-xr-x  12 nate    staff  408 Dec  9 11:51 Large
drwxr-xr-x  12 nate    staff  408 Nov  1 13:59 Test
$ ls "/Users/$USER/Library/Application Support/minecraft/saves/Large"
DIM-1         data          level.dat_mcr players       session.lock
DIM1          level.dat     level.dat_old region        stats
```

On your server, you'll need to find where the server.properties file is located
and you can find the directory in that folder (demonstrating on a Minecrab
world):

```
$ find / -name server.properties
/opt/minecrab/misc/server.properties
/opt/minecrab/server/server.properties
$ ls /opt/minecrab/server/world
data  DIM-1  DIM1  level.dat  level.dat_old  players  region  session.lock
```

Once you've found the directory, you need to `tar` it up to easily transfer it
later.  Here's me bundling the `Large` directory:

```
$ cd "/Users/$USER/Library/Application Support/minecraft/saves/"
$ tar -czf Large.tar.gz Large/
$ ll Large.tar.gz
-rw-r--r--  1 nate    staff  70224036 Dec 13 14:32 Large.tar.gz
```

Now launch a Minecrab server with whatever name you want:

```
$ minecrab-launch large
```

When it is running, you can either scp the file to the server directly:

```
$ scp Large.tar.gz root@[server ip address]:/var/tmp
```

Or upload it to Manta and download it when you log in.  Either way, get that
file to `/var/tmp` on your newly launched minecrab server.

Now log into your minecrab server:

```
$ minecrab-login Large
```

Now make sure that file is where it should be:

```
[root@0b9276f9-5d4f-4a1a-9c82-cf189f134ce0 ~]# ll /var/tmp
total 5126
-rw-r--r-- 1 root root 5129854 Dec 13 22:39 Large.tar.gz
```

Now we're going to shut down the Minecraft server, replace the files, and
start the server back up.  Here we go:

```
#Disable the Minecraft server
$ svcs | grep minecraft
online         22:24:35 svc:/application/minecraft:default
$ svcadm disable minecraft
$ svcs | grep minecraft

# Become the minecraft user to get the permissions right on the extracted files.
$ su minecraft
$ bash

# Remove the old world
$ rm -rf /opt/minecrab/server/world

# Extract your world
$ cd /var/tmp
/var/tmp/$ tar -xvf Large.tar.gz
/var/tmp/$ rm Large.tar.gz

# Copy your world into place (note that the directory must be called world)
/var/tmp/$ mv Large world
/var/tmp/$ cp -r /var/tmp/world /opt/minecrab/server/

# Become root again
$ exit
$ exit
$ whoami
root

# Start the minecraft server
$ svcadm enable minecraft

# Watch the logs to make sure it is starting up successfully:
$ tail -f /opt/minecrab/server/logs/latest.log
```

Now don't forget to whitelist yourself (since this is a new server), then join
the Minecraft game and see that your world is in order.
