#!/bin/bash

# $1 is list of zips in GCS. load1 copies each locally, unzips it, and loads each of the resulting DCMs
# into dcm4chee. If the log file contains the word "error", then the log file is appended to err.log

#set -x

while IFS='' read -r line || [[ -n "$line" ]]; do
#    echo "Text read from file: $line"
    if grep -Fxq $line ./done
    then
        echo $line " done"
    else
	echo "Loading " $line
	gsutil -m cp $line dcmzip.zip
	unzip -q -d dcmfiles dcmzip.zip
	docker run --rm --network=dcm4chee_default \
	       -v $PWD/dcmfiles:/tmp/dcmfiles dcm4che/dcm4che-tools:5.10.5 \
	       storescu -cDCM4CHEE@arc:11112 /tmp/dcmfiles &> log.log
	if grep -i -q error log.log; then
	   cp ./log.log >> ./err.log;
	fi
	rm log.log
#	python -t upload.py localhost 8042 dcmfiles orthanc orthanc
	RESULT=$?
	echo "Result=="$RESULT
#	if [ $RESULT = 1 ];
#	then
	    echo $line >> done
#	else
#	    echo "Failed to load " $line >> err.log
#	    exit
#	fi
	rm -rf dcmfiles
	rm dcmzip.zip
    fi
done < "$1"
