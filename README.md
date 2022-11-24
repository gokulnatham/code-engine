# Code Engine Samples with DevSecOps configuration
> **DISCLAIMER**: This is a guideline samples application and is used for demonstrative and illustrative purposes only. This is not a production ready code.

The samples can be deployed with [CI-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-ci-toolchain&env_id=ibm:yp:us-south) and [CD-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-cd-toolchain&env_id=ibm:yp:us-south).

The samples are located in different location to illustrate build strategy using code-engine:
- dockerfile-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/helloworld
- buildpacks-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/s2i-buildpacks

### Configuration for Code Engine as deployment target
| Property | Default | Description | Required |
| -------- | :-----: | ----------- | :------: |
| `code-engine-project` |  | the name of the code engine project to use (or create)  | required |
| `code-engine-region` | region of the toolchain | the region to create/lookup for the code engine project | |
| `code-engine-resource-group` | resource group of the toolchain | the resource group of the code engine project | |
| `code-engine-binding-resource-group` | | The name of a resource group to use for authentication for the service bindings of the code engine project. A service ID is created with Operator and Manager roles for all services in this resource group. Use "*" to specify all resource groups in this account. See [Configuring a project for access to a resource group](https://cloud.ibm.com/docs/codeengine?topic=codeengine-bind-services#bind-config-proj) | |
| `code-engine-entity-type` | `application` | type of code engine entity to create/update as part of deployment. It can be either `application` or `job` | |
| `code-engine-build-strategy` | `dockerfile` | The build strategy for the code engine entity. It can be `dockerfile` or `buildpacks` |
| `source` | | path to the location of code to build in the repository | |
| `CE_ENV_\<XXXX\>` |  | pipeline/trigger property (secured or not) to provide value for code engine environment variable \<XXXX\> | |
| `cpu` | `0.25` | The amount of CPU set for the instance of the application or job. For valid values, see [Supported memory and CPU combinations](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo). | |
| `memory` | `0.5G` | The amount of memory set for the instance of the application or job. Use `M` for megabytes or `G` for gigabytes. For valid values, see [Supported memory and CPU combinations](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo). | |
| `maxexecutiontime` | `7200` | The maximum execution time in seconds for runs of the job. | |
| `retrylimit` | `3` | The number of times to rerun an instance of the job before the job is marked as failed | |
| `port` | `http1:8080` | The port where the application listens. The format is `[NAME:]PORT`, where `[NAME:]` is optional. If `[NAME:]` is specified, valid values are `h2c`, or `http1`. When `[NAME:]` is not specified or is `http1`, the port uses `HTTP/1.1`. When `[NAME:]` is `h2c`, the port uses unencrypted `HTTP/2`. | |
| `min-scale` | `0` | The minimum number of instances that can be used for this application. This option is useful to ensure that no instances are running when not needed | |
| `max-scale` | `1` | The maximum number of instances that can be used for this application. If you set this value to 0, the application scales as needed. The application scaling is limited only by the instances per the resource quota for the project of your application. See [Limits and quotas for Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-limits) | |
| `service-bindings` | | JSON array including service name(s) (as as simple JSON string `"service-to-bind"`) or element(s) in the form of `{"service-to-bind":"prefix"}`.  | |

<u>Note</u>: As part of CD deployment process, to scope configuration/environment variables for a given inventory entry, you can prefix the property with the inventory entry name like `<inventory_entry>_`.

Example:

`hello-ce-dockerfile-app_CE_ENV_TARGET` : _Everybody_

`hello-ce-dockerfile-app_memory` : 1G
