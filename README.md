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

Nearly at the end of the installation there is a prompt that have to be filled with your database creadentials.


`Creating the "app/config/parameters.yml" file`
`Some parameters are missing. Please provide them.`
 
This should be "db" except you changed it in your compose file.
`database_host (db):` 
Please keep this port except you changed it in your compose file.
`database_port (3306): `
Database name given in .`env`.
`database_name (mydb): `
Database-Username given in `.env`.
`database_user (user): `
Password given in `.env`.
`database_password (userpass):`

The following lines can be ignored.
`mailer_transport (smtp):` 
`mailer_host (127.0.0.1): `
`mailer_user (null): `
`mailer_password (null):` 
`secret (ThisTokenIsNotSoSecretChangeIt): ` 

