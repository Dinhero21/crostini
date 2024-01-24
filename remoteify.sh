#!/usr/bin/env bash

LOCAL_DIRECTORY=$1

# Relative -> Absolute
LOCAL_DIRECTORY=$(realpath "$LOCAL_DIRECTORY")

# Ensure Directory Exists (Local)
mkdir -p "$LOCAL_DIRECTORY"

# Are 10 nibbles enough? This should give a chance of collision
# of about 1 trillion 99 billion 511 million 627 thousand 776
# which should be more then enough.
HASH=$(echo -n "$LOCAL_DIRECTORY" | sha1sum | head -c 10)

# Temporary directory that is parent to our intermediate ones
VOLATILE_DIRECTORY=/tmp/$HASH
mkdir -p "$VOLATILE_DIRECTORY"

# Un-cached expensive network directory
SSHFS_DIRECTORY=$VOLATILE_DIRECTORY/sshfs
mkdir -p "$SSHFS_DIRECTORY"

# Cached files
CACHE_DIRECTORY=$VOLATILE_DIRECTORY/cache
mkdir -p "$CACHE_DIRECTORY"

# SSH Server
DESTINATION=home

REMOTE_DIRECTORY=sshfs/$HASH

# Ensure Directory Exists (Remote)
ssh $DESTINATION "mkdir -p \"$REMOTE_DIRECTORY\""

# Transfer Files (Local -> Remote)
scp -pr "$LOCAL_DIRECTORY"/* $DESTINATION:$REMOTE_DIRECTORY

# Clear Local Files
rm -rf "$SSHFS_DIRECTORY"/*
rm -rf "$CACHE_DIRECTORY"/*
rm -rf "$LOCAL_DIRECTORY"/*

# Mirror Remote <-> Local (SSHFS)
sshfs $DESTINATION:$REMOTE_DIRECTORY "$SSHFS_DIRECTORY"

# Cache Files (from SSHFS, cached on CACHE, to LOCAL)
catfs $SSHFS_DIRECTORY $CACHE_DIRECTORY $LOCAL_DIRECTORY
