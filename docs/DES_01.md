
# 1. Introduction

## Problem

Need a good way to sandbox dev environments
- cleanup: dependencies won't bloat the system after
- supply chain protection: malicious dependencies will be limited in their effect

## Goals

Create an interface to interact with a sandboxed development environment.

## Non-goals

Authentication/Authorization: having a user provide credentials to access the
sandboxed environment is out of scope.

# 2. Functional requirements

```sh
./dev-box start <name>
./dev-box stop <name>

# example
./dev-box start vvrs
```

Running this command creates and connects an ssh connection to a development
environment. When the ssh connection is closed, the box is deleted.

If a box with the name already exists, it should connect to it.

# 3. Technical Spec

[agent-sandbox](https://github.com/kubernetes-sigs/agent-sandbox/) will be used
to provision the sandboxes.

SSH requests will be routed through the control plane with kubectl.