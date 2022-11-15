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
| `code-engine-entity-type` | `application` | type of code engine entity to create/update as part of deployment. It can be either `application` or `job` | |
| `code-engine-build-strategy` | `dockerfile` | The build strategy for the code engine entity. It can be `dockerfile` or `buildpacks` |
| `source` | | path to the location of code to build in the repository | |
| `CE_ENV_\<XXXX\>` |  | pipeline/trigger property (secured or not) to provide value for code engine environment variable \<XXXX\> | |

<u>Note</u>: As part of CD deployment process, to scope configuration/environment variables for a given inventory entry, you can prefix the property with the inventory entry name like `<inventory_entry>_`.

Example:

`hello-ce-dockerfile-app_CE_ENV_TARGET` : _Everybody_
