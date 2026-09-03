FROM docker.io/satosa:8
USER root:root
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/openconext-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["openconext-entrypoint.sh"]

USER root:root

# https://stackoverflow.com/questions/47062854/custom-docker-image-doesnt-inherit-cmd/47063296#47063296
CMD ["gunicorn","-b0.0.0.0:8080","satosa.wsgi:app"]

HEALTHCHECK \
      --start-period=30s \
      --start-interval=1s \
      --interval=10s \
      --timeout=1s \
      --retries=20 \
      CMD curl --fail -s -o /dev/null -w "%{http_code}" http://localhost/internal/health
