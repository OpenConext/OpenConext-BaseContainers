FROM docker.io/library/debian:bookworm-slim

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update                                    && \
    apt-get -y dist-upgrade                           && \
    apt-get -y install                                   \
        build-essential                                  \
        bzip2                                            \
        ca-certificates                                  \
        curl                                             \
        default-libmysqlclient-dev                       \
        git                                              \
        libxmlsec1-dev                                   \
        pkgconf                                          \
        python3                                          \
        python3-dev                                      \
        python3-venv                                     \
        util-linux                                       \
        xz-utils                                         \
        && \
    apt-get -y autoremove                             && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# if specified, drop privileges to this uid and gid
ARG RUNAS_UID
ARG RUNAS_GID

# install default venv
RUN \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip wheel setuptools

ENV VIRTUAL_ENV="/venv"
ENV PATH="/venv/bin:${PATH}"

# Set the default workdir
WORKDIR /venv

# Copy the startup script
RUN mkdir /container-init /container-init-post
COPY --chmod=0755 ./bin/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python3"]
