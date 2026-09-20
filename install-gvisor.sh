#!/bin/bash

set -e
ARCH=$(uname -m)
URL=https://storage.googleapis.com/gvisor/releases/release/latest/${ARCH}
wget ${URL}/gvisor.tar.zstd ${URL}/gvisor.tar.zstd.sha512
sha512sum -c gvisor.tar.zstd.sha512
sudo tar --zstd -xf gvisor.tar.zstd -C /usr/local/bin
rm -f gvisor.tar.zstd gvisor.tar.zstd.sha512

sudo /usr/local/bin/runsc install
sudo systemctl reload docker
docker run --rm --runtime=runsc hello-world

