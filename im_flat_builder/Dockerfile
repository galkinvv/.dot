# syntax=docker.io/docker/dockerfile:1
FROM docker.io/ubuntu:resolute-20260312
RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache/apt \
    apt-get update &&\
    apt-get install -y --no-install-recommends flatpak-builder python3 ca-certificates git git-lfs elfutils &&\
    apt-get install -y --no-install-recommends python3-yaml python3-requests python3-pil python3-json-pointer python3-packaging
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
RUN flatpak install --assumeyes --no-related org.gnome.Sdk/x86_64/48 org.gnome.Platform/x86_64/48 org.winehq.Wine/x86_64/stable-24.08 org.gnome.Sdk.Compat.i386/x86_64/48 org.freedesktop.Sdk.Extension.toolchain-i386/x86_64/24.08
# Usage gitlab-ci-local --privileged --mount-cache --variable im_flat_builder=im_flat_builder
