#!/bin/bash

set -x

CONFIG_BUCKET=$1
MACHINE_URL=$2

# First install nginx                                                                                         
sudo apt-get install -y nginx

# Replace default config and insert domain name of this VM                                                    
sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf
sudo sed -ie "s/SERVER_NAME/$MACHINE_URL/" /etc/nginx/nginx.conf

# Now install certbot                                                                                         
#sudo rm -rf /etc/letsencrypt

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx

# Get the admin email address                                                                                 
sudo gsutil cp gs://$CONFIG_BUCKET/ir_addr.txt .
SERVER_ADMIN=`cat ir_addr.txt`
sudo rm ir_addr.txt

# Ccreate a new cert. Note that Let's Encrypt strictly limits creating new certs on the                
# same domain to 10 in a one week period.                                                                     
sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive

# Edit the letsencrypt config file so as to not enable TLS v1.0                                               
sudo sed -ie 's/TLSv1 / /' /etc/letsencrypt/options-ssl-nginx.conf

# Restart nginx                                                                                               
sudo nginx -s stop
sudo nginx
