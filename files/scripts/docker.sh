#!/bin/bash

# Install Docker on Fedora.
set -euo pipefail

dnf5 -y remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

dnf5 config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

dnf -y install docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable docker

rm /etc/yum.repos.d/docker-ce.repo
