
# 1. Introduction

## Problem

Need a way to actually develop in the container.
- vim or helix or vscode
- git
- proper language toolchain

Also need to be able to view output.
- code execution
- guis
- images

## Goals

Change the base docker image and create a build script. Add a port to allow
external access for servers displaying data.

## Non-goals

- Fine tune the image for development
- Create an unneeded versioning system

# 2. Functional requirements

- The docker image and build scripts should be in the repo and not stored in my
head
- A port should be opened so if configured with vs code, it can be connected to
  via the port
    - this also allows servers to run, showing more graphical output

# 3. Technical Spec

- Bash script for building
- Port forwarding for containers
- The agent-sandbox project provides a sandbox-router to directly route traffic
  to pods