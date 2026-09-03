FROM haproxy:2.8

USER root
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/* \
USER haproxy

COPY conf/haproxy.pem /usr/local/etc/haproxy

HEALTHCHECK \
      --start-period=30s \
      --start-interval=1s \
      --interval=10s \
      --timeout=1s \
      --retries=20 \
      CMD curl --fail -s -o /dev/null -w "%{http_code}" http://localhost/internal/health

