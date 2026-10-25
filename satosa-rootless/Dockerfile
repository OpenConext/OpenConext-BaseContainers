FROM docker.io/satosa:8

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

# The base image runs as the unprivileged "satosa" user; build steps
# need root
USER root

# The base image entrypoint generates the SATOSA config in /etc/satosa
# at start, so it needs to be writable by the unprivileged user
RUN groupadd -g "${USER_GID}" openconext \
 && useradd -M -u "${USER_UID}" -g openconext -s /usr/sbin/nologin openconext \
 && chown -R openconext:openconext /etc/satosa

# Warn if running as root; hand off to the base image entrypoint, which
# generates the config and starts gunicorn
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER openconext
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn","-b0.0.0.0:8080","satosa.wsgi:app"]