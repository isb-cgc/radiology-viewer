#!/bin/bash

set -x

VIEWER_VERSION=0.9
#SERVER_ADMIN=$1
#SERVER_NAME=$2
#SERVER_ALIAS=$3
BRANCH=$1
MACHINE_URL=$2
CONFIG_BUCKET=$3
WEBAPP=$4
PROJECT=$5

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
sudo apt-get -y update
sudo apt-get -y upgrade

wait_on_lock
### Install git
sudo apt-get -y install git

wait_on_lock
### Other installation/config/startup scripts are in the radiology-viewer repo
git clone --branch $BRANCH https://github.com/isb-cgc/radiology-viewer.git
cd ./radiology-viewer

wait_on_lock
### Install docker
#./build/install_docker.sh
install_docker

wait_on_lock
### Install docker-compose
./build/install_docker-compose.sh

export PATH=/snap/bin:$PATH
#echo $PATH
# Execute gcloud and gsutil to ensure that confif files which they create have
# dvproc as owner (not root)
ls -la $HOME
gcloud auth list
gcloud beta auth list
gsutil ls
docker --version
ls -la $HOME

wait_on_lock
###  Install ohif-viewer
./build/install_ohif.sh

### Automatically run a script on rebooting
crontab -l > mycron 
echo "@reboot $HOME/radiology-viewer/startup.sh $PROJECT $MACHINE_URL 2>&1 | tee $HOME/radiology-viewer/log.txt" >> mycron
crontab mycron
rm mycron

### Install nginx
./build/install_nginx.sh $CONFIG_BUCKET $MACHINE_URL

ls -la $HOME

#### Create the mount point for the DB and index, which we keep on separate images that survive replacing the VM
#sudo mkdir -p /mnt/disks/orthanc-db
#sudo mkdir -p /mnt/disks/orthanc-index
### Create the mount point for the DB which we keep on separate images that survive replacing the VM
sudo mkdir -p /mnt/disks/dicom-db

ls -la $HOME

### Install Tenable
./build/install_tenable.sh $CONFIG_BUCKET

### Install clamav
./build/install_clamav.sh

### Do the update/upgrade thing
sudo apt-get -y update
sudo apt-get -y upgrade

ls -la $HOME

### Reboot so that update/upgrade takes effect
sudo reboot
