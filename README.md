# Docker stack for Factorio hosting

## Usage

### Requirements

- Docker (Included in autoinstaller)
- Linux or OSX Host
- At least a dualcore CPU with 2 GHz each core.

### Install

#### Clone Repo
Go to your desired folder like home:

`$: cd`

To get this repository local use the following command:

SSH: `$: git clone git@github.com:ribase/factorio-admin.git`

HTTPS: `$: git clone https://github.com/ribase/factorio-admin.git`

#### Autoinstaller

##### Ubuntu/Debian

You can use the enclosed "autoinstaller".

Go to the cloned repo:

`cd ~/`

If you need to install docker and docker-compose:

`./install --docker`

If you dont need to install docker:

`./install`

##### RHEL/CentOS

NO SUPPORT

#### Manual install

##### Install docker

- Please visit [this](https://docs.docker.com/engine/installation/) link.

#### Install Server

Use the enclosed installer:

`./install`

