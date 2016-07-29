#!/bin/sh

if [ -z $1 ]
then
 echo Enter what you want to to: redeploy or checkin and redeploy-front or redeploy-redis
fi

if [ "$1" = "deploy" ]
then
 echo Deploy the whole cluster
 gcloud container clusters delete greencdn
 gcloud container clusters create greencdn
 kubectl create -f ../redis-master-controller.yaml
 kubectl create -f ../redis-master-service.yaml
 kubectl create -f ../redis-slave-controller.yaml
 kubectl create -f ../redis-slave-service.yaml
 kubectl create -f ../frontend-controller.yaml
 kubectl create -f ../frontend-service.yaml
fi

if [ "$1" = "redeploy-redis" ]
then
 echo Redeploying redis...
 #docker rmi gcr.io/api-project-79515284030/greencdn-image
 #cont_id=`docker build . | grep Successfully | awk '{print $NF}'`
 #docker tag $cont_id gcr.io/api-project-79515284030/greencdn-image
 #gcloud docker push gcr.io/api-project-79515284030/greencdn-image
 kubectl delete -f ../redis-master-controller.yaml
 kubectl delete -f ../redis-slave-controller.yaml
 kubectl create -f ../redis-master-controller.yaml
 kubectl create -f ../redis-slave-controller.yaml
fi
if [ "$1" = "redeploy-front" ]
then
 echo Redeploying frontend...
 docker rmi gcr.io/api-project-79515284030/greencdn-image
 cont_id=`docker build . | grep Successfully | awk '{print $NF}'`
 docker tag $cont_id gcr.io/api-project-79515284030/greencdn-image
 gcloud docker push gcr.io/api-project-79515284030/greencdn-image
 kubectl delete -f ../frontend-controller.yaml
 kubectl create -f ../frontend-controller.yaml
fi

