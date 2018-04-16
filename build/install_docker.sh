#!/bin/bash

set -x

sudo apt-get -y update

### Install docker
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

#sudo apt-get -y install --no-install-recommends \
#    apt-transport-https \
#    curl \
#    software-properties-common

#curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -   
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty edge"

#sudo add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \                                                                     
#   $(lsb_release -cs) \                                                                                                             
#   stable"

#sudo add-apt-repository \                                                                                                          
#   "deb https://packages.docker.com/1.12/apt/repo/ \                                                                               
#   ubuntu-$(lsb_release -cs) \                                                                                                     
#   main"                                                                                                                           

sudo apt-get update

#sudo apt-get -y install docker-engine                                                                                              
sudo apt-get -y install docker-ce

sudo usermod -aG docker $USER
