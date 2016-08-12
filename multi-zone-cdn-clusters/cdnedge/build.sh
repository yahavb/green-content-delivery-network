#!/bin/sh

if [ -z $1 ]
then
 echo Enter what you want to to: redeploy or checkin and redeploy-edge
fi

if [ "$1" = "deploy" ]
then
 echo Deploy the whole cluster
 gcloud container clusters delete greencdn
 gcloud container clusters create greencdn
 kubectl create -f ../cdn-edge-controller.yaml
 kubectl create -f ../cdn-edge-service.yaml
fi

if [ "$1" = "redeploy-edge" ]
then
 echo Redeploying frontend...
 docker rmi gcr.io/api-project-79515284030/cdnedge-image
 cont_id=`docker build . | grep Successfully | awk '{print $NF}'`
 docker tag $cont_id gcr.io/api-project-79515284030/cdnedge-image
 gcloud docker push gcr.io/api-project-79515284030/cdnedge-image
 kubectl delete -f ../cdn-edge-controller.yaml
 kubectl create -f ../cdn-edge-controller.yaml
 kubectl delete -f ../cdn-edge-service.yaml
 kubectl create -f ../cdn-edge-service.yaml
fi

