#!/usr/bin/env bash

# shellcheck source=./code-engine-utilities.sh
source "${WORKSPACE}/$(get_env ONE_PIPELINE_CONFIG_DIRECTORY_NAME)/scripts/code-engine-utilities.sh"

if ! initialize-code-engine-project-context; then
  echo "Code Engine project context initialization failed. Exiting 1"
  exit 1
fi

echo -e "Configuring access to private image registry"
if [ -f /config/api-key ]; then
  IBMCLOUD_API_KEY="$(cat /config/api-key)" # pragma: allowlist secret
else
  IBMCLOUD_API_KEY="$(get_env ibmcloud-api-key)" # pragma: allowlist secret
fi
IBMCLOUD_TOOLCHAIN_ID="$(jq -r .toolchain_guid /toolchain/toolchain.json)"
REGISTRY_URL="$(load_artifact app-image name | awk -F/ '{print $1}')"
export IMAGE_PULL_SECRET_NAME
IMAGE_PULL_SECRET_NAME="ibmcloud-toolchain-${IBMCLOUD_TOOLCHAIN_ID}-${REGISTRY_URL}"

if ! kubectl get secret "${IMAGE_PULL_SECRET_NAME}"; then
    echo -e "${IMAGE_PULL_SECRET_NAME} not found, creating it"
    # for Container Registry, docker username is 'token' and email does not matter
    kubectl create secret docker-registry "${IMAGE_PULL_SECRET_NAME}" --docker-server="${REGISTRY_URL}" --docker-password="${IBMCLOUD_API_KEY}" --docker-username=iamapikey --docker-email=a@b.com
fi
