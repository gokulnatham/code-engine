#!/usr/bin/env bash

# shellcheck source=./code-engine-utilities.sh
source "${WORKSPACE}/$(get_env ONE_PIPELINE_CONFIG_DIRECTORY_NAME)/scripts/code-engine-utilities.sh"

echo "Deploying your code as Code Engine job...."
setup-ce-env-configmap "$(get_env app-name)"
setup-ce-env-secret "$(get_env app-name)"
if ! deploy-code-engine-job "$(get_env app-name)" "${IMAGE}" "${IMAGE_PULL_SECRET_NAME}"; then
  echo "Failure in code engine job deployment. Exiting 1"
  exit 1
fi

# Bind services, if any
if ! bind-services-to-code-engine-job "$(get_env app-name)"; then
  echo "Failure in services binding to code engine job. Exiting 1"
  exit 1
fi

echo "Checking if job is ready..."
# TODO
