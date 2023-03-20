# Code Engine Component Samples with DevSecOps configuration
> **DISCLAIMER**: This is a guideline samples application and is used for demonstrative and illustrative purposes only. This is not a production ready code.

The samples can be deployed with [CI-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-ci-toolchain&env_id=ibm:yp:us-south) and [CD-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-cd-toolchain&env_id=ibm:yp:us-south).

The samples are located in different location to illustrate build strategy using code-engine:
- dockerfile-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/helloworld
  Note: this component can be deployed as a Code Engine application or a Code Engine job
- buildpacks-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/s2i-buildpacks

### Configuration for Code Engine as deployment target
| Property | Default | Description | Required |
| -------- | :-----: | ----------- | :------: |
| `code-engine-project` |  | the name of the code engine project to use (or create)  | required |
| `code-engine-region` | region of the toolchain | the region to create/lookup for the code engine project | |
| `code-engine-resource-group` | resource group of the toolchain | the resource group of the code engine project | |
| `code-engine-binding-resource-group` | | The name of a resource group to use for authentication for the service bindings of the code engine project. A service ID is created with Operator and Manager roles for all services in this resource group. Use "*" to specify all resource groups in this account. See [Configuring a project for access to a resource group](https://cloud.ibm.com/docs/codeengine?topic=codeengine-bind-services#bind-config-proj) | |
| `code-engine-deployment-type` | `application` | type of code engine component to create/update as part of deployment. It can be either `application` or `job` | |
| `code-engine-build-strategy` | `dockerfile` | The build strategy for the code engine component. It can be `dockerfile` or `buildpacks` | |
| `code-engine-build-use-native-docker` | `false` | Property to opt-in for using native docker build capabilities as opposed to use Code Engine build to containerize the source. Note this setting only takes effect if the build-strategy is set to 'dockerfile'. Valid values are 'true' and 'false'. | |
| `code-engine-build-size` | `large` | the size to use for the build, which determines the amount of resources used. Valid values include small, medium, large, xlarge. | |
| `code-engine-build-timeout` | `1200` | the amount of time, in seconds, that can pass before the build run must succeed or fail. | |
| `code-engine-wait-timeout` | `1300` | the maximum timeout for the CLI operation to wait. | |
| `source` | Default to root of source code repository | path to the location of code to build in the repository | |
| `context-dir` | `.` | The directory in the repository that contains the buildpacks file or the Dockerfile. | |
| `dockerfile` | `Dockerfile` | The path to the Dockerfile. Specify this option only if the name is other than Dockerfile | |
| `cpu` | `0.25` | The amount of CPU set for the instance of the application or job. For valid values, see [Supported memory and CPU combinations](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo). | |
| `memory` | `0.5G` | The amount of memory set for the instance of the application or job. Use `M` for megabytes or `G` for gigabytes. For valid values, see [Supported memory and CPU combinations](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo). | |
| `ephemeral-storage` | `0.4G` | The amount of ephemeral storage to set for the instance of the application or for the runs of the job. Use M for megabytes or G for gigabytes. | |
| `job-maxexecutiontime` | `7200` | The maximum execution time in seconds for runs of the job. | |
| `job-retrylimit` | `3` | The number of times to rerun an instance of the job before the job is marked as failed | |
| `job-instances` | `1` | Specifies the number of instances that are used for runs of the job. When you use this option, the system converts to array indices. For example, if you specify instances of 5, the system converts to array-indices of 0 - 4. This option can only be specified if the --array-indices option is not specified. The default value is 1. | |
| `app-port` | `8080` | The port where the application listens. The format is `[NAME:]PORT`, where `[NAME:]` is optional. If `[NAME:]` is specified, valid values are `h2c`, or `http1`. When `[NAME:]` is not specified or is `http1`, the port uses `HTTP/1.1`. When `[NAME:]` is `h2c`, the port uses unencrypted `HTTP/2`. | |
| `app-min-scale` | `0` | The minimum number of instances that can be used for this application. This option is useful to ensure that no instances are running when not needed | |
| `app-max-scale` | `1` | The maximum number of instances that can be used for this application. If you set this value to 0, the application scales as needed. The application scaling is limited only by the instances per the resource quota for the project of your application. See [Limits and quotas for Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-limits) | |
| `app-deployment-timeout` | `300` | The maximum timeout for the application deployment. | |
| `app-concurrency` | `100` | The maximum number of requests that can be processed concurrently per instance. | |
| `app-visibility` | `public` | The visibility for the application. Valid values are public, private and project. Setting a visibility of public means that your app can receive requests from the public internet or from components within the Code Engine project. Setting a visibility of private means that your app is not accessible from the public internet and network access is only possible from other IBM Cloud using Virtual Private Endpoints (VPE) or Code Engine components that are running in the same project. Visibility can only be private if the project supports application private visibility. Setting a visibility of project means that your app is not accessible from the public internet and network access is only possible from other Code Engine components that are running in the same project. | |
| `CE_ENV_\<XXXX\>` |  | pipeline/trigger property (secured or not) to provide value for code engine environment variable \<XXXX\> | |
| `service-bindings` | | JSON array including service name(s) (as as simple JSON string `"service-to-bind"`) or element(s) in the form of `{"service-to-bind":"prefix"}`.  | |

<u>Note</u>: As part of CD deployment process, to scope configuration/environment variables for a given inventory entry, you can prefix the property with the inventory entry name like `<inventory_entry>_`.

Example:

`hello-ce-dockerfile-app_CE_ENV_TARGET` : _Everybody_

`hello-ce-dockerfile-app_memory` : 1G

## Learn more

* [Getting started with IBM Cloud Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)
* [Getting started with toolchains](https://cloud.ibm.com/devops/getting-started)
* [DevSecOps with Continuous Delivery](https://cloud.ibm.com/docs/devsecops?topic=devsecops-devsecops_intro)
* [Integrating Code Engine workloads with Continuous Delivery](https://cloud.ibm.com/docs/codeengine?topic=codeengine-toolchain-ce)
