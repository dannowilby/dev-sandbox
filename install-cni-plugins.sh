#!/bin/bash

git clone --depth=1 -b v2.3.4 https://github.com/containerd/containerd.git
cd containerd && ./script/setup/install-cni
