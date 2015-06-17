#!/bin/sh

command -v encfs >/dev/null 2>&1 || { echo >&2 "I require encfs but it's not installed.  Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }

SAFE=`pwd`/.safe
SAFEROOT=`pwd`/youkeepass

mkdir -p $SAFE
mkdir -p $SAFEROOT

encfs --standard "$SAFE" "$SAFEROOT"

cd "$SAFEROOT"

if [ ! -d "ruby-party" ]; then
    git clone https://github.com/conchyliculture/ruby-party
fi

cd ruby-party

ruby party.rb ssl

sleep 1

cd ../..

fusermount -u "$SAFEROOT"
