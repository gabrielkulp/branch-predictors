#!/bin/sh

ARCH=RISCV
BIN_TYPE=opt

usage() {
	echo "Usage: $0 [-a ARCH] [-t TYPE] [-x]"
	echo "    ARCH can be RISCV, ARM, or X86"
	echo "    TYPE can be debug, opt, fast, prof, perf"
	echo "Default is RISCV opt."
	echo "Use -x to create a smaller export container at the end."
	exit 2
}

while getopts 'hxa:t:' c
do
case $c in
	h) usage ;;
	x) EXPORT=true ;;
	a) ARCH=$OPTARG ;;
	t) BIN_TYPE=$OPTARG ;;
	
esac; done

# build the full development image (it's over 5GB)
echo "Building $ARCH/gem5.$BIN_TYPE executable"
docker build . \
	--build-arg ARCH=$ARCH \
	--build-arg BIN_TYPE=$BIN_TYPE \
	-t gabrielkulp/gem5-build:$ARCH

# only do the export if -x is provided
if [ -n "$EXPORT" ]; then
	echo "Creating new container to export"
	IMAGE=$(docker build -q - < Dockerfile-run)
	ID=$(docker create $IMAGE)
	echo "Exporting executable to smaller image"
	docker export $ID | docker import - gabrielkulp/gem5:$ARCH -c 'CMD [ "gem5", "--help" ]'
	echo "Tagged gabrielkulp/gem5:$ARCH"
	echo "Removing temporary container and image"
	docker rm $ID
	docker rmi $IMAGE
fi
echo "Done!"
