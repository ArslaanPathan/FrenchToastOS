FROM ubuntu:latest

# debug uname
RUN uname -a

RUN apt-get update && apt-get install -y \
    build-essential \
    bison \
    flex \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    texinfo \
    wget \
    grub-common \
    grub-pc-bin \
    grub-efi-ia32-bin \
    xorriso \
    mtools \
    make

WORKDIR /tmp
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz && \
    tar -xf binutils-2.41.tar.gz && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.41/configure --target=i686-elf --prefix=/opt/cross --disable-nls --disable-werror && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && rm -rf binutils-2.41* build-binutils

RUN wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz && \
    tar -xf gcc-13.2.0.tar.gz && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-13.2.0/configure --target=i686-elf --prefix=/opt/cross --disable-nls --enable-languages=c,c++ --without-headers && \
    make all-gcc -j$(nproc) && \
    make all-target-libgcc -j$(nproc) && \
    make install-gcc && \
    make install-target-libgcc && \
    cd /tmp && rm -rf gcc-13.2.0* build-gcc

ENV PATH="/opt/cross/bin:${PATH}"

WORKDIR /workspace
