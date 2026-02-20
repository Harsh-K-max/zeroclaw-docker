#!/usr/bin/env bash
# ZeroClaw Docker Proxy Script
# This allows you to run 'zeroclaw' commands from your host terminal

DOCKER_DATA_DIR="c:/Null/PicoCLaw/zeroclaw/.zeroclaw-docker"

# Use MSYS_NO_PATHCONV=1 to prevent path mangling on Windows
export MSYS_NO_PATHCONV=1

docker run --rm -it \
  -e HOME=/zeroclaw-data \
  -e ZEROCLAW_WORKSPACE=/zeroclaw-data/workspace \
  -v "$DOCKER_DATA_DIR/.zeroclaw:/zeroclaw-data/.zeroclaw" \
  -v "$DOCKER_DATA_DIR/workspace:/zeroclaw-data/workspace" \
  zeroclaw-bootstrap:local "$@"
