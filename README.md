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
