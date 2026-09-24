FROM haproxy:2.8

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root. The base image already runs
# as an unprivileged user; this image uses the same "openconext" user as
# the other rootless base images for consistency.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

# The base image runs as the unprivileged "haproxy" user; build steps
# need root
USER root

RUN groupadd -g "${USER_GID}" openconext \
 && useradd -M -u "${USER_UID}" -g openconext -s /usr/sbin/nologin openconext

COPY conf/haproxy.pem /usr/local/etc/haproxy

# Warn if running as root; hand off to CMD (haproxy). The base image
# does not ship a config: downstream images must provide haproxy.cfg,
# and since this image runs without root it must only bind ports >= 1024
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER openconext
ENTRYPOINT ["/entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]