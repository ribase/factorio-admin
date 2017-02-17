#!/bin/bash

fileName=$1

cd update-folder/ && tar -xf $1

cd ../

cp -rf ./update-folder/factorio/* ../factorio

rm -rf ./update-folder/*

return true


