#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${ONE_PIPELINE_PATH}"/tools/retry

if [ -f /config/api-key ]; then
  IBMCLOUD_API_KEY="$(cat /config/api-key)" # pragma: allowlist secret
else
  IBMCLOUD_API_KEY="$(get_env ibmcloud-api-key)" # pragma: allowlist secret
fi

IBMCLOUD_TOOLCHAIN_ID="$(jq -r .toolchain_guid /toolchain/toolchain.json)"
IBMCLOUD_CE_REGION="$(get_env dev-region | awk -F ":" '{print $NF}')"
if [ -z "$IBMCLOUD_CE_REGION" ];
  # default to toolchain region
  IBMCLOUD_CE_REGION=$(jq -r '.region_id' /toolchain/toolchain.json | awk -F: '{print $3}')
fi

REGISTRY_URL="$(load_artifact app-image name | awk -F/ '{print $1}')"
IMAGE="$(load_artifact app-image name)"
DIGEST="$(load_artifact app-image digest)"
IMAGE_PULL_SECRET_NAME="ibmcloud-toolchain-${IBMCLOUD_TOOLCHAIN_ID}-${REGISTRY_URL}"

# SETUP BEGIN
ibmcloud config --check-version false
retry 5 2 \
  ibmcloud login -a $(get_env ibmcloud-api "https://cloud.ibm.com") -r $IBMCLOUD_CE_REGION --apikey $IBMCLOUD_API_KEY

ibmcloud target -g "$(get_env resource-group)"

# Make sure that the latest version of Code Engine CLI is installed
if ! ibmcloud plugin show code-engine >/dev/null 2>&1; then
    ibmcloud plugin install code-engine
else
    ibmcloud plugin update code-engine --force
fi

echo "Check Code Engine project availability"
if ibmcloud ce proj get -n $(get_env code-engine-project); then
    echo -e "Code Engine project $(get_env code-engine-project) found."
else
    echo -e "No Code Engine project with the name $(get_env code-engine-project) found. Creating new project..."
    ibmcloud ce proj create -n $(get_env code-engine-project)
    echo -e "Code Engine project $(get_env code-engine-project) created."
fi

echo "Loading Kube config..."
ibmcloud ce proj select -n $(get_env code-engine-project) -k

RG_NAME=$(ibmcloud resource groups --output json | jq '.[] | select(.id=="$(get_env resource-group)") | .name')
# check to see if "$(get_env resource-group)" is a name or an ID
if [ "${RG_NAME}" == "" ]; then
  RG_NAME="$(get_env resource-group)"
fi
# check to see if $RG_NAME is not the default resource group
if [ $(ibmcloud resource groups --output json | jq '.[] | select(.name=="$RG_NAME") | .default') == 'false' ]; then
  echo "Updating Code Engine project to bind to resource group $RG_NAME..."
  ibmcloud ce project update --binding-resource-group "$RG_NAME"
fi

echo -e "Configuring access to private image registry"
if ! kubectl get secret ${IMAGE_PULL_SECRET_NAME}; then
    echo -e "${IMAGE_PULL_SECRET_NAME} not found, creating it"
    # for Container Registry, docker username is 'token' and email does not matter
    kubectl create secret docker-registry ${IMAGE_PULL_SECRET_NAME} --docker-server=${REGISTRY_URL} --docker-password=${IBMCLOUD_API_KEY} --docker-username=iamapikey --docker-email=a@b.com
fi