FROM docker.io/satosa:8

COPY ./conf/openconext-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["openconext-entrypoint.sh"]

USER root:root

# https://stackoverflow.com/questions/47062854/custom-docker-image-doesnt-inherit-cmd/47063296#47063296
CMD ["gunicorn","-b0.0.0.0:8080","satosa.wsgi:app"]
