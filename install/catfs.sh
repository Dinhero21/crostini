#!/usr/bin/env bash

sudo apt install build-essential pkg-config fuse libfuse-dev -y

./install/rust.sh

cargo install catfs
