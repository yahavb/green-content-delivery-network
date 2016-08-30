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

##CDN Edge Control Plane Build-out
###Clusters Bootstrap
```
gcloud container clusters create cdn-edg-us-central1-b --scopes cloud-platform --zone us-central1-b --num-nodes 6
gcloud container clusters create cdn-edg-us-west1-b --scopes cloud-platform --zone us-west1-b --num-nodes 3
gcloud container clusters create cdn-edg-us-east1-b --scopes cloud-platform --zone us-east1-b --num-nodes 6
```

###cluster config
In order to add cluster into the federation we require to create kubernetes cluster config and kubeconfig.

The ```cluster config``` is a Kubernetes cluster object and holds information required by the Kubernetes Federated Controller Manager to add a cluster to a federation.
The ```kubeconfig``` file is a standard Kubernetes configuration object that is used to provide API Server credentials to Kubernetes clients. You will need one kubeconfig file for each cluster in the federation.

####kubeconfig
Load the kubeconfig from each cluster created before

```
gcloud container clusters get-credentials cdn-edg-us-central1-b --zone=us-central1-b
gcloud container clusters get-credentials cdn-edg-us-east1-b --zone=us-east1-b
gcloud container clusters get-credentials cdn-edg-us-west1-b --zone=us-west1-b
```

Listing the configs:
```
for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done
```

####Generating cluster config
We are going to create a kubeconfig file for each cluster and update the serverAddress field in the cluster manifest. In case there are an already exsting kubeconfig file it is requirest to remove/unset them.

```
for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do kubectl config unset contexts.$c;done
for c in $(kubectl config view -o jsonpath='{.clusters[*].name}');do kubectl config unset clusters.$c; done
for c in $(kubectl config view -o jsonpath='{.users[*].name}');do kubectl config unset users.$c; done
kubectl config unset current-context
```

#####For each cluster do:
```
kubectl config use-context $THE CONFIG CREATED ABOVE
serverAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
sed -i "s|SERVER_ADDRESS|${serverAddress}|g" clusters/*.yaml
kubectl config view --flatten --minify > kubeconfigs/*/kubeconfig
```

#### Register a DNS entry for the conrol plane
```
gcloud dns managed-zones create federation \
  --description "Green CDN PoC" \
  --dns-name cdn-edge.green.cloudfederation.com
```

## Provision Federated Control Plane

The Kubernetes federated control plane consists of two services:

* federation-apiserver
* federation-controller-manager

List all contexts in your local kubeconfig:

```
for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done
```

Both services need to run in a host Kubernetes cluster. Use the gce-us-central1 cluster as the host cluster.

```
kubectl config use-context gke_hightowerlabs_us-central1-b_gce-us-central1
```

> Your context names will be different. Replace hightowerlabs with your GCP project name. 

### Federation Namespace

The Kubernetes federation control plane will run in the federation namespace. Create the federation namespace using kubectl:

```
kubectl create -f ns/federation.yaml
```

### Federated API Server Service

The federated controller manager must be able to locate the federated API server when running on the host cluster.

```
kubectl create -f services/federation-apiserver.yaml
```

Wait until the `EXTERNAL-IP` is populated as it will be required to configure the federation-controller-manager.

```
kubectl --namespace=federation get services 
```
```
NAME                   CLUSTER-IP      EXTERNAL-IP    PORT(S)   AGE
federation-apiserver   10.119.242.80   XX.XXX.XX.XX   443/TCP   1m
```

### Federation API Server Secret

In this section you will create a set of credentials to limit access to the federated API server.

Edit known-tokens.csv to add a token to the first column of the first line. This token will be used to authenticate Kubernetes clients.

```
XXXXXXXXXXXXXXXXXXX,admin,admin
```

#### Create the federation-apiserver-secrets

Store the `known-tokens.csv` file in a Kubernetes secret that will be accessed by the federated API server at deployment time.

```
kubectl --namespace=federation \
  create secret generic federation-apiserver-secrets \
  --from-file=known-tokens.csv
```

```
kubectl --namespace=federation \
  describe secrets federation-apiserver-secrets
```

### Federation API Server Deployment

Get the federated API server public IP address.

