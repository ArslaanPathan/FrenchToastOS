CC = i686-elf-gcc
AS = i686-elf-as
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra

OBJS = src/boot.o src/kernel.o

.PHONY: all clean iso-files

all: FrenchToastOS.iso

src/boot.o: src/boot.s
	$(AS) src/boot.s -o src/boot.o

src/kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c src/kernel.c -o src/kernel.o

FrenchToastOS.bin: $(OBJS)
	$(CC) -T linker.ld -o FrenchToastOS.bin -ffreestanding -O2 -nostdlib $(OBJS) -lgcc

iso-files: FrenchToastOS.bin
	mkdir -p isodir/boot/grub
	cp FrenchToastOS.bin isodir/boot/
	cp boot/grub.cfg isodir/boot/grub/

FrenchToastOS.iso: iso-files
	grub-mkrescue /usr/lib/grub/i386-pc /usr/lib/grub/i386-efi /usr/lib/grub/x86_64-efi -o FrenchToastOS.iso isodir

clean:
	rm -f $(OBJS) FrenchToastOS.bin FrenchToastOS.iso
	rm -rf isodir
