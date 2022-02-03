#!/bin/sh

ARCH=RISCV
BIN_TYPE=opt

usage() {
	echo "Usage: ${0} [-a ARCH] [-t TYPE] [-nx] [-u REPO]"
	echo "    ARCH can be RISCV, ARM, or X86. Default is RISCV."
	echo "    TYPE can be debug, opt, fast, prof, perf. Default is opt."
	echo "    -n to skip building (you could use this with -x and -u)"
	echo "    -x to create a smaller export container at the end."
	echo "    -u to upload the final exported container to REPO/gem5:ARCH."
	exit 2
}

while getopts 'xna:t:u:' c
do
case ${c} in
	x) EXPORT=true ;;
	n) NOBUILD=true ;;
	a) ARCH="${OPTARG}" ;;
	t) BIN_TYPE="${OPTARG}" ;;
	u) OWNER="${OPTARG}" ;;
	*) usage ;;
esac; done

# build the full development image (it's over 5GB)
# but only if -n is NOT provided
if [ -z "${NOBUILD}" ]; then
	echo "Building ${ARCH}/gem5.${BIN_TYPE} executable"
	docker build . \
		--build-arg "ARCH=${ARCH}" \
		--build-arg "BIN_TYPE=${BIN_TYPE}" \
		-t gem5-dev:"${ARCH}"
fi

# only do the export if -x is provided
if [ -n "${EXPORT}" ]; then
	echo "Creating new container to export"
	IMAGE=$(docker build -q --build-arg "ARCH=${ARCH}" - < Dockerfile-release)
	ID=$(docker create "${IMAGE}")
	echo "Exporting executable to smaller image"
	docker export "${ID}" | docker import - "gem5:${ARCH}" -c 'WORKDIR /opt' -c 'CMD [ "gem5", "--help" ]'
	echo "Tagged gem5:${ARCH}"
	echo "Removing temporary container and image"
	docker rm "${ID}"
	docker rmi "${IMAGE}"
fi

# only do the upload if -u is provided
if [ -n "${OWNER}" ]; then
	docker tag "gem5:${ARCH}" "${OWNER}/gem5:${ARCH}"
	docker push "${OWNER}/gem5:${ARCH}"
fi

echo "Done!"
