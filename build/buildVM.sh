#!/usr/bin/env bash
set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: ./$PROGNAME <prod|dev|test|uat>"
    exit 1;
fi

#arr = ['prod','dev','test','uat']
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
	SSL_BUCKET=web-app-deployment-files/$1
    else
	SSL_BUCKET=webapp-deployment-files-$1
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
	INDEX_DISK_NAME=orthanc-index-prod
    elif [ $1 == 'dev' ]
    then
	INDEX_DISK_NAME=orthanc-index-dev
    else 
	INDEX_DISK_NAME=orthanc-index
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

else
    echo "Usage: ./$PROGNAME <prod|dev|test|uat> <<external IP address>"
    exit 1;
fi

#if [ $1 == 'uat' ]
#then
#	MACHINE_TAG=
#else
#	MACHINE_TAG=http-server
#fi

MACHINE_TAG=dicom-viewer-vm
BASE_NAME=dicom-viewer
STATIC_IP_ADDRESS=$BASE_NAME-$1
MACHINE_NAME=$BASE_NAME-$1
MACHINE_DESC="dicom viewer server for "$1
DB_DISK_NAME=orthanc-db
DV_USER=dvproc
USER_AND_MACHINE=${DV_USER}@${MACHINE_NAME}
VM_REGION=us-west1
ZONE=$VM_REGION-b
IP_REGION=us-central1
IP_SUBNET=${IP_REGION}

SERVER_ADMIN=wl@isb-cgc.org
SERVER_ALIAS=www.mvm-dot-isb-cgc.appspot.com

#
# Create static external IP address if not already existan
addresses=$(gcloud compute addresses list --project $PROJECT|grep $STATIC_IP_ADDRESS)
if [ -z "$addresses" ]
then
    gcloud compute addresses create $STATIC_IP_ADDRESS --region $VM_REGION --project $PROJECT
fi
### Get the numeric IP addr as SERVER_NAME
ADDR_STRING=$(gcloud compute addresses describe $MACHINE_NAME --region $VM_REGION --project $PROJECT | grep address:)
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
#gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "${MACHINE_TYPE}" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1404-lts" --project "${PROJECT}" --address="${STATIC_IP_ADDRESS}"
gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "${MACHINE_TYPE}" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1710" --project "${PROJECT}" --address="${STATIC_IP_ADDRESS}"
#fi

#
# Add network tag to machine:
#
sleep 10
if [ -n "$MACHINE_TAG" ]
then
    gcloud compute instances add-tags "${MACHINE_NAME}" --tags "${MACHINE_TAG}" --project "${PROJECT}" --zone "${ZONE}"
fi

#
# Attach disks holding the Orthanc DB and index
#
gcloud compute instances attach-disk "${MACHINE_NAME}" --disk="${DB_DISK_NAME}" --device-name="${DB_DISK_NAME}" --project="${PROJECT}" --mode="ro" --zone="${ZONE}"
gcloud compute instances attach-disk "${MACHINE_NAME}" --disk="${INDEX_DISK_NAME}" --device-name="${INDEX_DISK_NAME}" --project="${PROJECT}" --mode="rw" --zone="${ZONE}"

#
# Copy and run a config script
#
sleep 10
gcloud compute scp $(dirname $0)/install_deps.sh "${USER_AND_MACHINE}":/home/"${DV_USER}" --zone "${ZONE}" --project "${PROJECT}"
gcloud compute ssh --zone "${ZONE}" --project "${PROJECT}" "${USER_AND_MACHINE}" -- '/home/'"${DV_USER}"'/install_deps.sh' "${SERVER_ADMIN}" "${SERVER_NAME}" "${SERVER_ALIAS}" "${SSL_BUCKET}" "${WEBAPP}"
