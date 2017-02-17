#!/bin/bash

fileName=$1

cd factorio/update-folder/ && tar -xf $1

cd ../

cp -rf factorio/update-folder/factorio/* factorio/

rm -rf factorio/update-folder/*

return true


