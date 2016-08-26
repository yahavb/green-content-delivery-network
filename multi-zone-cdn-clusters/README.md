#Multi Zones CDN Clusters
##CDN Edge Control Plane
CDN deployments usually spans across multiple regions. Our approch will even extend it to across cloud boundaries. Such CDN services
provides geographic distribution and signifcantly improves the service availibility. 

This prototype uses Kuberentes 1.3 for achieving the multi zone deployments. The multi-zone cluster implemented below spans across three
regions:
```https://cloud.google.com/compute/docs/regions-zones/regions-zones```

* us-central1-b
* us-east1-b
* us-west1-b

In Kubernetes 1.3, our goal was to minimize the friction points and reduce the management/operational overhead associated with deploying 
a service with geographic distribution to multiple clusters. This post explains how to do this. 

Note: Though the examples used here leverage Google Container Engine (GKE) to provision Kubernetes clusters, they work anywhere you 
want to deploy Kubernetes.

Let’s get started. The first step is to create is to create Kubernetes clusters into 4 Google Cloud Platform (GCP) regions using GKE.
