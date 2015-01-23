![minecrab-banner](images/minecrab-banner.png)

- [What it does](#what-it-does)
- [Getting started](#getting-started)
- [Basic commands](#basic-commands)
- [Advanced commands](#advanced-commands)
- [How it works](#how-it-works)
- [What it costs](#what-it-costs)
- [Troubleshooting](#troubleshooting)
- [Notes](#notes)
- [License](#license)



## What it does

Minecrab provisions a fully configured Minecraft server on a [Joyent's Public
Cloud](http://www.joyent.com/products/compute-service), specifically on a
SmartOS virtual machine.  You can play on the server, invite friends, build
stuff, and so on. When you're finished playing and shut down the server,
Minecrab saves your world to the cloud [Joyent Manta Storage
Service](http://www.joyent.com/products/manta).

Next time you want to play, just have Minecrab provision your server again.
Your world will be there, just as you left it.

Note that we don't make any money off of the Minecrab software
directly, and you can run it in any compatible cloud (e.g. Telefonica
or private instances).

If you do choose to use it on our public virtual machine service, we
do charge users for our normal cloud hosting and storage costs.

See [What it costs](#what-it-costs) later in this README to find out
more about our virtual machine and storage charges.

Also see [minecrab.io](http://minecrab.io).

## Getting started

First you need to get your gear together.
This is the hardest part of the whole operation.
Then you can play.

### Get your gear together


1. Get the Minecraft software: [minecraft.net](http://minecraft.net)<br />
Minecrab makes it easy to run servers.
To play in them, you need to buy the software from Mojang.
1. Get a [Joyent Cloud](http://my.joyentcloud.com) or compatible account.<br />
You can sign up for a [free trial](https://my.joyentcloud.com/landing/signup/70180000000ShEu).
(The rest of this guide assumes that you're using a Joyent Cloud account.)
1. If you are on Mac OS X:
<br />
    1. Install node, npm, node-manta and smartdc tools using the [Mac OS X Installer](https://us-east.manta.joyent.com/manta/public/sdks/joyent-node-latest.pkg).
    1. Install the jsontool `sudo npm install jsontool -g`
    1. Install [git](http://git-scm.com)
2. Otherwise:
(Tested on Ubuntu 13.10. It will probably work on other platforms):
<br />
    1. Install [Node](http://nodejs.org/)
    1. Install [Manta](http://apidocs.joyent.com/manta/#getting-started)
    1. Install [CloudAPI](http://apidocs.joyent.com/cloudapi/#getting-started)
    1. Install the jsontool `sudo npm install jsontool -g`
    1. Install [git](http://git-scm.com)
    1. Make sure [ssh-agent](#problems-with-ssh-agent) is running and has access to your ssh key and password.
1. Set up your CloudAPI and Manta environment variables:
   Run these commands in a Terminal window.
   (Pro-tip: save them in a file for later use,
   and `source <filename>` to run them as needed,
   or put them in your `.bash_profile`.)

   ```
   export MANTA_USER=<your Joyent Cloud name>
   export MANTA_URL=https://us-east.manta.joyent.com
   export MANTA_KEY_ID=$(ssh-keygen -l -f ~/.ssh/id_rsa.pub | awk '{print $2}' | tr -d '\n')

   export SDC_URL=<URL of a Joyent Cloud datacenter> (see below)
   export SDC_ACCOUNT=<your Joyent Cloud name>
   export SDC_KEY_ID=$(ssh-keygen -l -f ~/.ssh/id_rsa.pub | awk '{print $2}' | tr -d '\n')
   ```

   Use the `MANTA_URL` as given. For `SDC_URL` choose the closest datacenter:

   ```
   https://us-east-1.api.joyentcloud.com
   https://us-west-1.api.joyentcloud.com
   https://us-sw-1.api.joyentcloud.com
   https://eu-ams-1.api.joyentcloud.com
   ```

   `MANTA_KEY_ID` and `SDC_KEY_ID` are fingerprints of one of your SSH keys in the Joyent Cloud.
   The `ssh-keygen` command just makes it easier to get your fingerprints.

1. Clone this repo

   ```
   git clone https://github.com/joyent/minecrab.git
   ```

### Now you can play


1. Create your first server

   ```
   cd minecrab
   bin/minecrab-launch <new server name>
   ```

1. Add players

   ```
   bin/minecrab-add-friends <server name> <minecraft friend name>
   ```

1. Play Minecraft

1. Put your server away

   ```
   bin/minecrab-shutdown <server name>
   ```

1. Time passes

1. Restore your server to play again

   ```
   bin/minecrab-launch <old server name>
   ```


## Basic commands

These are command-line commands you use to manage your server.


### minecrab-launch

```
minecrab-launch [-p first-player] [-f flavor] <server-name>
```

Create or restore the server named `server-name`.

If provided `first-player` is added to the white list.
This is useful when launching a server for this first time.

`flavor` lets you specify a Minecraft distribution.
Possible values are minecraft, craftbukkit, ftb_ultimate, and voltz.

### minecrab-shutdown

```
minecrab-shutdown [-Y] [-M] [-W] <server-name>
```
Saves the world to Manta,
tears down the Minecraft server,
and starts generating a map.

`-Y` shuts down without asking for confirmation.
This is useful if you're scripting the shutdown process.

`-W` shuts down without saving the world to Manta.
This is useful if you're shutting down and [annihilating](#minecrab-annihilate).

`-M` shuts down without generating a map.
This is useful if you you do not want to incur [job charges](#what-it-costs ).


### minecrab-add-friend

```
minecrab-add-friend <server-name> <player-name>
```

Adds `player-name` to `server-name`'s white list.

### minecrab-kick-friend

```
minecrab-kick-friend <server-name> <friend-name> [reason]
```

Removes `friend-name` from `server-name`'s white  list and
kicks them off the server. You can provide a `reason`.

### minecrab-list-friends

```
minecrab-list-friends <server-name>
```

Lists the players in `server-name`'s white list.


### minecrab-list

```
minecrab-list
```

Lists all the minecrab servers running in your Joyent account.
Running servers are listed first.
You can restart servers that are offline with the
[`minecrab-launch`](#minecrab-launch) command.
Use [`minecrab-annihilate`](#minecrab-annihilate) to
destroy a server forever.

```
$ bin/minecrab-list
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

### minecrab-backup

```
minecrab-backup <server-name>
```

Backs up `server-name`'s world to Manta.


### minecrab-copy

```
minecrab-copy <server-name> <copy-name>
```

Copies `server-name` to `copy-name`.
If `copy-name` exists,
you'll get a chance to cancel or overwrite the existing server.


```
$ minecrab-copy cigar pipe
Checking if server is up...
Taking latest backup of cigar...
tar: ./world/region/r.-1.0.mca: file changed as we read it
Copying cigar to pipe...
Done!
```

Now you can use [minecrab-launch](#minecrab-launch) to
launch the new server.

```
$ minecrab-launch pipe
Launching pipe ................... done
Server pipe running on 165.225.148.207 id: be9f2f8b-8716-4677-d98b-cf0d93762c18
Setting up...
Installing git...
Cloning repo...
Warning: Permanently added 'github.com,192.30.252.130' (RSA) to the list of known hosts.
Installing server...
Connect to server at 165.225.148.207!
```

### minecrab-annihilate

```
minecrab-annihilate <server-name>
```

Utterly and completely annihilates `server-name`.
If `server-name` is running,
you must [shut it down](#minecrab-shutdown) first.

This command removes the saved world from Manta.
Once the world is annihilated, you can never get it back.


### minecrab-get

```
minecrab-get <server-name>
```

Gets information about `server-name`.
If a [map](#minecrab-map) of the world is available,
its URL is listed here.

```
$ minecrab-get cigar
id:      eee95b34-dc8a-4b6e-cf5e-b1cad46cecdc
name:    ac9294e
image:   17c98640-1fdb-11e3-bf51-3708ce78e75a
memory:  4096 mb
disk:    134144 gb
dataset: sdc:sdc:base64:13.2.1
ip addr: 8.19.32.162
map:     http://us-east.manta.joyent.com/Joyent_Dev/public/minecrab/servers/cigar/map/view/index.html
manta:   /Joyent_Dev/public/minecrab/servers/cigar/server/world.tar.gz
```


### minecrab-map

```
minecrab-map <server-name>
```

Creates a map of the world in `server-name` and
makes it available through a URL.

The map is rendered on Manta.
A small world may take 15 minutes to map.
Larger worlds take longer to render.

```
$ minecrab-map  cigar
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
Use [minecrab-get](#minecrab-get) to get the URL of the map.



## Advanced commands

These commands let you work directly
with your Minecraft server
and with the instance that your server is on.

Be careful.

### minecrab-command

```
minecrab-command <server-name> <minecraft-command>
```

Runs a single Minecraft command as if you were at the console.


### minecrab-console

```
minecrab-console <server-name>
```

Logs in to the instance hosting `server-name` and
connects to the Minecraft server's console.

**WARNING** <br />
DO NOT use `Ctrl-C` to exit from the console,
or you will shut down your server.

Use `Ctrl-B d` instead.

###  minecrab-exec

```
minecrab-exec <server-name> <shell-command>
```

Run a single shell command (as root) on the instance hosting `server-name`.

### minecrab-login

```
minecrab-login <server-name>
```

Logs in as root to the instance hosting `server-name`.


## How it works

Minecrab uses SSH agent forwarding to give the instances it creates
access to your authorization.
If you look at the code in the `bin` directory,
you'll see that all calls to `ssh` use the `-A` switch.

In order for all this to work,
you must be using `ssh-agent`.
On OS X, SSH is set up to use agents by default.

If you're having trouble with `ssh-agent`,
see [Problems with SSH agent](#problems-with-ssh-agent)
in the Troubleshooting section.

To learn more about agent forwarding,
see Steve Freidl's
[An Illustrated Guide to SSH Agent Forwarding](http://www.unixwiz.net/techtips/ssh-agent-forwarding.html).

## What it costs

Using Minecrab on the Joyent Cloud service incurs three kinds of charges:

* Compute time charges while a Minecraft server is running on an instance
* Storage charges for your Minecraft world when it's offline
* Job charges for rendering a map of your world

### Compute charges

When you [launch](#minecrab-launch) a server
Minecrab provisions a SmartOS instance
using the [base64 13.2.1](http://wiki.joyent.com/wiki/display/jpc2/SmartMachine+Base#SmartMachineBase-13.2.1)
image
with 4 GB of RAM and 131 GB of disk space.

This virtual machine instance size is [billed](http://www.joyent.com/products/compute-service/pricing)
at $0.128 per hour.

When you run [minecrab-shutdown](#minecrab-shutdown),
the Minecraft server stops,
the instance that is hosting the Minecraft server is deleted,
and billing for the instance ends.

As long as you remember to shut down your instance,
you won't pay for an idle server.

### Storage charges

Storage for your Minecraft world on Manta
is [billed at $0.086 per GB per month](http://www.joyent.com/products/manta/pricing).
Most Minecraft worlds are less than 100 MB, which would be less than a penny a month.

### Job charges

Map rendering takes place on Manta using a 4 GB job.
This job is [billed](http://www.joyent.com/products/manta/pricing) at
$0.00016 * number of seconds of wall-clock time.

For example: <br />

* A 15-minute job costs $0.144.
* A two-hour job costs $1.152.

If you don't want to pay for map rendering,
use the `-M` option
in [minecrab-shutdown](#minecrab-shutdown).

Note that all prices are as of the writing of this guide.

## Troubleshooting

### Problems with SSH agent

To see if `ssh-agent` is running properly,
use `ssh-add`:

```
$ ssh-add -L
ssh-rsa AAAAB3N ... so much text ... PQ== /Users/yourname/.ssh/id_rsa
```

If you don't see your key,
you may need to add it like this:

```
$ ssh-add ~/.ssh/id_rsa
```

If you see something like:

```
$ ssh-add -L
Could not open a connection to your authentication agent.
```

You'll need to start `ssh-agent` with something like this:

```
$ eval $(ssh-agent -s)  # if you are using bash and related shells
... or ...
$ eval `ssh-agent -c`   # if you are using csh and related shells
```

### Killing minecrab servers that failed to start

There may be times when a minecrab server fails to come up.
Here's an example:

```
$ bin/minecrab-launch -p user persephone
Launching persephone.............................. Done!
Server persephone running on 72.2.119.193 id: 058b1756-ba7c-40a9-ef9c-a9e26019a64a
Setting up...
minecrab-launch: fatal error: Failed to execute echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config on 72.2.119.193
```

There's a good chance that the instance was created.
If you just leave it running, you'll get charged for it.

Find the machine you want to kill.
Use its tags to find the instances ID:

```
$ sdc-listmachines --tag "minecrab=*" | json -a id tags
17e4ab29-85d5-46a6-b246-f81c80e1c4c7 {
  "minecrab": "alcyone"
}
058b1756-ba7c-40a9-ef9c-a9e26019a64a {
  "minecrab": "persephone"
}
```

In this case we have two minecrab servers.
"Persephone" is the one that failed to launch,
so lets kill it.
Use `sdc-deletemachine` to delete the instance.
Then use `sdc-getmachine` to monitor its death.:

```
$ sdc-deletemachine 058b1756-ba7c-40a9-ef9c-a9e26019a64a
$ sdc-getmachine 058b1756-ba7c-40a9-ef9c-a9e26019a64a | json state
Running
$ sdc-getmachine 058b1756-ba7c-40a9-ef9c-a9e26019a64a | json state
Object is Gone (410)
```


## Credits

* [Minecraft Overviewer](https://github.com/overviewer/Minecraft-Overviewer) - The renderer we use.
* [aboron/minecraft-smartos-smf](https://github.com/aboron/minecraft-smartos-smf) - Used as the basis for running
  the minecraft server.
* [Minecraft](https://minecraft.net) Minecraft ®/TM & © 2009-2013 Mojang / Notch

## Notes

* The error `tar: ./world/region/r.-1.0.mca: file changed as we read it`
is benign. You can ignore it.
* The warning
`Warning: Permanently added 'github.com,192.30.252.130' (RSA) to the list of known hosts.`
is benign.
* The error `socket hang up` means that
we were unable to provision an instance for your server.
Try the command again.
* On Ubuntu 13 (and probably other Linuxes) there were Node.js build
EACCES warnings that were safe to ignore.

## License

The code for Minecrab is MIT, see LICENSE.

## Minecraft EULA

Minecrab will automatically agree to the Minecraft EULA on your behalf.  By
using Minecrab you are implicitly agreeing to the Minecraft EULA.  That can be
found here:

https://account.mojang.com/documents/minecraft_eula
