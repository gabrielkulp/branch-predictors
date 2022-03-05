# this is just a wrapper around build.sh

# default target
all: queens.c matmul.c Dockerfile build.sh
	./build.sh

clean:
	rm -f queens.x86 queens.riscv queens.arm
	rm -f matmul.x86 matmul.riscv matmul.arm

.PHONY: all clean

