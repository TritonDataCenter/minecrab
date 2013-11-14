
# Hammerhead

Minecraft server on demand.


- [What it does](#what-it-does)
- [Getting started](#getting-started)
- [Basic commands](#basic-commands)
- [Advanced commands](#advanced-commands)
- [What it costs](#what-it-costs)
- [Notes](#notes)



## What it does

Hammerhead provisions a fully configured Minecraft server
on a Joyent SmartOS instance. You can play on the server, invite friends,
build stuff, and so on. When you're finished playing and shut down the server,
Hammerhead saves your world to [Manta](http://www.joyent.com/products/manta).

Next time you want to play, just have Hammerhead provision your server again.
Your world will be there, just as you left it.

From the time that you [launch](#minecraft-server-launch) a server
to the time that you [shut it down](#minecraft-server-shutdown),
your account will be charged $0.128 per hour.
Learn more about [what it costs](#what-it-costs) to run a Minecraft server
this way.




## Getting started

1. Get a Minecraft account: [minecraft.net](http://minecraft.net)
1. Get a Joyent Cloud account: [my.joyentcloud.com](http://my.joyentcloud.com)
1. Install [Node](http://nodejs.org/).
1. Install [Manta](http://apidocs.joyent.com/manta/#getting-started)
1. Install [CloudAPI](http://apidocs.joyent.com/cloudapi/#getting-started)


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

## Basic commands

These are command-line commands you use to manage your server.


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
165.225.148.207 stopping   beans
8.19.32.162     running    cigar
n/a             offline    carrot
n/a             offline    filips
n/a             offline    darkplace
n/a             offline    filip
```

### minecraft-server-backup

```
minecraft-server-backup <server-name>
```

Backs up `server-name`'s world to Manta.


### minecraft-server-copy

```
minecraft-server-copy <server-name> <copy-name>
```

Copies `server-name` to `copy-name`.
If `copy-name` exists,
you'll get a chance to cancel or overwrite the existing server.


```
$ minecraft-server-copy cigar pipe
Checking if server is up...
Taking latest backup of cigar...
tar: ./world/region/r.-1.0.mca: file changed as we read it
Copying cigar to pipe...
Done!
```

Now you can use [minecraft-server-launch](#minecraft-server-launch) to
launch the new server.

```
$ minecraft-server-launch pipe
Launching pipe ................... done
Server pipe running on 165.225.148.207 id: be9f2f8b-8716-4677-d98b-cf0d93762c18
Setting up...
Installing git...
Cloning repo...
Warning: Permanently added 'github.com,192.30.252.130' (RSA) to the list of known hosts.
Installing server...
Connect to server at 165.225.148.207!
```

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
If a [map](#minecraft-server-map) of the world is available,
its URL is listed here.

```
$ minecraft-server-get cigar
id:      eee95b34-dc8a-4b6e-cf5e-b1cad46cecdc
name:    ac9294e
image:   17c98640-1fdb-11e3-bf51-3708ce78e75a
memory:  4096 mb
disk:    134144 gb
dataset: sdc:sdc:base64:13.2.1
ip addr: 8.19.32.162
map:     http://us-east.manta.joyent.com//Joyent_Dev/public/minecraft/cigar/map/view/index.html
manta:   /Joyent_Dev/public/minecraft/cigar/server/world.tar.gz
```


### minecraft-server-map

```
minecraft-server-map <server-name>
```

Creates a map of the world in `server-name` and
makes it available through a URL.

The map is rendered on Manta.
A small world may take 15 minutes to map.
Larger worlds take longer to render.

```
$ minecraft-server-map  cigar
Finding server...
Taking latest backup of cigar...
tar: ./world/region/r.-1.0.mca: file changed as we read it
Running map command from cigar...
added 1 input to 14e13f31-ea6d-eab7-f924-ace497431bff
Kicking off job...
Job 14e13f31-ea6d-eab7-f924-ace497431bff running!
Done!
```

Use `mjob get` to check on the progress of the mapping:

```
$ mjob get b042006a-bae8-6d77-a061-99f2abe12e37 | json state
running
. . .
$ mjob get b042006a-bae8-6d77-a061-99f2abe12e37 | json state
done
```

When the rendering job ends, the state will be done.
Use [minecraft-server-get](#minecraft-server-get) to get the URL of the map.



## Advanced commands

These commands let you work directly
with your Minecraft server
and with the instance that your server is on.

Be careful.

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

**WARNING** <br />
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

Logs in as root to the instance hosting `server-name`.


## What it costs

When you [launch](#minecraft-server-launch) a server
Hammerhead provisions a SmartOS instance
using the [base64 13.2.1](http://wiki.joyent.com/wiki/display/jpc2/SmartMachine+Base#SmartMachineBase-13.2.1)
image
with 4 GB of RAM and 131 GB of disk space.

This instance size is [billed](http://www.joyent.com/products/compute-service/pricing)
at $0.128 per hour.

When you [shut down](#minecraft-server-shutdown) the server,
billing for the instance ends.

Storage for the servers on Manta is [billed at $0.086 per GB per month](http://www.joyent.com/products/manta/pricing).
Most servers are less than 100 MB.

Map rendering takes place on Manta using a 4 GB job.
This job is [billed](http://www.joyent.com/products/manta/pricing) at
$0.00016 * number of seconds of wall-clock time.

For example: <br />

* A 15-minute job costs $0.144.
* A two-hour job costs $1.152.



## Notes

* The error `tar: ./world/region/r.-1.0.mca: file changed as we read it`
is benign. You can ignore it.
* The warning
`Warning: Permanently added 'github.com,192.30.252.130' (RSA) to the list of known hosts.`
is benign.
* The error `socket hang up` means that
we were unable to provision an instance for your server.
Try the command again.
