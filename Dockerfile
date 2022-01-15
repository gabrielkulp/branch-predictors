FROM debian:11
WORKDIR /usr/local/src

# Install dependencies
RUN apt update
RUN apt install -y build-essential git m4 scons zlib1g zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev python-dev-is-python3

# Get the code
RUN git clone https://gem5.googlesource.com/public/gem5

# Build it
WORKDIR /usr/local/src/gem5
RUN scons build/X86/gem5.opt -j `nproc`

# Next, copy the contents of this repo into the image
# todo

# And finally build it again with our changes
# todo
