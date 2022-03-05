#!/bin/sh

docker build -t benchmark_build .
docker create --name extract benchmark_build

docker cp extract:/opt/matmul.x86 ./matmul.x86
docker cp extract:/opt/queens.x86 ./queens.x86
docker cp extract:/opt/matmul.riscv ./matmul.riscv
docker cp extract:/opt/queens.riscv ./queens.riscv
docker cp extract:/opt/matmul.arm ./matmul.arm
docker cp extract:/opt/queens.arm ./queens.arm

docker rm extract
