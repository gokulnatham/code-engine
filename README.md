<p align="center">
    <a href="https://cloud.ibm.com">
        <img src="https://cloud.ibm.com/media/docs/developer-appservice/resources/ibm-cloud.svg" height="100" alt="IBM Cloud">
    </a>
</p>

<p align="center">
    <a href="https://cloud.ibm.com">
        <img src="https://img.shields.io/badge/IBM%20Cloud-powered-blue.svg" alt="IBM Cloud">
    </a>
    <img src="https://img.shields.io/badge/platform-codeengine-lightgrey.svg?style=flat" alt="CodeEngine">
    <a href="https://cloud.ibm.com/docs/devsecops">
        <img src="https://img.shields.io/badge/DevSecOps-enabled-blue.svg?style=flat" alt="DevSecOps">
    </a>
</p>

# Create and deploy a Code Engine Sample Application using IBM Cloud DevSecOps

> **DISCLAIMER**: This repository contains guideline sample applications and is used for demonstrative and illustrative purposes only deployed using IBM Cloud DevSecOps Continuous Integration (CI) and Continuous Deployment (CD) pipelines. This is not a production ready code.

## Contents
- [Scope](#scope)
- [Build and Run the samples with your own machine](#build-and-run-the-samples-with-your-own-machine)
- [Create DevSecOps toolchains](#create-devsecops-toolchains)
- [Additional information](#additional-information)

## Scope
This repository contains application samples that can be deployed to IBM Cloud Code Engine.

## Build and Run the samples with your own machine

The samples are located in different folders to illustrate build strategy using code-engine:
- [dockerfile-strategy](./dockerfile-strategy) folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/helloworld
  Note: this component can be deployed as a Code Engine application or a Code Engine job
- [buildpacks-strategy](./buildpacks-strategy) folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/s2i-buildpacks

To build and run from your own local machine, follow the instructions from the https://github.com/IBM/CodeEngine repository:
- The `dockerfile-strategy` sample is rooted at https://github.com/IBM/CodeEngine/tree/main/helloworld
- The `buildpacks-strategy` sample is rooted at https://github.com/IBM/CodeEngine/tree/main/s2i-buildpacks


## Create DevSecOps toolchains

### Pre-requisites

- An IBM Cloud account needs to be setup

### Toolchains setup

The DevSecOps toolchains to create and deploy these samples to IBM Cloud with DevSecOps CI can be created using the following link: [DevSecOps CI toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-ci-toolchain&env_id=ibm:yp:us-south).

The DevSecOps CD can be created using the following link: [DevSecOps CD toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-cd-toolchain&env_id=ibm:yp:us-south).


### Customized scripts for DevSecOps pipelines
The source code of the sample contains a [.pipeline-config.yaml](/.pipeline-config.yaml) file and scripts located in the [scripts](./scripts/) folder.
The `.pipeline-config.yaml` file is the core configuration file that is used by DevSecOps CI, CD and CC pipelines for all of the stages in the pipeline run processes.
Those scripts can be customized if needed just like the `.pipeline-config.yaml` content.

### Configuration of customized stages and scripts
Note: default scripts invoked in various stages of the pipelines are provided by the [commons base image](https://us-south.git.cloud.ibm.com/open-toolchain/compliance-commons) and can be configured using specific properties, as described in the documentation [Pipeline parameters](https://cloud.ibm.com/docs/devsecops?topic=devsecops-cd-devsecops-pipeline-parm)

The sections below describe additional parameters (specific to these customized scripts) used to configure the [`scripts`](./scripts/) used in this sample.

#### containerize stage
| Property | Default | Description | Required |
| -------- | :-----: | ----------- | :------: |
| `code-engine-ibmcloud-api-key` | Default to the value of `ibmcloud-api-key` | specific IBM Cloud API key to be used for the CodeEngine related operations. | 
| `code-engine-project` |  | the name of the code engine project to use (or create)  | required |
| `code-engine-region` | region of the toolchain | the region to create/lookup for the code engine project | |
| `code-engine-resource-group` | resource group of the toolchain | the resource group of the code engine project | |
| `code-engine-build-strategy` | `dockerfile` | The build strategy for the code engine component. It can be `dockerfile` or `buildpacks` | |
| `code-engine-build-use-native-docker` | `false` | Property to opt-in for using native docker build capabilities as opposed to use Code Engine build to containerize the source. Note this setting only takes effect if the build-strategy is set to 'dockerfile'. Valid values are 'true' and 'false'. | |
| `code-engine-build-size` | `large` | the size to use for the build, which determines the amount of resources used. Valid values include small, medium, large, xlarge. | |
| `code-engine-build-timeout` | `1200` | the amount of time, in seconds, that can pass before the build run must succeed or fail. | |
| `code-engine-wait-timeout` | `1300` | the maximum timeout for the CLI operation to wait. | |
| `context-dir` | `.` | The directory in the repository that contains the buildpacks file or the Dockerfile. | |
| `dockerfile` | `Dockerfile` | The path to the Dockerfile. Specify this option only if the name is other than Dockerfile | |
| `image-name` | Default to humanished-part of the application repository and the source directory | name of the image that is built | |
| `registry-domain` | | the container registry URL domain that is used to build and tag the image. Useful when using private-endpoint container registry. | |
| `source` | Default to root of source code repository | path to the location of code to build in the repository | |

### deployment stage
| Property | Default | Description | Required |
| -------- | :-----: | ----------- | :------: |
| `code-engine-ibmcloud-api-key` | Default to the value of `ibmcloud-api-key` | specific IBM Cloud API key to be used for the CodeEngine related operations. | 
| `code-engine-project` |  | the name of the code engine project to use (or create)  | required |
| `code-engine-region` | region of the toolchain | the region to create/lookup for the code engine project | |
| `code-engine-resource-group` | resource group of the toolchain | the resource group of the code engine project | |
| `code-engine-binding-resource-group` | | The name of a resource group to use for authentication for the service bindings of the code engine project. A service ID is created with Operator and Manager roles for all services in this resource group. Use "*" to specify all resource groups in this account. See [Configuring a project for access to a resource group](https://cloud.ibm.com/docs/codeengine?topic=codeengine-bind-services#bind-config-proj) | |
| `code-engine-deployment-type` | `application` | type of code engine component to create/update as part of deployment. It can be either `application` or `job` | |
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
| `env-from-configmaps` | | semi-colon separated list of configmaps to set environment variables from | |
| `env-from-secrets` | | semi-colon separated list of secrets to set environment variables from | |
| `remove-unspecified-references-to-configuration-resources`| `false` | remove references to unspecified configuration resources (configmap/secret) references (pulled from env-from-configmaps, env-from-secrets along with auto-managed by CD) | | 
| `service-bindings` | | JSON array including service name(s) (as a simple JSON string `"service-to-bind"`) or element(s) in the form of `{"service-to-bind":"prefix"}`.  | |

<u>Note</u>: As part of CD deployment process, to scope configuration/environment variables for a given inventory entry, you can prefix the property with the inventory entry name like `<inventory_entry>_`.

Example:

`hello-ce-dockerfile-app_CE_ENV_TARGET` : _Everybody_

`hello-ce-dockerfile-app_memory` : 1G

### Detect secrets

Detect secrets check is performed as part of the PullRequest pipeline and Continuous Integration pipelines so this repository includes a [.secrets.baseline](.secrets.baseline) to identify baseline for secrets check.

More information at [Configuring Detect secrets scans](https://cloud.ibm.com/docs/devsecops?topic=devsecops-cd-devsecops-detect-secrets-scans)

Note: detect-secret is configured as a pre-commit hook for this sample repository. See [.pre-commit-config.yaml](.pre-commit-config.yaml)

### CRA Scanning

This repository includes a [.cra/.cveignore](.cra/.cveignore) file that is used by Code Risk Analyzer (CRA) in IBM Cloud Continuous Delivery. This file helps address vulnerabilities that are found by CRA until a remediation is available, at which point the vulnerabilities will be addressed in the respective package versions. CRA keeps the code in this repository free of known vulnerabilities, and therefore helps make applications that are built on this code more secure. If you are not using CRA, you can safely ignore this file.

## Additional information

### Documentation

- [Getting started with IBM Cloud Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)
- [Getting started with toolchains](https://cloud.ibm.com/devops/getting-started)
- [Integrating Code Engine workloads with Continuous Delivery](https://cloud.ibm.com/docs/codeengine?topic=codeengine-toolchain-ce)
- [DevSecOps with Continuous Delivery](https://cloud.ibm.com/docs/devsecops?topic=devsecops-devsecops_intro)
- [DevSecOps tutorial - Set-up prerequites](https://cloud.ibm.com/docs/devsecops?topic=devsecops-tutorial-cd-devsecops)
- [DevSecOps tutorial - Set-up a DevSecOps CI toolchain](https://cloud.ibm.com/docs/devsecops?topic=devsecops-tutorial-ci-toolchain)
- [DevSecOps tutorial - Set-up a DevSecOps CD toolchain](https://cloud.ibm.com/docs/devsecops?topic=devsecops-tutorial-cd-toolchain)
- [DevSecOps Continuous Integration pipeline](https://cloud.ibm.com/docs/devsecops?topic=devsecops-cd-devsecops-ci-pipeline)

### Troubleshooting
Documentation can be found [here](https://cloud.ibm.com/docs/ContinuousDelivery?topic=ContinuousDelivery-troubleshoot-devsecops).

### Report a problem or looking for help
Get help directly from the IBM Cloud development teams by joining us on [Slack](https://join.slack.com/t/ibm-devops-services/shared_invite/zt-1znyhz8ld-5Gdy~biKLe233Chrvgdzxw).
