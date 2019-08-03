#!/bin/bash

set -x

CONFIG_BUCKET=$1
MACHINE_URL=$2

# First install nginx
sudo apt-get install -y nginx

sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx 

sudo certbot certificates

# If there is currently a certificate for this domain, use the cached configs
CERT=`sudo certbot certificates | grep "Certificate Path: /etc/letsencrypt/live/$MACHINE_URL/fullchain.pem" `
echo $CERT
if [ ! -z "$CERT" ]; then
    #echo Yes
    #exit

    # A certificate exists. Get the saved keys, etc. and nginx.conf
    sudo gsutil cp gs://$CONFIG_BUCKET/dicom_viewer/letsencrypt.tar letsencrypt.tar
    sudo tar xvf letsencrypt.tar -C /
    sudo rm letsencrypt.tar

    sudo gsutil cp gs://$CONFIG_BUCKET/dicom_viewer/nginx.conf /etc/nginx/nginx.conf
else
    #echo No
    #exit
    # Replace default config and insert domain name of this VM
    sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf
    sudo sed -ie "s/SERVER_NAME/$MACHINE_URL/" /etc/nginx/nginx.conf

    # Get the admin email address
    sudo gsutil cp gs://$CONFIG_BUCKET/ir_addr.txt .
    SERVER_ADMIN=`cat ir_addr.txt`
    sudo rm ir_addr.txt

    # Create a new cert. Note that Let's Encrypt strictly limits creating new certs on the
    # same domain to 10 in a one week period. 
    #sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive --staging
    sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive

    # Edit the letsencrypt config file so as to not enable TLS v1.0 and only use some strong ciphers     
    sudo sed -ie 's/TLSv1 / /' /etc/letsencrypt/options-ssl-nginx.conf
    sudo sed -ie 's/^ssl_ciphers.*/ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";/' /etc/letsencrypt/options-ssl-nginx.conf

    # Save the resulting /etc/letsencrypt.
    sudo tar cvf letsencrypt.tar /etc/letsencrypt
    sudo gsutil cp letsencrypt.tar gs://$CONFIG_BUCKET/dicom_viewer/letsencrypt.tar
    sudo rm letsencrypt.tar
    
    # Save the nginx config. It was modified by certbot
    sudo gsutil cp /etc/nginx/nginx.conf gs://$CONFIG_BUCKET/dicom_viewer/nginx.conf
fi
  
# Restart nginx
sudo nginx -s stop
sudo nginx
