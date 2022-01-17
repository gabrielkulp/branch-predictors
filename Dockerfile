FROM debian:11

# Install dependencies
RUN apt update \
 && apt install -y build-essential git m4 scons zlib1g \
    zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev \
    libgoogle-perftools-dev python-dev-is-python3 python3-pydot

# Get the code (v21.2.0.0)
ARG SRC_DIR=/usr/local/src/gem5
RUN git clone https://gem5.googlesource.com/public/gem5 $SRC_DIR \
 && cd $SRC_DIR \
 && git checkout f554b1a7b56b5889bd5daec6e09eda8c3fbd93d1



# ARCH options are RISCV, ARM, X86, and some others.
# details here: http://old.gem5.org/Supported_Architectures.html
# and: https://www.gem5.org/documentation/general_docs/architecture_support/
ARG ARCH=RISCV

# BIN_TYPE options are debug, opt, fast, prof, perf
# details here: http://learning.gem5.org/book/part1/building.html
ARG BIN_TYPE=opt



# Build it
WORKDIR $SRC_DIR
ARG BUILD_TARGET="build/$ARCH/gem5.$BIN_TYPE"
RUN scons $BUILD_TARGET -j `nproc`

# Next, copy the contents of this repo into the image
COPY ./gem5 $SRC_DIR

# Build it again with our changes
RUN scons $BUILD_TARGET -j `nproc`

# Copy resulting binary somewhere nice
RUN cp $BUILD_TARGET /usr/local/bin/gem5

# Set built binary as the default command for this image
CMD [ "gem5", "--help" ]
