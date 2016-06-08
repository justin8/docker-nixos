#!/bin/bash
set -e

cd "$(readlink -f "$(dirname "$0")")"

VERSION=$(grep VERSION= nixos-builder/Dockerfile | grep -oE '[0-9.]+')

docker build --rm -t local/nixos-builder ./nixos-builder
docker tag -f local/nixos-builder local/nixos-builder:$VERSION
docker run --privileged --rm -v $PWD:/out:rw local/nixos-builder
docker build --rm -t local/nixos ./nixos
docker tag -f local/nixos local/nixos:$VERSION
