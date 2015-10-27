FROM debian:jessie
MAINTAINER Przemek Wesołek <przemek@wesolek.net>

# Install OpenSSH
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*

# sshd needs this directory to run
RUN mkdir -p /var/run/sshd

# Copy configuration and entrypoint script
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /

EXPOSE 22

ENV STORAGE_DIR storage

ENTRYPOINT ["/entrypoint"]
