# Docker stack for Factorio hosting

## Usage

### Requirements

- Docker (Included in autoinstaller)
- Linux or OSX Host
- GIT
- At least a dualcore CPU with 2 GHz each core.

### Install

#### Create user for Stack

`$: sudo useradd -d /home/factorio -m factorio`

Then create a password for this user

`$: passwd factorio`

#### Add user to sudoers list

`$: sudo adduser factorio sudo`

#### Create Docker group

`$: sudo groupadd docker`

#### Give user docker rights 

`$: sudo gpasswd -a factorio docker`


#### Switch to user

Just type `$: login` in your terminal.

#### Clone Repo
Go to your desired folder like home:

`$: cd`

To get this repository local use the following command:

`$: git clone https://github.com/ribase/factorio-admin.git`

#### Configure

Please customize your `.env` file located in the base of this repo.

Please change the DB credentials located in this file

`MYSQL_ROOT_PASSWORD=root`
`MYSQL_DATABASE=mydb`
`MYSQL_USER=user`
`MYSQL_PASSWORD=userpass`

#### Autoinstaller

##### Ubuntu/Debian

You can use the enclosed "autoinstaller".

Go to the cloned repo:

`cd ~/`

Just type in `$: ./install`and follow the instructions.


##### RHEL/CentOS

NO SUPPORT

#### Manual install

##### Install docker

- Please visit [this](https://docs.docker.com/engine/installation/) link.

#### Install Server

Use the enclosed installer:

`./install`


