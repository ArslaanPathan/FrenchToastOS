#!/bin/sh

# Copyright (c) 2026 Arslaan Pathan
# This software is licensed under the ARPL. See LICENSE for details.

echo "installing binfmt hooks because ALARM is bad and it keeps breaking on reboot"
echo -1 | sudo tee /proc/sys/fs/binfmt_misc/qemu-x86_64
docker run --privileged --rm tonistiigi/binfmt --install amd64

echo "actually running alpine"
docker run -it --mount type=bind,src=$(dirname "$0"),target=/workspace --platform linux/amd64 --rm alpine:latest
