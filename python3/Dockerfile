# First build SRAM SBS image
FROM docker.io/library/python:3.11-slim-bookworm

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
    apt-get -y autoremove                             && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# if specified, drop privileges to this uid and gid
ARG RUNAS_UID
ARG RUNAS_GID

# Copy the startup script
RUN mkdir /container-init /container-init-post
COPY --chmod=0755 ./bin/entrypoint.sh /entrypoint.sh

# Set the default workdir
WORKDIR /opt

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3"]
