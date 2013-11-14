# Hammerhead

Minecraft server on demand.

## What it does

Hammerhead provisions a fully configured Minecraft server
on a Joyent SmartOS instance. You can play on the server, invite friends,
build stuff, and so on. When you're finished playing and shut down the server,
Hammerhead saves your world to [Manta](http://www.joyent.com/products/manta).

Next time you want to play, just have Hammerhead provision your server again.
Your world will be there, just as you left it.

## Getting started

1. Get a Minecraft account: [minecraft.net](http://minecraft.net)
1. Get a Joyent Cloud account: [my.joyentcloud.com](http://my.joyentcloud.com)


### Set up your CloudAPI and Manta environment variables:

```
export MANTA_USER=<your Joyent Cloud name>
export MANTA_URL=https://us-east.manta.joyent.com
export MANTA_KEY_ID=<the fingerprint of one of your SSH keys in Joyent Cloud>
export SDC_URL=<URL of a Joyent Cloud datacenter> (see below)
export SDC_ACCOUNT=<your Joyent Cloud name>
export SDC_KEY_ID=<the fingerprint of one of your SSH keys in Joyent Cloud
```

Use the `MANTA_URL` as given. For `SDC_URL` choose the closest datacenter:

```
https://us-east-1.api.joyentcloud.com
https://us-west-1.api.joyentcloud.com
https://us-sw-1.api.joyentcloud.com
https://eu-ams-1.api.joyentcloud.com
```


### Clone this repo

```
git clone git@github.com:joyent/minecraft.git
```

### Create your first server

```
cd minecraft
bin/minecraft-server-launch <server name> <minecraft name>
```

Play minecraft.

### Put your minecraft server away

```
bin/minecraft-server-shutdown <server name>
```

### Restore your minecraft server to play again

```
bin/minecraft-launch-server <server name>
```

## Basic Commands


### minecraft-server-launch

```
minecraft-server-launch <server-name> [player-name]
```

Create or restore the server named `server-name`.
If provided `player-name` is added to the white list.
This is useful when launching a server for this first time.

### minecraft-server-shutdown

```
minecraft-server-shutdown <server-name>
```
Saves the world to Manta and tears down the Minecraft server.


### minecraft-server-add-friend

```
minecraft-server-add-friend <server-name> <player-name>
```

Adds `player-name` to `server-name`'s white list.

### minecraft-server-kick-friend

```
minecraft-server-kick-friend <server-name> <friend-name> [reason]
```

Removes `friend-name` from `server-name`'s white  list and
kicks them off the server. You can provide a `reason`.

### minecraft-server-list-friends

```
minecraft-server-list-friends <server-name>
```

Lists the players in `server-name`'s white list.


### minecraft-server-list

```
minecraft-server-list
```

Lists all the Minecraft servers running in your Joyent account.
Running servers are listed first.
You can restart servers that are offline with the
[`minecraft-server-launch`](#minecraft-server-launch) command.
Use [`minecraft-server-annihilate`](#minecraft-server-annihilate) to
destroy a server forever.

```
$ bin/minecraft-server-list
IP              STATE      NAME
165.225.151.29  running    nate
165.225.149.97  running    joyent
165.225.151.19  running    absinthe
n/a             offline    beans
n/a             offline    carrot
n/a             offline    darkplace
n/a             offline    filip
n/a             offline    filips
n/a             offline    gin
n/a             offline    potato
```

### minecraft-server-backup

```
minecraft-server-backup <server-name>
```

Backs up `server-name`'s world to Manta.


### minecraft-server-annihilate

```
minecraft-server-annihilate <server-name>
```

Utterly and completely annihilates `server-name`.
If `server-name` is running,
you must [shut it down](#minecraft-server-shutdown) first.

This command removes the saved world from Manta.
Once the world is annihilated, you can never get it back.


### minecraft-server-get

```
minecraft-server-get <server-name>
```

Gets information about `server-name`.

```
$ bin/minecraft-server-get joyent
id:      159be633-edb2-6d31-c65c-8be8ad0b714e
name:    32a6119
image:   17c98640-1fdb-11e3-bf51-3708ce78e75a
memory:  4096 mb
disk:    134144 gb
dataset: sdc:sdc:base64:13.2.1
ip addr: 165.225.149.97
```


### minecraft-server-map

```
minecraft-server-map <server-name>
```

## Advanced Commands

### minecraft-server-command

```
minecraft-server-command <server-name> <minecraft-command>
```

Runs a single Minecraft command as if you were at the console.


### minecraft-server-console

```
minecraft-server-console <server-name>
```

Logs in to the instance hosting `server-name` and
connects to the Minecraft server's console.

**WARNING**
DO NOT use `Ctrl-C` to exit from the console,
or you will shut down your server.

Use `Ctrl-B d` instead.

###  minecraft-server-exec

```
minecraft-server-exec <server-name> <shell-command>
```

Run a single shell command (as root) on the instance hosting `server-name`.

### minecraft-server-login

```
minecraft-server-login <server-name>
```

Logs in to the instance hosting `server-name` as root.
