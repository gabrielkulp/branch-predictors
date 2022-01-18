#!/bin/sh

CONTAINER="$1"
shift

docker run --rm -it -v "$(pwd):/opt" -u $(id -u):$(id -g) "$CONTAINER" gem5 $@
