#!/usr/bin/env bash

# shellcheck source=./code-engine-utilities.sh
source "${WORKSPACE}/$(get_env ONE_PIPELINE_CONFIG_DIRECTORY_NAME)/scripts/code-engine-utilities.sh"

echo "Deploying your code as Code Engine job...."
setup-ce-env-configmap "$(get_env app-name)"
setup-ce-env-secret "$(get_env app-name)"
deploy-code-engine-job "$(get_env app-name)" "${IMAGE}" "${IMAGE_PULL_SECRET_NAME}" "$(get_env ce-env-configmap "")" "$(get_env ce-env-secret "")"

# Bind services, if any
bind-services-to-code-engine-job "$(get_env app-name)"

echo "Checking if job is ready..."
# TODO
