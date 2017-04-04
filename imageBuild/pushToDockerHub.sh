#!/usr/bin/env bash

if [[ -z $1 ]];then
exit;
fi


imgId=$1
docker tag $imgId hbpmip/exaremelocal:latest
docker login
docker push hbpmip/exaremelocal