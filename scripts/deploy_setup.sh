#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091
source "${WORKSPACE}/$PIPELINE_CONFIG_REPO_PATH/scripts/code-engine-utilities.sh"

if ! initialize-code-engine-project-context; then
  echo "Code Engine project context initialization failed. Exiting 1"
  exit 1
fi

# Configure the secret for registry credentials
IBMCLOUD_TOOLCHAIN_ID="$(jq -r .toolchain_guid /toolchain/toolchain.json)"
REGISTRY_URL=$(echo "${IMAGE}" | awk -F/ '{print $1}')
export REGISTRY_SECRET_NAME="ibmcloud-toolchain-${IBMCLOUD_TOOLCHAIN_ID}-${REGISTRY_URL}"

if ibmcloud ce registry get --name "${REGISTRY_SECRET_NAME}" > /dev/null 2>&1; then
  echo "${REGISTRY_SECRET_NAME} Secret to push and pull the image already exists."
else
  echo "Secret to push and pull the image does not exists, Creating it......."
  if [ -f /config/api-key ]; then
    ICR_API_KEY="$(cat /config/api-key)" # pragma: allowlist secret
  else
    ICR_API_KEY="$(get_env ibmcloud-api-key)" # pragma: allowlist secret
  fi
  ibmcloud ce registry create --name "${REGISTRY_SECRET_NAME}" --email a@b.com  --password="$ICR_API_KEY" --server "$(echo "$IMAGE" |  awk -F/ '{print $1}')" --username iamapikey
fi
