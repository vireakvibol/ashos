#!/bin/sh

# If you are installing this on VirtualBox to test it out, set RAM bigger than
# 1024MB as otherwise it errors out (running out of cache/RAM space)

main() {
    if [ $(id -u) -ne 0 ]; then echo "Please run as root!"; exit 1; fi
    if [ -z "$HOME" ]; then HOME="/root" ; fi
    RELEASE="kinetic"
    prep_packages="debootstrap ntp tmux" # btrfs-progs

  # attempt to install and if errors sync time and database
    apt-get -y --fix-broken install $prep_packages
    [ $? ] && sync_time && echo "Please wait for 30 seconds!" && sleep 30 && fixdb && apt-get -y --fix-broken install $prep_packages

    configs
    #git clone http://github.com/ashos/ashos
    #git config --global --add safe.directory ./ashos # prevent fatal error "unsafe repository is owned by someone else"
    #cd ashos
    #/bin/bash ./src/prep/parted_gpt_example.sh $2
    #python3 setup.py $1 $2 $3
}

# Configurations
configs() {
    setfont Lat38-TerminusBold24x12 # /usr/share/consolefonts/
    echo "export LC_ALL=C LC_CTYPE=C LANGUAGE=C" | tee -a $HOME/.bashrc
    #echo "alias p='curl -F "'"sprunge=<-"'" sprunge.us'" | tee -a $HOME/.bashrc
    echo "alias p='curl -F "'"f:1=<-"'" ix.io'" | tee -a $HOME/.bashrc
    echo "alias d='df -h | grep -v sda'" | tee -a $HOME/.bashrc
    echo "setw -g mode-keys vi" | tee -a $HOME/.tmux.conf
    echo "set -g history-limit 999999" | tee -a $HOME/.tmux.conf
}

# Remove man pages (fixes slow man-db trigger)
fixdb() {
    add-apt-repository -y universe # ntp
    apt-get -y autoremove
    apt-get -y autoclean
    apt-get -y clean # Needed?
    apt-get -y remove --purge man-db # Fix slow man-db trigger
    apt-get -y update
    apt-get -y check # Needed?
}

# Sync time
sync_time() {
    if [ -x "$(command -v wget)" ]; then
        date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
    elif [ -x "$(command -v curl)" ]; then
        date -s "$(curl -I google.com 2>&1 | grep Date: | cut -d' ' -f3-6)Z"
    else
        echo "F: Syncing time failed! Neither wget nor curl available."
    fi
}

main "$@"; exit

