#!/bin/sh

echo "installing binfmt hooks because alarm is bad and it keeps breaking on reboot"
echo -1 | sudo tee /proc/sys/fs/binfmt_misc/qemu-x86_64
docker run --privileged --rm tonistiigi/binfmt --install amd64

echo "actually running alpine"
docker run -it --mount type=bind,src=$(dirname "$0"),target=/workspace --platform linux/amd64 --rm alpine:latest
