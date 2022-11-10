#!/usr/bin/env bash

# shellcheck source=./code-engine-utilities.sh
source "${WORKSPACE}/$(get_env ONE_PIPELINE_CONFIG_DIRECTORY_NAME)/scripts/code-engine-utilities.sh"

if ! initialize-code-engine-project-context; then
  echo "Code Engine project context initialization failed. Exiting 1"
  exit 1
fi

# Configure the secret for registry credentials
if ibmcloud ce registry get --name "${PIPELINE_ID}" > /dev/null 2>&1 ;
  then
  echo "${PIPELINE_ID} Secret to push and pull the image already exists."
else
  echo "Secret to push and pull the image does not exists, Creating it......."
  if [ -f /config/api-key ]; then
    ICR_API_KEY="$(cat /config/api-key)" # pragma: allowlist secret
  else
    ICR_API_KEY="$(get_env ibmcloud-api-key)" # pragma: allowlist secret
  fi
  ibmcloud ce registry create  --name "${PIPELINE_ID}" --email a@b.com  --password="$ICR_API_KEY" --server "$(echo "$IMAGE" |  awk -F/ '{print $1}')" --username iamapikey
fi

echo "using Buildpacks to build application"
ibmcloud ce buildrun submit --name "${PIPELINE_RUN_ID}" --strategy buildpacks --image "$IMAGE" --registry-secret "${PIPELINE_ID}" --source "$WORKSPACE/$(load_repo app-repo path)/$(get_env context-dir "")" --context-dir "." --wait

# TODO Should use the icr cli command to retrieve the DIGEST it would prevent to pull back the built image
# in the docker dind local registry
# Pull the image to retrieve the digest
docker pull "${IMAGE}"
DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE}" | awk -F@ '{print $2}')"

#
# Save the artifact to the pipeline,
# so it can be scanned and signed later
#
save_artifact app-image \
    type=image \
    "name=${IMAGE}" \
    "digest=${DIGEST}" \
    "tags=${IMAGE_TAG}"

#
# Make sure you connect the built artifact to the repo and commit
# it was built from. The source repo asset format is:
#   <repo_URL>.git#<commit_SHA>
#
# In this example we have a repo saved as `app-repo`,
# and we've used the latest cloned state to build the image.
#
url="$(load_repo app-repo url)"
sha="$(load_repo app-repo commit)"

save_artifact app-image \
"source=${url}.git#${sha}"

# optional tags
set +e
TAG="$(cat /config/custom-image-tag)"
set -e
if [[ "${TAG}" ]]; then
    #see build_setup script
    IFS=',' read -ra tags <<< "${TAG}"
    for i in "${!tags[@]}"
    do
        TEMP_TAG=${tags[i]}
        # shellcheck disable=SC2001
        TEMP_TAG=$(echo "$TEMP_TAG" | sed -e 's/^[[:space:]]*//')
        echo "adding tag $i $TEMP_TAG"
        ADDITIONAL_IMAGE_TAG="$ICR_REGISTRY_REGION.icr.io"/"$ICR_REGISTRY_NAMESPACE"/"$IMAGE_NAME":"$TEMP_TAG"
        docker tag "$IMAGE" "$ADDITIONAL_IMAGE_TAG"
        docker push "$ADDITIONAL_IMAGE_TAG"

        # save tags to pipelinectl
        image_tags="$(load_artifact app-image tags)"
        save_artifact app-image "tags=${image_tags},${TEMP_TAG}"
    done
fi
