#!/bin/bash

sudo apt-get update
sudo apt-get install clang

eval "$(curl -sL https://swiftenv.fuller.li/install.sh)"
which swift
swift --version
