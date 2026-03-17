CC = i686-elf-gcc
AS = nasm
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra

SRCS = src/kernel.c
OBJS = src/boot.o src/kernel.o

all: FrenchToastOS.iso

src/boot.o: src/boot.asm
	$(AS) -f elf32 src/boot.asm -o src/boot.o

src/kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o src/kernel.o

FrenchToastOS.bin: $(OBJS)
	$(CC) -T linker.ld -o FrenchToastOS.bin -ffreestanding -O2 -nostdlib $(OBJS) -lgcc

FrenchToastOS.iso: FrenchToastOS.bin
	mkdir -p isodir/boot/grub
	cp FrenchToastOS.bin isodir/boot/
	cp boot/grub.cfg isodir/boot/grub/
	grub-mkrescue -o FrenchToastOS.iso isodir

clean:
	rm -f $(OBJS) FrenchToastOS.bin FrenchToastOS.iso
	rm -rf isodir
