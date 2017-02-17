#!/bin/bash

fileName=$1

tar -cf /var/opt/factorio/factorio-update-backup.tar.gz /var/opt/factorio/

mkdir /var/opt/factorio/update-folder

cd /var/opt/factorio/update-folder/ ; tar -xf $1

cp -rf /var/opt/factorio/update-folder/factorio/* /var/opt/factorio/

rm -rf /var/opt/factorio/update-folder/*

return true


