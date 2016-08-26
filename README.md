# Enabling Green Content Distribution Network by Clouds Orchestration
This is a simulation of content delivery networks that opportunistically allocates compute resources for CDN workloads that fits the user demand and the resources supply.

In the following section we evaluate a coordination com- ponent that harmonizes on-demand streaming jobs demands with available compute resources powered by green energy resources. Such resources will be published to the coordina- tion system through a resource availability tuple {region,cut- in,rated,cut-off,power-efficiency}, where region and power- efficiency indicates solar or wind based energy and region, cut-in, rated and cut-off of those energies.

On-demand streaming job demand includes the specific region, total-job workload, load-factor, as well as contract deadline stermed tuple. The load-factor indicates the required number of CPU cores per the total-job-workload. The region indication will optimize the match between the supply and demand. Also, the total-job-workload and the deadline will be checked against the cut-in-rated, cutoff time for wind or power-efficiency for solar, based on the published load-factor. We will suggest a hybrid data center structure that does not deviate from the common data-center architecture. 

The core difference lies on an automatic transfer switch (ATS) that switches between different available power sources: gen- erator, grid or clean-energy when available. In both cases the data-center design does not change and requires incremental changes only by adding clean-energy power sources to the
datacenter’s ATS’s.

The simulation includes a cross-region distributed system that accepts supply of compute resources that runs on green-energy. It is a pre-allocated set of compute resources that meant to be used for any workload. When a green-energy source is not available the compute resource will remain idle in standby mode with no need for UPS as suggested in Open CloudServer OCS Chassis Management Specification Version 2.0. When a green energy is available the compute resources will resume its operation, accept,process infra-health calls and be ready for processing workload. 

The simulation will manifest a coordination system between the supply and demand as fast data system. It will process two kinds of requests (1) user workload (2) available green-cdn. The requests will be sent to a fast-data db that will create a match and assign demanded workload to supplied resources. 

The simulation includes four core systems:
* Loaders - loaders that simulate workloads and supply based on real data
```https://github.com/yahavb/green-content-delivery-network/tree/master/loader```

* Data Plane - coordination system that pull the data from 2 and calculated the match and assign jobs ```https://github.com/yahavb/green-content-delivery-network/tree/master/cdn-orchestrator```

* Control Plane - Multi Zones CDN Clusters that process the workload
```https://github.com/yahavb/green-content-delivery-network/tree/master/multi-zone-cdn-clusters```

As
