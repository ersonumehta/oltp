#!/bin/bash
echo "starting deploy script"
pwd
ls -ltr
aws s3 cp s3://oltpartifacts-734836383818-us-east-1-an/oltp/oltp-0.0.1-SNAPSHOT.jar /tmp/
