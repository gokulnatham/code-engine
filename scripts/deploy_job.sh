#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091
source "${WORKSPACE}/$PIPELINE_CONFIG_REPO_PATH/scripts/code-engine-utilities.sh"

echo "Deploying your code as Code Engine job...."
setup-cd-auto-managed-env-configmap "$(get_env app-name)"
setup-cd-auto-managed-env-secret "$(get_env app-name)"
if ! deploy-code-engine-job "$(get_env app-name)" "${IMAGE}" "${REGISTRY_SECRET_NAME}"; then
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
