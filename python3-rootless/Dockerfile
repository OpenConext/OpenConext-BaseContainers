FROM docker.io/library/python:3.11-slim-bookworm

ENV PYTHON_VERSION_MAJOR=3
ENV PYTHON_VERSION_MINOR=3.11

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update                                    && \
    apt-get -y dist-upgrade                           && \
    apt-get -y install                                   \
        build-essential                                  \
        bzip2                                            \
        curl                                             \
        default-libmysqlclient-dev                       \
        git                                              \
        libxmlsec1-dev                                   \
        pkgconf                                          \
        python3-dev                                      \
        util-linux                                       \
        xz-utils                                         \
    && \
    apt-get -y autoremove                               \
    && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt /var/log/alternatives.log /var/log/apt /var/log/dpkg.log

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd -g "${USER_GID}" openconext \
 && useradd -M -u "${USER_UID}" -g openconext -s /usr/sbin/nologin openconext

# Copy the startup script
RUN mkdir /container-init /container-init-post
COPY --chmod=0755 ./bin/entrypoint.sh /entrypoint.sh

# Set the default workdir
WORKDIR /opt

# Run as the unprivileged user
USER openconext

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3"]