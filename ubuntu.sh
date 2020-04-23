#!/bin/bash

sudo apt-get update
sudo apt-get install clang

eval "$(curl -sL https://swiftenv.fuller.li/install.sh)"
which swift
swift --version

echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bash_profile
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(swiftenv init -)"' >> ~/.bash_profile
