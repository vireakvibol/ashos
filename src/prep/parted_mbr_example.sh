#!/bin/sh

if [ $(id -u) -ne 0 ]; then echo "Please run as root!"; exit 1; fi

if [ $# -eq 0 ]; then
    echo "No hard drive specified!"
    exit 1
fi

parted --align minimal --script $1 mklabel msdos unit MiB mkpart primary \
            ext4 1MiB 80% set 1 boot on mkpart primary ext4 80% 100%

