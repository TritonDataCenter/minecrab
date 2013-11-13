# Minecraft on Manta

Minecraft server on demand.

## What it does

## Getting started

1. Get a Minecraft account: [minecraft.net]
1. Get a Joyent Cloud account: [my.joyentcloud.com]
1. Set up your CloudAPI and Manta environment variables:

```
export MANTA_USER=<your Joyent Cloud name>
export MANTA_URL=https://us-east.manta.joyent.com
export MANTA_KEY_ID=<the fingerprint of one of your SSH keys in Joyent Cloud>
export SDC_URL=<URL of a Joyent Cloud datacenter> (see below)
export SDC_ACCOUNT=<your Joyent Cloud name>
export SDC_KEY_ID=<the fingerprint of one of your SSH keys in Joyent Cloud
```

1. Clone this repo:

```
git clone git@github.com:joyent/minecraft.git
```

1. Create your first server

```
cd minecraft
bin/minecraft-server-launch <server name> <minecraft name>
```

1. Play minecraft.
1. Put your minecraft server away:

```
bin/minecraft-server-shutdown <server name>
```

1. Restore your minecraft server:

```
bin/minecraft-launch-server <server name>
```


 


### Datacenters

For `SDC_URL` choose one of the following"

* https://us-east-1.api.joyentcloud.com
* https://us-west-1.api.joyentcloud.com
* https://us-sw-1.api.joyentcloud.com
* https://eu-ams-1.api.joyentcloud.com