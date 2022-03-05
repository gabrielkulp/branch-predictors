From debian:11

# x86 toolchain
RUN apt update && apt install -y gcc gcc-riscv64-linux-gnu gcc-arm-linux-gnueabihf

WORKDIR /opt
COPY queens.c matmul.c /opt/

ARG QUEENS_CFLAGS="-g -O3 -std=c99 -static"
ARG MATMUL_CFLAGS="-g -O3 -std=c99 -static -funroll-loops -fno-math-errno -fno-trapping-math -fassociative-math -ffinite-math-only -fno-signaling-nans -fno-signed-zeros -ftree-vectorize -fcx-limited-range"

RUN gcc                     $QUEENS_CFLAGS queens.c -o queens.x86   \
 && gcc                     $MATMUL_CFLAGS matmul.c -o matmul.x86   \
 && riscv64-linux-gnu-gcc   $QUEENS_CFLAGS queens.c -o queens.riscv \
 && riscv64-linux-gnu-gcc   $MATMUL_CFLAGS matmul.c -o matmul.riscv \
 && arm-linux-gnueabihf-gcc $QUEENS_CFLAGS queens.c -o queens.arm   \
 && arm-linux-gnueabihf-gcc $MATMUL_CFLAGS matmul.c -o matmul.arm
