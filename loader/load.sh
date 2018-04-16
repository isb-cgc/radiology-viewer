#!/bin/bash

#set -x

while IFS='' read -r line || [[ -n "$line" ]]; do
#    echo "Text read from file: $line"
    if grep -Fxq $line ./done
    then
        echo $line " done"
    else
	echo "Loading " $line
	gsutil -m cp $line dcmzip.zip
	unzip -d dcmfiles dcmzip.zip
	python -t upload.py localhost 8042 dcmfiles orthanc orthanc
	if [ $? = 1 ];
	then
	    echo $line >> done
	else
	    echo "Failed to load " $line >> err.log
	    exit
	fi
	rm -rf dcmfiles
	rm dcmzip.zip
    fi
done < "$1"
