#!/bin/bash

set -euo pipefail

RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'
BLUE='\e[34m'
NC='\e[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
REPOSITORY_NAME=$(basename "${REPO_ROOT}")
ENV_FILE="${REPO_ROOT}/docker/.env"
touch "${ENV_FILE}"

GITHUB_STATUS="SKIPPED"
AZURE_STATUS="SKIPPED"

confirm() {
    local prompt="$1"

    while true; do
        read -rp "${prompt} [y/N]: " answer

        case "${answer}" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo]|"")
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

set_env() {
    local key="$1"
    local value="$2"

    if grep -q "^${key}=" "${ENV_FILE}"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "${ENV_FILE}"
    else
        echo "${key}=${value}" >> "${ENV_FILE}"
    fi
}



echo -e "${BLUE}8.1 Create a GitHub Fine-grained PAT${NC}"
if confirm "Do you want to create a GitHub Token?"; then
  echo "Nice! Then open the following URL:"

  BASE_URL="https://github.com/settings/personal-access-tokens/new"

  PARAMS="name=Azure%20Infrastructure%20Lab"
  PARAMS="${PARAMS}&description=Token%20for%20Jenkins%20Pipeline"
  PARAMS="${PARAMS}&expires_in=30"
  PARAMS="${PARAMS}&contents=read"

  echo
  echo "${BASE_URL}?${PARAMS}"
  echo
  echo "Then configure:"
  echo "  • Repository access: Only select repositories"
  echo "  • Repository: ${REPOSITORY_NAME}"
  echo
  echo "Please make sure the following variables exist in:"
  echo "  ${ENV_FILE}"
  echo
  cat <<EOF
GITHUB_USERNAME=<your_github_username>
GITHUB_TOKEN=<your_github_pat>
EOF
    echo
  GITHUB_STATUS="PENDING"

else
    echo
    echo "Please make sure the following variables exist in:"
    echo "  ${ENV_FILE}"
    echo

    cat <<EOF
GITHUB_USERNAME=<your_github_username>
GITHUB_TOKEN=<your_github_pat>
EOF
    echo
fi


echo
echo -e "${BLUE}8.2 Azure Service Principal${NC}"
if confirm "Create an Azure Service Principal?"; then
  if ! az account show >/dev/null 2>&1; then
      echo "No Azure session detected."
      echo "Opening Azure login..."
      az login
  fi

  echo
  echo "Available subscriptions:"
  az account list -o table
  echo

  SUBSCRIPTIONS=$(az account list --query "length([])" -o tsv)

  if [ "${SUBSCRIPTIONS}" -gt 1 ]; then
      read -rp "Subscription ID: " SUBSCRIPTION_ID
      az account set --subscription "${SUBSCRIPTION_ID}"
  else
      SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  fi

  echo "Using subscription:"
  az account show --output table

  if az ad sp list --display-name ${REPOSITORY_NAME} --query "[].id" -o tsv | grep -q .; then
    echo -e "${YELLOW}\nAzure SP '${REPOSITORY_NAME}' already exists for sub '${SUBSCRIPTION_ID}'${NC}"
    AZURE_STATUS="PENDING"
  else
    echo
    echo "Creating Azure SP for '${SUBSCRIPTION_ID}'"

    SP_JSON=$(az ad sp create-for-rbac \
        --name "${REPOSITORY_NAME}" \
        --role Contributor \
        --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
        --json-auth)

    CLIENT_ID=$(echo "${SP_JSON}" | jq -r '.clientId')
    CLIENT_SECRET=$(echo "${SP_JSON}" | jq -r '.clientSecret')
    TENANT_ID=$(echo "${SP_JSON}" | jq -r '.tenantId')

    set_env "AZURE_CLIENT_ID" "${CLIENT_ID}"
    set_env "AZURE_CLIENT_SECRET" "${CLIENT_SECRET}"
    set_env "AZURE_TENANT_ID" "${TENANT_ID}"
    set_env "AZURE_SUBSCRIPTION_ID" "${SUBSCRIPTION_ID}"

    echo
    echo -e "${GREEN}Azure Service Principal created successfully.${NC}"
    echo "Credentials written to ${ENV_FILE}"
    AZURE_STATUS="CREATED"
  fi
else

    echo
    echo "Please make sure the following variables exist in:"
    echo "  ${ENV_FILE}"
    echo

    cat <<EOF
AZURE_CLIENT_ID=<client_id>
AZURE_CLIENT_SECRET=<client_secret>
AZURE_TENANT_ID=<tenant_id>
AZURE_SUBSCRIPTION_ID=<subscription_id>
EOF
    echo

fi

echo
echo -e "${BLUE}========== Configuration Summary ==========${NC}"

if [ "${GITHUB_STATUS}" = "PENDING" ]; then
    echo -e "${GREEN}✓ GitHub PAT pending${NC}"
else
    echo -e "${YELLOW}⚠  GitHub PAT skipped${NC}"
fi

if [ "${AZURE_STATUS}" = "CREATED" ]; then
    echo -e "${GREEN}✓ Azure Service Principal configured${NC}"
elif [ "${AZURE_STATUS}" = "PENDING" ]; then
    echo -e "${GREEN}⚠  Azure Service Principal pending${NC}"
else
    echo -e "${YELLOW}⚠  Azure Service Principal skipped${NC}"
fi

echo -e "${GREEN}✓ Credentials file: ${ENV_FILE}${NC}"
echo
