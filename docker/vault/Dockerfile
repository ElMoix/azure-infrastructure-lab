FROM hashicorp/vault:1.20.4

USER root

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-custom.sh

RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
