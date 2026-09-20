#!/bin/bash
#
# Install gVisor into a kind node's containerd.
#
# install-gvisor.sh registers runsc with the *host's* Docker daemon. That is not
# what runs your pods -- the kind node is itself a container running its own
# containerd, and that containerd is what the kubelet talks to. This script
# installs runsc and the shim inside the node and registers a "runsc" runtime
# handler, which is what RuntimeClass/gvisor resolves to.

set -e

NODE=${1:-agent-sandbox-control-plane}
ARCH=$(uname -m)
URL=https://storage.googleapis.com/gvisor/releases/release/latest/${ARCH}
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

echo "Downloading gVisor (${ARCH})..."
wget -q -P "$WORKDIR" ${URL}/gvisor.tar.zstd ${URL}/gvisor.tar.zstd.sha512
(cd "$WORKDIR" && sha512sum -c gvisor.tar.zstd.sha512)
tar --zstd -xf "$WORKDIR/gvisor.tar.zstd" -C "$WORKDIR"

echo "Copying gVisor into node ${NODE}..."
# The release ships more than runsc + the shim: gvisor-bin/ holds the sentry
# sidecar and friends, and runsc refuses to start without them. Copy the whole
# extracted tree, the way the host-side install untars it into /usr/local/bin.
for f in "$WORKDIR"/runsc "$WORKDIR"/containerd-shim-runsc-v1 "$WORKDIR"/gvisor-bin; do
  docker cp "$f" "${NODE}:/usr/local/bin/"
done
docker exec "$NODE" chown -R root:root /usr/local/bin/runsc \
  /usr/local/bin/containerd-shim-runsc-v1 /usr/local/bin/gvisor-bin
docker exec "$NODE" chmod -R 755 /usr/local/bin/runsc \
  /usr/local/bin/containerd-shim-runsc-v1 /usr/local/bin/gvisor-bin

echo "Registering runsc runtime handler in the node's containerd..."
docker exec -i "$NODE" bash -s <<'INNER'
set -e
CONFIG=/etc/containerd/config.toml

if grep -q 'runtimes.runsc' "$CONFIG"; then
  echo "  runsc handler already present, leaving config alone"
else
  cat >> "$CONFIG" <<'TOML'

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc.options]
    TypeUrl = "io.containerd.runsc.v1.options"
    ConfigPath = "/etc/containerd/runsc.toml"
TOML
  echo "  appended runsc handler"
fi

# Nested containers: the node already owns the cgroup hierarchy, so let runsc
# stay out of it. systrap is the default platform and needs no KVM access.
cat > /etc/containerd/runsc.toml <<'TOML'
[runsc_config]
  platform = "systrap"
  ignore-cgroups = "true"
TOML

systemctl restart containerd
INNER

echo "Waiting for containerd to come back..."
for _ in $(seq 30); do
  docker exec "$NODE" crictl info >/dev/null 2>&1 && break
  sleep 1
done

if docker exec "$NODE" crictl info -o json 2>/dev/null \
     | tr -d ' "' | grep -q '^runsc:{$'; then
  echo "runsc handler is live in CRI."
else
  echo "ERROR: containerd did not pick up the runsc handler."
echo "  check: docker exec $NODE journalctl -u containerd -n 50"
  exit 1
fi
