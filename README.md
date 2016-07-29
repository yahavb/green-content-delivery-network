# greencdn
This is a simulation of content delivery networks that opportunistically allocates compute resources for CDN workloads that fits the user demand and the resources supply.

The simulation includes a cross-region distributed system that accepts supply of compute resources that runs on green-energy. It is a pre-allocated set of compute resources that meant to be used for any workload. When a green-energy source is not available the compute resource will remain idle in standby mode with no need for UPS as suggested in Open CloudServer OCS Chassis Management Specification Version 2.0. When a green energy is available the compute resources will resume its operation, accept,process infra-health calls and be ready for processing workload. 

The simulation will manifest a coordination system between the supply and demand as fast data system. It will process two kinds of requests (1) user workload (2) available green-cdn. The requests will be sent to a fast-data db that will create a match and assign demanded workload to supplied resources. 

The simulation includes three core systems:
###1. loaders that simulate workloads and supply based on real data.
###2. multi-tier api servers that consumes the loaders data.
###3. coordination system that pull the data from 2 and calculated the match and assign jobs.


##2 - API server

The service includes two API calls: 

1. I want x vCPUs within y minutes i.e. 

###### /map.php?cmd=append&key=DemandEvents&value=${timestamp},${day},us_${region-prefix},${num-cpu}
###### /map.php?cmd=append&key=${day}-${timestamp}&value=DemandEvents,us_${region-prefix},${num-cpu}
###### /map.php?cmd=append&key=us_${region-prefix}&value=DemandEvents,${day}-${timestamp},${num-cpu}

Above are three calls originated to the coordination service for indexing purposes. i.e. one can query each request by type (supply or demand), timestamp (for simplicity only the day in the month and time in a day) and by region.
2. I have x vCPUs for until t
###### /map.php?cmd=append&key=SupplyEvents&value=${timestamp},${day},us_${region-prefix},${num-cpu}
###### /map.php?cmd=append&key=${day}-${timestamp}&value=SupplyEvents,us_${region-prefix},${num-cpu}
###### /map.php?cmd=append&key=us_${region-prefix}&value=SupplyEvents,${day}-${timestamp},${num-cpu}

Above are three calls originated to the coordination service for indexing purposes. i.e. one can query each request by type (supply or demand), timestamp (for simplicity only the day in the month and time in a day) and by region.

x indicates the capacity, y indicates the workload threshold, t indicates the predicated compute availability duration in time.  

The API service code and configuration are under /cdn-service/green-cdn. It includes the docker images with the relvant code and redis client.

##3 - Persistence server
The persistence y layer is redis cluster with n=3 slaves and master that spans across three pods/vms. The frontend layer connects to the redis-cluster over TCP and the from the sensor or the power station over http (/map.php)

The redis docker image is specified in /cdn-service/redis-slave. 

The overall specification of both the redis and the front-end layer are under /cdn-service/*.yaml

##4 - The loader 
The loader is the tool that simulates the workload. It uses Apache jmeter. The testplan includes two sections: supply and demand. Each section execute the requests using a Poissongaussian random timer(\lambda=100) that distribute the traffic similarly to the reference google cluster data. 


###Data Flow
The API exposed via HTTP that registers the data, persist it in distributed Redis cluster. It is fetched by an async worker that push the data into GCE BigTable that looks for possible match and assign jobs to resources.  

### Architecture
The frontend layer includes Apache Http server loaded with php. It is currently uses php:5-apache docker image. 
It includes php-based redis app that allows a sensor to report to the system.



### Command Ref.
####git
1. git add *
2. git commit -m "message"
3. git push -u origin master

####re-image
Under every docker image there is a build script that handles the commands below automatically.

1. modify the directory php-redis so it includes the all the required modifications. 
2. in shell, move to the directory with the Dockerfile and execute : docker build .
3. then we need to tag the new build created by coping the container id e.g. “Successfully built 60e0cc387b04”
4. Then we need to tag the new container: docker tag f7ccbcc93ab0 gcr.io/api-project-79515284030/greencdn-image
5. then we need to push the build into gce: gcloud docker push gcr.io/api-project-79515284030/greencdn-image
6. In case docker is not responding clean the images :docker rmi gcr.io/api-project-79515284030/greencdn-image

https://blogs.technet.microsoft.com/server-cloud/2015/03/10/microsoft-reinvents-datacenter-power-backup-with-new-open-compute-project-specification/ 
