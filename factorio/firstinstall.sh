#!/bin/bash

fileName=$1

cd factorio/update-folder/ && tar -xf $1

cd ../

cp -rf update-folder/factorio/* ../factorio

rm -rf update-folder/*


