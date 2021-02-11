FROM grafana/tanka:0.14

LABEL org.opencontainers.image.source="https://github.com/letsbuilders/tanka-action"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
