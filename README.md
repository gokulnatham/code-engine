# Code Engine Samples with DevSecOps configuration
> **DISCLAIMER**: This is a guideline samples application and is used for demonstrative and illustrative purposes only. This is not a production ready code.

This sample contains an simple Node.js microservice that can be deployed with [CI-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-ci-toolchain&env_id=ibm:yp:us-south) and [CD-toolchain](https://cloud.ibm.com/devops/setup/deploy?repository=https%3A%2F%2Fus-south.git.cloud.ibm.com%2Fopen-toolchain%2Fcompliance-cd-toolchain&env_id=ibm:yp:us-south).

The samples are located in different location to illustrate build strategy using code-engine:
- dockerfile-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/helloworld
- buildpacks-strategy folder contains sample application copied from https://github.com/IBM/CodeEngine/tree/main/s2i-buildpacks
