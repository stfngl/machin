#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "need root user"
    exit 1
fi

./setup/apt-get
./setup/docker

apt-get install -y ca-certificates curl
apt-get update
apt-get upgrade -y

./install/python3
./install/docker

apt-get autoremove -y
apt-get auto-clean -y
apt-get clean -y

echo "exit and restart wsl disto with 'PS C:\> wsl --terminate DISTRO'"
