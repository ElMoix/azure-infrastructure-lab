#!/bin/sh

# Just used this because the image from the Dockerhub uses "root", not "vault"

set -e
chown -R vault:vault /vault/data
exec /usr/local/bin/docker-entrypoint.sh "$@"
