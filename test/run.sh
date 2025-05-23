#!/usr/bin/env bash
set -e

docker build -f test/Dockerfile.test -t mytools-test .
docker run --rm mytools-test