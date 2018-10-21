#!/usr/bin/env bash
set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: ./$PROGNAME <prod|dev|test|uat>"
    exit 1;
fi

#Set this according to the branch being developed/executed
BRANCH=ohif-d4c-certbot

declare -a arr=('prod' 'dev' 'test' 'uat')
if [[ ${arr[*]} =~ $1 ]]
then
    declare -a arr1=('prod','dev')

    if [[ ${arr1[*]} =~ $1 ]]
    then
	PROJECT=isb-cgc
    else
	PROJECT=isb-cgc-$1
    fi

    declare -a arr2=('dev','prod')

    if [[ ${arr2[*]} =~ $1 ]]
    then
	CONFIG_BUCKET=web-app-deployment-files/$1
    else
	CONFIG_BUCKET=webapp-deployment-files-$1
    fi

    if [ $1 == 'prod' ]
    then
	WEBAPP=isb-cgc.appspot.com
    elif [ $1 == 'dev' ]
    then
	WEBAPP=mvm-dot-isb-cgc.appspot.com
    elif [ $1 == 'test' ]
    then
	WEBAPP=isb-cgc-test.appspot.com
    else 
	WEBAPP=isb-cgc-uat.appspot.com
    fi

    if [ $1 == 'prod' ]
    then
	INDEX_DISK_NAME=dicom-db
    elif [ $1 == 'dev' ]
    then
	INDEX_DISK_NAME=dicom-db
    else 
	INDEX_DISK_NAME=dicom-db
    fi

    if [ $1 == 'prod' ]
    then
	MACHINE_TYPE="n1-standard-4"
    elif [ $1 == 'dev' ]
    then
	MACHINE_TYPE="n1-standard-2"
    else 
	MACHINE_TYPE="n1-standard-1"
    fi

    if [[ ${arr1[*]} =~ $1 ]]
    then
	ATTACH_MODE="rw"
    else 
	ATTACH_MODE="rw"
    fi

else
    echo "Usage: ./$PROGNAME <prod|dev|test|uat> <<external IP address>"
    exit 1;
fi

MACHINE_TAGS=dicom-viewer-vm,http-server,ssh-from-whc,http-from-whc
BASE_NAME=dicom-viewer
STATIC_EXTERNAL_IP_ADDRESS=$BASE_NAME-$1
#STATIC_INTERNAL_IP_ADDRESS=$BASE_NAME-$1-internal
MACHINE_NAME=$BASE_NAME-$1
MACHINE_DESC="dicom viewer server for "$1
MACHINE_URL=$MACHINE_NAME.isb-cgc.org
DB_DISK_NAME=dicom-db
DB_DEVICE_NAME=dicom-db
INDEX_DEVICE_NAME=dicom-db
DV_USER=dvproc
USER_AND_MACHINE=${DV_USER}@${MACHINE_NAME}
VM_REGION=us-west1
ZONE=$VM_REGION-b
IP_REGION=${VM_REGION}
#IP_SUBNET=dicom

SERVER_ADMIN=wl@isb-cgc.org
SERVER_ALIAS=www.mvm-dot-isb-cgc.appspot.com

##
## Create static internal IP address if not already existant
#addresses=$(gcloud compute addresses list --project $PROJECT|grep $STATIC_INTERNAL_IP_ADDRESS)
#if [ -z "$addresses" ]
#then
#    gcloud compute addresses create $STATIC_INTERNAL_IP_ADDRESS --region $IP_REGION --project $PROJECT --subnet $IP_SUBNET
#fi
#### Get the numeric IP addr as SERVER_NAME
#ADDR_STRING=$(gcloud compute addresses describe $STATIC_INTERNAL_IP_ADDRESS --region $VM_REGION --project $PROJECT | grep address:)
#IFS=', ' read -r -a addr_string_array <<< "$ADDR_STRING"
##SERVER_NAME="${addr_string_array[1]}"

#
# Create static external IP address if not already existant
addresses=$(gcloud compute addresses list --project $PROJECT|grep $STATIC_EXTERNAL_IP_ADDRESS)
if [ -z "$addresses" ]
then
    gcloud compute addresses create $STATIC_EXTERNAL_IP_ADDRESS --region $IP_REGION --project $PROJECT
fi
### Get the numeric IP addr as SERVER_NAME
ADDR_STRING=$(gcloud compute addresses describe $STATIC_EXTERNAL_IP_ADDRESS --region $VM_REGION --project $PROJECT | grep address:)
IFS=', ' read -r -a addr_string_array <<< "$ADDR_STRING"
SERVER_NAME="${addr_string_array[1]}"

#
# Delete existing VM, then spin up the new one:
#
instances=$(gcloud compute instances list --project $PROJECT --filter="zone:(us-west1-b)"|grep $MACHINE_NAME)
if [ -n "$instances" ]
then
    gcloud compute instances delete -q "${MACHINE_NAME}" --zone "${ZONE}" --project "${PROJECT}"
fi
#gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "${MACHINE_TYPE}" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1710" --project "${PROJECT}" --address="${STATIC_EXTERNAL_IP_ADDRESS}" --private-network-ip="${STATIC_INTERNAL_IP_ADDRESS}" --network="${IP_SUBNET}"
gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "${MACHINE_TYPE}" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1804-lts" --project "${PROJECT}" --address="${STATIC_EXTERNAL_IP_ADDRESS}"
#fi

#
# Add network tag to machine:
#
sleep 10
if [ -n "$MACHINE_TAGS" ]
then
    gcloud compute instances add-tags "${MACHINE_NAME}" --tags "${MACHINE_TAGS}" --project "${PROJECT}" --zone "${ZONE}"
fi

#
# Attach disks holding the DICOM DB and index
#
gcloud compute instances attach-disk "${MACHINE_NAME}" --disk="${DB_DISK_NAME}" --device-name="${DB_DEVICE_NAME}" --project="${PROJECT}" --mode="${ATTACH_MODE}" --zone="${ZONE}"
if [ ${DB_DISK_NAME} != ${INDEX_DISK_NAME} ]
then
    gcloud compute instances attach-disk "${MACHINE_NAME}" --disk="${INDEX_DISK_NAME}" --device-name="${INDEX_DEVICE_NAME}" --project="${PROJECT}" --mode="rw" --zone="${ZONE}"
fi

#
# Copy and run a config script
#
sleep 10
gcloud compute scp $(dirname $0)/install_deps.sh "${USER_AND_MACHINE}":/home/"${DV_USER}" --zone "${ZONE}" --project "${PROJECT}"
while [ $? -ne 0 ]; do
    sleep 2
    gcloud compute scp $(dirname $0)/install_deps.sh "${USER_AND_MACHINE}":/home/"${DV_USER}" --zone "${ZONE}" --project "${PROJECT}"
done

gcloud compute ssh --zone "${ZONE}" --project "${PROJECT}" "${USER_AND_MACHINE}" -- '/home/'"${DV_USER}"'/install_deps.sh' "${BRANCH}" "${MACHINE_URL}" "${CONFIG_BUCKET}" "${WEBAPP}"
