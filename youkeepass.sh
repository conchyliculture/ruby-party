#!/bin/sh

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