```
advertiseAddress=$(kubectl --namespace=federation get services federation-apiserver \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Edit `deployments/federation-apiserver.yaml` and set the advertise address for the federated API server.

```
sed -i "" "s|ADVERTISE_ADDRESS|${advertiseAddress}|g" deployments/federation-apiserver.yaml
```

Create the federated API server in the host cluster:

```
kubectl create -f deployments/federation-apiserver.yaml
```

#### Verify

```
kubectl --namespace=federation get deployments
```
```
NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
federation-apiserver   1         1         1            0           7s
```

```
kubectl --namespace=federation get pods
```
```
NAME                                   READY     STATUS    RESTARTS   AGE
federation-apiserver-116423504-4mwe8   2/2       Running   0          13s
```

### Federation Controller Manager Deployment

#### Create the Federated API Server Kubeconfig

The federation-controller-manager needs a kubeconfig file to connect to the federation-apiserver.

Get the federated API server public IP address:

```
advertiseAddress=$(kubectl --namespace=federation get services federation-apiserver \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Use the `kubectl config` command to build up a kubeconfig file for the federated API server:

```
kubectl config set-cluster federation-cluster \
  --server=https://${advertiseAddress} \
  --insecure-skip-tls-verify=true
```

```
kubectl config set-credentials federation-cluster \
  --token=changeme
```

> The `--token` flag must be set to the same token used in the known-tokens.csv.

```
kubectl config set-context federation-cluster \
  --cluster=federation-cluster \
  --user=federation-cluster
```

Switch to the `federation-cluster` context and dump the federated API server credentials:

```
kubectl config use-context federation-cluster
```

```
kubectl config view --flatten --minify > kubeconfigs/federation-apiserver/kubeconfig
```

#### Create the Federated API Server Secret

Switch to the host cluster context and create the `federation-apiserver-secret`, which holds the kubeconfig for the federated API server used by the Federated Controller Manager.

```
kubectl config use-context gke_hightowerlabs_us-central1-b_gce-us-central1
```

```
kubectl create secret generic federation-apiserver-secret \
  --namespace=federation \
  --from-file=kubeconfigs/federation-apiserver/kubeconfig
```

Verify

```
kubectl --namespace=federation describe secrets federation-apiserver-secret
```

#### Deploy the Federated Controller Manager

```
kubectl create -f deployments/federation-controller-manager.yaml
```

Wait for the `federation-controller-manager` pod to be running.

```
kubectl --namespace=federation get pods
```

```
NAME                                             READY     STATUS    RESTARTS   AGE
federation-apiserver-116423504-4mwe8             2/2       Running   0          12m
federation-controller-manager-1899587413-c1c1w   1/1       Running   0          16s
```

##### Adding Clusters

With the federated control plane in place we are ready to start adding clusters to our federation.

> kubectl 1.3.0 or later is required to work with a federated Kubernetes control plane. See the [prerequisites](#prerequisites) 

* cdn-edg-us-central1-b

```
kubectl --namespace=federation create secret generic cdn-edg-us-central1-b \
  --from-file=kubeconfigs/cdn-edg-us-central1-b/kubeconfig
```

```
kubectl --context=federation-cluster \
  create -f clusters/cdn-edg-us-central1-b.yaml
```

* cdn-edg-us-west1-b

```
kubectl --namespace=federation create secret generic cdn-edg-us-west1-b \
  --from-file=kubeconfigs/cdn-edg-us-west1-b/kubeconfig
```

```
kubectl --context=federation-cluster \
  create -f clusters/cdn-edg-us-west1-b.yaml
```

* cdn-edg-us-east1-b

```
kubectl --namespace=federation create secret generic cdn-edg-us-east1-b \
  --from-file=kubeconfigs/cdn-edg-us-east1-b/kubeconfig
```

```
kubectl --context=federation-cluster \
  create -f clusters/cdn-edg-us-east1-b.yaml
```
## Running Federated Workloads

Create a federated service object in the `federation-cluster` context.

```
kubectl --context=federation-cluster create -f services/nginx.yaml
```

Wait until the nginx service is propagated across all 4 clusters and the federated service is updated with the details. Currently this can take up to 5 mins to complete.


List all contexts in your local kubeconfig

```
for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done
```

View the nginx service in each Kubernetes cluster, which was created by the federated controller manager.

```
kubectl --context=$THE CONTEXT CREATED ABOVE get svc nginx
```
```
NAME      CLUSTER-IP     EXTERNAL-IP      PORT(S)   AGE
nginx     10.63.250.98   104.199.136.89   80/TCP    9m
```

### Create Nginx Deployments

```
kubectl --context="$THE CONTEXT CREATED ABOVE" \
  run nginx --image=nginx:1.11.1-alpine --port=80
```

```
kubectl --context="$THE CONTEXT CREATED ABOVE for -us-central1" \
  run nginx --image=nginx:1.11.1-alpine --port=80
```

```
kubectl --context=$THE CONTEXT CREATED ABOVE for -us-west1" \
  run nginx --image=nginx:1.11.1-alpine --port=80
```

```
kubectl --context="$THE CONTEXT CREATED ABOVE for -us-east1" \
  run nginx --image=nginx:1.11.1-alpine --port=80
```
