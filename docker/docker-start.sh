#!/usr/bin/env bash

set -euo pipefail

export RED='\e[31m'
export YELLOW='\e[33m'
export GREEN='\e[32m'
export BLUE='\e[34m'
export NC='\e[0m'

export JENKINS_CONTAINER="azure-lab-jenkins"
export VAULT_CONTAINER="azure-lab-vault"
VER="latest"

JENKINS_URL="http://localhost:8080"
VAULT_URL="http://localhost:8200"

BUILD_EXEC="./docker-start.sh --build"
if [ $# -gt 0 ] && [ "$1" != "--build" ]; then
    echo -e "${RED}Unknown argument: $1${NC}"
    echo "Usage: ${BUILD_EXEC}"
    exit 1
fi

check_image() {
    full_image="${1}:${VER}"
    if docker image inspect "${full_image}" >/dev/null 2>&1; then
        echo -e "${GREEN}Image ${full_image} exists${NC}"
        return 0
    else
        echo -e "${YELLOW}Image ${full_image} not found${NC}"
        return 1
    fi
}


echo -e "\n${BLUE}1. Checking Docker Compose${NC}"
if ! docker compose version >/dev/null 2>&1; then
    echo -e "${RED}Docker Compose is not installed.${NC}"
    exit 1
else
    docker compose version
fi

echo -e "\n${BLUE}2. Setting up Docker images${NC}"
echo "You can recreate the images by executing: ${BUILD_EXEC}"
FORCE_BUILD=false
if [ "${1:-}" = "--build" ]; then
    FORCE_BUILD=true
fi

if [ "$FORCE_BUILD" = true ]; then
    echo -e "${YELLOW}Forced build requested.${NC}"
    docker compose build --no-cache
else
    BUILD_REQUIRED=false
    
    if ! check_image "${JENKINS_CONTAINER}"; then
        BUILD_REQUIRED=true
    fi

    if ! check_image "${VAULT_CONTAINER}"; then
        BUILD_REQUIRED=true
    fi

    if [ "$BUILD_REQUIRED" = true ]; then
        echo -e "\n${YELLOW}2.1 Building Docker images${NC}"
        docker compose build
    else
        echo -e "${GREEN}All images already exist. Skipping build.${NC}"
    fi
fi

echo -e "\n${BLUE}3. Starting containers${NC}"
docker compose up -d

echo -e "\n${BLUE}4. Waiting for Jenkins${NC}"
timeout 120 bash -c "
until curl -fs ${JENKINS_URL}/login >/dev/null 2>&1; do
    sleep 2
done
"

echo -e "${GREEN}Jenkins is ready${NC}"
docker exec "${JENKINS_CONTAINER}" java -version

echo -e "\n${BLUE}5. Waiting for Vault${NC}"
SECONDS=0
while true; do
    set +e
    docker exec "${VAULT_CONTAINER}" vault status >/dev/null 2>&1
    STATUS=$?

    if [ "$STATUS" -eq 0 ] || [ "$STATUS" -eq 2 ]; then
        break
    fi

    sleep 2

    if [ "$SECONDS" -ge 90 ]; then
        echo -e "${RED}Vault did not start in time.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}Vault is up${NC}"
docker exec "${VAULT_CONTAINER}" vault version

echo -e "\n${BLUE}5.1 Initializing Vault Setup${NC}"
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi
./vault/init/init.sh

echo -e "\n${BLUE}6. Show running containers${NC}"
docker compose ps

echo -e "\n${GREEN}✓ Jenkins : ${JENKINS_URL}"
echo -e "✓ Vault   : ${VAULT_URL}${NC}"
