#!/usr/bin/env bash

set -euo pipefail

SECRETS_DIR="$(cd "$(dirname "$0")"/.. && pwd)/secrets"
mkdir -p "$SECRETS_DIR"

###########
vault_status() {
    docker exec "$VAULT_CONTAINER" vault status 2>/dev/null || {
        local exit_code=$?

        if [ "$exit_code" -ne 2 ]; then
            return "$exit_code"
        fi
    }
}

###########
STATUS=$(vault_status)
INITIALIZED=$(echo "$STATUS" | awk '/Initialized/ {print $2}')
if [ "$INITIALIZED" = "false" ]; then
    echo -e "${GREEN}Initializing Vault${NC}"

    INIT_OUTPUT=$(docker exec "$VAULT_CONTAINER" \
        vault operator init \
        -key-shares=3 \
        -key-threshold=2)

    echo "$INIT_OUTPUT"
    echo "$INIT_OUTPUT" | awk '/Unseal Key 1:/ {print $4}' > "$SECRETS_DIR/unseal-key-1"
    echo "$INIT_OUTPUT" | awk '/Unseal Key 2:/ {print $4}' > "$SECRETS_DIR/unseal-key-2"
    echo "$INIT_OUTPUT" | awk '/Unseal Key 3:/ {print $4}' > "$SECRETS_DIR/unseal-key-3"
    echo "$INIT_OUTPUT" | awk '/Initial Root Token:/ {print $4}' > "$SECRETS_DIR/root-token"
    echo -e "\n${GREEN}[INFO] Secrets saved at ${SECRETS_DIR}${NC}"
else
    echo -e "${YELLOW}Vault already initialized${NC}"

    if [ ! -f "$SECRETS_DIR/unseal-key-1" ]; then
        echo -e "${RED}[ERROR] Vault is initialized but unseal keys are missing${NC}"
	echo "Restore vault/secrets or remove the Vault data volume (docker compose down -v)"
        exit 1
    fi
fi

###########
SEALED=$(echo "$STATUS" | awk '/Sealed/ {print $2}')
if [ "$SEALED" = "true" ]; then
    echo -e "\n${GREEN}Unsealing Vault${NC}"
    docker exec "$VAULT_CONTAINER" \
        vault operator unseal "$(cat "$SECRETS_DIR/unseal-key-1")"

    docker exec "$VAULT_CONTAINER" \
        vault operator unseal "$(cat "$SECRETS_DIR/unseal-key-2")"
else
    echo -e "${YELLOW}Vault already unsealed${NC}"
fi
