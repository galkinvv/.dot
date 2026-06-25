# syntax=docker.io/docker/dockerfile:1
# docker image for building flatpaks via gitlab-ci-local --privileged
FROM docker.io/ubuntu:resolute-20260421
RUN cat >/etc/apt/sources.list.d/ubuntu.sources <<EOF
# frozen resolute without any updates. Its docker build environment for running build inside flatpak container, no its files are exported in build result, so prefer stability to security updates
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: resolute
Components: main universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache/apt \
    --mount=type=tmpfs,target=/tmp \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-yaml python3-requests python3-pil python3-json-pointer python3-packaging ca-certificates git git-lfs elfutils && \
    python3 -u <<EOF
import hashlib, pathlib, urllib.request, subprocess
def retrieve_file(url, dest_path, sha256digest):
    for _attempt in range(3):
        try:
            print(urllib.request.urlretrieve(url, dest_path))
            break
        except Exception as e:
            print(f"retrying {url} after {e}")
    assert hashlib.file_digest(dest_path.open("rb"), "sha256").hexdigest() == sha256digest, f"{dest_path} sha256 is not {sha256digest}"

dest = pathlib.Path("/usr/local/bin/flat-manager-client")
retrieve_file("https://github.com/flatpak/flat-manager/releases/download/0.5.0/flat-manager-client.amd64", dest, "9733a148ac185bc8d7fb0429a43f9ad7d934635760bb71933658642c697f87c9")
dest.chmod(0o755)

# last version known to be compatible with running in docker. Its insecure regarding to escaping its container, but its in CI for building known artifacts
# from https://launchpad.net/ubuntu/+source/flatpak/1.16.3-1build1/+build/32305438/
flatpak_version = "_1.16.3-1build1_amd64.deb"
flatpak_deb_repo_url = "http://launchpadlibrarian.net/848709827/"
flatpak_deb_dest = pathlib.Path("/tmp/flatpak" + flatpak_version)
retrieve_file(flatpak_deb_repo_url + "flatpak" + flatpak_version, flatpak_deb_dest, "8d9f32593b9e1338d16378a5d8b5f72df858e8cfcc3ae2de95d1be26786aa409")
subprocess.call(["apt", "install", "-y", "--no-install-recommends", "--allow-downgrades", flatpak_deb_dest, "flatpak-builder"])
EOF

RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
RUN flatpak install --assumeyes --no-related flathub runtime/org.gnome.Platform/x86_64/48 \
    runtime/org.freedesktop.Sdk.Extension.toolchain-i386/x86_64/24.08 runtime/org.gnome.Sdk/x86_64/48 runtime/org.gnome.Sdk.Compat.i386/x86_64/48
RUN flatpak install --assumeyes --no-related --no-deps app/org.winehq.Wine/x86_64/stable-24.08
RUN flatpak install --assumeyes --no-related --no-deps runtime/org.winehq.Wine.mono/x86_64/stable-24.08 runtime/org.winehq.Wine.gecko/x86_64/stable-24.08
