#!/bin/bash

set -x

VIEWER_VERSION=0.9
SERVER_ADMIN=$1
SERVER_NAME=$2
SERVER_ALIAS=$3
SSL_BUCKET=$4
WEBAPP=$5

### See if anything is still holding lock on /var/lib/dpkg/lock
function wait_on_lock() 
{
    PID=$(sudo lsof -F p  /var/lib/dpkg/lock | grep p | sed 's/p//')
    while [ -n "$PID" ]
    do
	echo "Waiting on held lock"
	ps -f -p $PID
	sleep 5
	PID=$(sudo lsof -F p  /var/lib/dpkg/lock | grep p | sed 's/p//')
    done
}

function install_docker()
{
    wait_on_lock
    sudo apt-get -y update

    wait_on_lock
    sudo apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common

    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    wait_on_lock
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty edge"

    wait_on_lock
    sudo apt-get update

    wait_on_lock
    sudo apt-get -y install docker-ce

    sudo usermod -aG docker $USER
}

wait_on_lock
### Install git
sudo apt-get -y install git

wait_on_lock
### Other installation/config/startup scripts are in the radiology-viewer repo
git clone --branch pg https://github.com/bcli4d/radiology-viewer.git

cd ./radiology-viewer

wait_on_lock
### Install docker
./build/install_docker.sh

### Automatically run a script on rebooting
crontab -l > mycron 
echo "@reboot $HOME/radiology-viewer/startup.sh $VIEWER_VERSION $SERVER_ADMIN $SERVER_NAME $SERVER_ALIAS $WEBAPP" >> mycron
crontab mycron
rm mycron

### Install nginx
./build/install_nginx.sh $SSL_BUCKET

### Configure for Orthanc
#./build/config_orthanc.sh

### Install Tenable
./build/install_tenable.sh

### Install clamav
./build/install_clamav.sh

### Do the update/upgrade thing
sudo apt-get -y update
sudo apt-get -y upgrade

### Reboot so that update/upgrade takes effect
sudo reboot
