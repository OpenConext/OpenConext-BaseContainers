FROM eclipse-temurin:21-jre-alpine

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

RUN addgroup -g "${USER_GID}" openconext \
 && adduser -D -H -u "${USER_UID}" -G openconext -s /sbin/nologin openconext

# Default workdir, owned by the unprivileged user
WORKDIR /app
RUN chown -R openconext:openconext /app

# Warn if running as root; hand off to CMD
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER openconext
ENTRYPOINT ["/entrypoint.sh"]