#!/usr/bin/env bash

if [ "$PIPELINE_DEBUG" = "1" ]; then
  pwd
  env
  trap env EXIT
  set -x +e

  export IBMCLOUD_TRACE=true
fi

source "${ONE_PIPELINE_PATH}/tools/retry"
source "${ONE_PIPELINE_PATH}/internal/tools/logging"

ibmcloud_login() {
  local -r ibmcloud_api=$(get_env ibmcloud-api "https://cloud.ibm.com")

  ibmcloud config --check-version false
  # Use `code-engine-ibmcloud-api-key` if present, if not, fall back to `ibmcloud-api-key`
  local SECRET_PATH="/config/ibmcloud-api-key"
  if [[ -s "/config/code-engine-ibmcloud-api-key" ]]; then
    SECRET_PATH="/config/code-engine-ibmcloud-api-key"
  fi

  retry 5 3 ibmcloud login -a "$ibmcloud_api" --apikey @"$SECRET_PATH" --no-region
  exit_code=$?
  if [ $exit_code -ne 0 ]; then
    error "Could not log in to IBM Cloud."
    exit $exit_code
  fi
}

refresh_ibmcloud_session() {
  local login_temp_file="/tmp/ibmcloud-login-cache"
  if [[ ! -f "$login_temp_file" ]]; then
    ibmcloud_login
    touch "$login_temp_file"
  elif [[ -n "$(find "$login_temp_file" -mmin +15)" ]]; then
    ibmcloud_login
    touch "$login_temp_file"
  fi
}

initialize-code-engine-project-context() {
  refresh_ibmcloud_session || return

  # create the project and make it current
  IBMCLOUD_CE_REGION="$(get_env code-engine-region | awk -F ":" '{print $NF}')"
  if [ -z "$IBMCLOUD_CE_REGION" ]; then
    # default to toolchain region
    IBMCLOUD_CE_REGION=$(jq -r '.region_id' /toolchain/toolchain.json | awk -F: '{print $3}')
  fi

  IBMCLOUD_CE_RG="$(get_env code-engine-resource-group)"
  if [ -z "$IBMCLOUD_CE_RG" ]; then
    # default to toolchain resource group
    IBMCLOUD_CE_RG="$(jq -r '.container.guid' /toolchain/toolchain.json)"
  fi
  ibmcloud target -r "$IBMCLOUD_CE_REGION" -g "$IBMCLOUD_CE_RG"

  # Make sure that the latest version of Code Engine CLI is installed
  if ! ibmcloud plugin show code-engine > /dev/null 2>&1; then
    echo "Installing code-engine plugin"
    ibmcloud plugin install code-engine
  else
    echo "Updating code-engine plugin"
    ibmcloud plugin update code-engine --force
  fi

  echo "Check Code Engine project availability"
  if ibmcloud ce proj get -n "$(get_env code-engine-project)" > /dev/null 2>&1; then
    echo -e "Code Engine project $(get_env code-engine-project) found."
  else
    echo -e "No Code Engine project with the name $(get_env code-engine-project) found. Creating new project..."
    ibmcloud ce proj create -n "$(get_env code-engine-project)"
    echo -e "Code Engine project $(get_env code-engine-project) created."
  fi

  echo "Loading Kube config..."
  if ! ibmcloud ce proj select -n "$(get_env code-engine-project)" -k; then
    echo "Code Engine project $(get_env code-engine-project) can not be selected"
    return 1
  fi

  # check to see if $IBMCLOUD_CE_RG is not the default resource group
  if [ "$(ibmcloud resource groups --output json | jq -r --arg RG_NAME "$IBMCLOUD_CE_RG" '.[] | select(.name==$RG_NAME) | .default')" == 'false' ]; then
    echo "Updating Code Engine project to bind to resource group $IBMCLOUD_CE_RG..."
    ibmcloud ce project update --binding-resource-group "$IBMCLOUD_CE_RG"
  fi

}
