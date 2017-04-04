#!/usr/bin/env bash

if [[ -z $1 ]];then
echo "give the image id";exit;
fi


imgId=$1
docker tag $imgId hbpmip/exaremelocal:latest
docker login
docker push hbpmip/exaremelocal