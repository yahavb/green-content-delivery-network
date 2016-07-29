#!/bin/sh

if [ -z $1 ]
then
 echo Enter what you want to to: redeploy or checkin and redeploy
fi

if [ "$1" = "deploy" ]
then
 echo Deploy the whole cluster
 kubectl create -f ../jmeter-job.yaml
fi

if [ "$1" = "redeploy" ]
then
 echo Redeploying...
 docker rmi gcr.io/api-project-79515284030/greencdn-loader-image
 cont_id=`docker build . | grep Successfully | awk '{print $NF}'`
 docker tag $cont_id gcr.io/api-project-79515284030/greencdn-loader-image
 gcloud docker push gcr.io/api-project-79515284030/greencdn-loader-image
 kubectl delete -f ../jmeter-job.yaml
 kubectl create -f ../jmeter-job.yaml
fi
