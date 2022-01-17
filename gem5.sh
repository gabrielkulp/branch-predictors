#!/bin/sh

ARCH="$1"
shift

docker run --rm -it -v "$(pwd):/opt" -u $(id -u):$(id -g) "gem5-dev:$ARCH" gem5 $@
