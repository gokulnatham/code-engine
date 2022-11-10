#!/usr/bin/env bash
echo "Deploying your code as Code Engine job...."
if ibmcloud ce job get -n "$(get_env app-name)" > /dev/null 2>&1; then
    echo "Code Engine job with name $(get_env app-name) found, updating it"
    ibmcloud ce job update -n "$(get_env app-name)" \
        -i "${IMAGE}" \
        --rs "${IMAGE_PULL_SECRET_NAME}" \
        -w=false \
        --cpu "$(get_env cpu "0.25")" \
        -m "$(get_env memory "0.5G")" \
        --maxexecutiontime "$(get_env maxexecutiontime "7200")"
        # TODO take in account --cmd --arg
else
    echo "Code Engine job with name $(get_env app-name) not found, creating it"
    ibmcloud ce job create -n "$(get_env app-name)" \
        -i "${IMAGE}" \
        --rs "${IMAGE_PULL_SECRET_NAME}" \
        -w=false \
        --cpu "$(get_env cpu "0.25")" \
        -m "$(get_env memory "0.5G")" \
        --maxexecutiontime "$(get_env maxexecutiontime "7200")"
        # TODO take in account --cmd --arg
fi
# Bind services, if any
# shellcheck disable=SC2162,SC2046,SC2005
while read; do
    NAME=$(echo "$REPLY" | jq -j '.key')
    PREFIX=$(echo "$REPLY" | jq -j '.value')
    if ! ibmcloud ce job get -n "$(get_env app-name)" | grep "$NAME"; then
        ibmcloud ce job bind -n "$(get_env app-name)" --si "$NAME" -p "$PREFIX" -w=false
    fi
done < <(jq -c 'to_entries | .[]' <<<$(echo $(get_env service-bindings "") | base64 -d))
echo "Checking if job is ready..."
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
echo "=========================================================="
echo -e "View the application at: $APPLICATION_URL"
# Record task results
set_env app-url "$APPLICATION_URL"
