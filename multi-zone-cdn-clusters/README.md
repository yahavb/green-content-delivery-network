#Multi Zones CDN Clusters
##CDN Edge Control Plane
CDN deployments usually spans across multiple regions. Our approch will even extend it to across cloud boundaries. Such CDN services
provides geographic distribution and signifcantly improves the service availibility. 

This prototype uses Kuberentes 1.3 for achieving the multi zone deployments. The multi-zone cluster implemented below spans across three
regions(```https://cloud.google.com/compute/docs/regions-zones/regions-zones```):

* us-central1-b
* us-east1-b
* us-west1-b

The prototype leverges the Google Container Engine to provision Kubernetes clusters and relies on ```https://github.com/kelseyhightower/kubernetes-cluster-federation```
Few of the core requirments from the CDN edge control plane is discovery, load-balancing and failover. More spefically:
* Internal discovery between CDN instances (pods and docker containers in Kubernetes terms). Instances should be bale to connect across different cloud boundries and regions. 
* Users streaming clients can discover and query nearby CDN edges to stream content over http/s protocols.
* Optimal CDN edge load-balancing. end users should discover the optimal CDN edges that are (1) nearby, (2) less loaded and (3) healthy 
* Failover. In case of a sudden lack of green energy or general failure in a serving edge, the endpoint will failover to a healthy CDN edge instance. Failover should NOT rely on client wisdom but through DNS manipluation on the servcie end

##CDN Edge Data Plane
A CDN edge deployments includes an apache instacne that is preloaded with a range of static content. It is deployed using the federation control plane. 

###Structure
```/clusters``` stores the three regions cluster specifications. If need to be recreated serverAddress needs to be replaced with new address.

```/deployments``` stores the federation-apiserver that will be used for coordinating kubernetes API across clusters. Also, it includes the controller manager.

```/ns``` The control panel namespece, federation

```/services``` stores the federation-apiserver service and the data plane, the cdn-edge service.


