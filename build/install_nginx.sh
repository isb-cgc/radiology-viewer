#!/bin/bash

set -x

SSL_BUCKET=$1

sudo apt-get install -y nginx

### Get https certificates
sudo mkdir -p /etc/nginx/ssl
echo $SSL_BUCKET
sudo gsutil cp gs://$SSL_BUCKET/ssl/camic-viewer-apache.crt /etc/nginx/ssl/ssl.crt
sudo gsutil cp gs://$SSL_BUCKET/ssl/camic-viewer-apache.key /etc/nginx/ssl/ssl.key

sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf

sudo nginx
