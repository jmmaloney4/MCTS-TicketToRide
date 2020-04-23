#!/bin/bash

sudo apt-get update
sudo apt-get install clang

eval "$(curl -sL https://swiftenv.fuller.li/install.sh)"
which swift
swift --version

echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bashrc
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(swiftenv init -)"' >> ~/.bashrc

source ~/.bashrc
