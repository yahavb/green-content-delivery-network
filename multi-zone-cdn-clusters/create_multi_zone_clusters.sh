#!/bin/sh
gcloud container clusters create cdn-edg-us-west-b --scopes cloud-platform --zone us-west1-b
gcloud container clusters create cdn-edg-us-central1-b --scopes cloud-platform --zone us-central1-b
gcloud container clusters create cdn-edg-us-east1-d --scopes cloud-platform --zone us-east1-d
