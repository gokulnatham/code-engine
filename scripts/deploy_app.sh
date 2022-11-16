#!/usr/bin/env bash

# shellcheck source=./code-engine-utilities.sh
source "${WORKSPACE}/$(get_env ONE_PIPELINE_CONFIG_DIRECTORY_NAME)/scripts/code-engine-utilities.sh"

echo "Deploying your code as Code Engine application...."
setup-ce-env-configmap "$(get_env app-name)"
setup-ce-env-secret "$(get_env app-name)"
if ! deploy-code-engine-application "$(get_env app-name)" "${IMAGE}" "${IMAGE_PULL_SECRET_NAME}"; then
  echo "Failure in code engine application deployment. Exiting 1"
  exit 1
fi

# Bind services, if any
bind-services-to-code-engine-application "$(get_env app-name)"

echo "Checking if application is ready..."
KUBE_SERVICE_NAME=$(get_env app-name)
DEPLOYMENT_TIMEOUT=$(get_env deployment-timeout "300")
echo "Timeout for the application deployment is ${DEPLOYMENT_TIMEOUT}"
ITERATION=0
while [[ "${ITERATION}" -le "${DEPLOYMENT_TIMEOUT}" ]]; do
    sleep 1
    SVC_STATUS_READY=$(kubectl get "ksvc/${KUBE_SERVICE_NAME}" -o json | jq '.status?.conditions[]?.status?|select(. == "True")')
    SVC_STATUS_NOT_READY=$(kubectl get "ksvc/${KUBE_SERVICE_NAME}" -o json | jq '.status?.conditions[]?.status?|select(. == "False")')
    SVC_STATUS_UNKNOWN=$(kubectl get "ksvc/${KUBE_SERVICE_NAME}" -o json | jq '.status?.conditions[]?.status?|select(. == "Unknown")')
    # shellcheck disable=SC2166
    if [ \( -n "$SVC_STATUS_NOT_READY" \) -o \( -n "$SVC_STATUS_UNKNOWN" \) ]; then
        echo "Application not ready, retrying"
    elif [ -n "$SVC_STATUS_READY" ]; then
        echo "Application is ready"
        break
    else
        echo "Application status unknown, retrying"
    fi
    ITERATION="${ITERATION}"+1
done
echo "Application service details:"
kubectl describe "ksvc/${KUBE_SERVICE_NAME}"
# shellcheck disable=SC2166
if [ \( -n "$SVC_STATUS_NOT_READY" \) -o \( -n "$SVC_STATUS_UNKNOWN" \) ]; then
    echo "Application is not ready after waiting maximum time"
    exit 1
fi
# Determine app url for polling from knative service
TEMP_URL=$(kubectl get "ksvc/${KUBE_SERVICE_NAME}" -o json | jq '.status.url')
echo "Application status URL: $TEMP_URL"
TEMP_URL=${TEMP_URL%\"} # remove end quote
TEMP_URL=${TEMP_URL#\"} # remove beginning quote
APPLICATION_URL=$TEMP_URL
if [ -z "$APPLICATION_URL" ]; then
    echo "Deploy failed, no URL found for application"
    exit 1
fi
echo "Application is available"
echo -e "View the application at: $APPLICATION_URL"
# Record task results
set_env app-url "$APPLICATION_URL"
