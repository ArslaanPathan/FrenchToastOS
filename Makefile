CC = i386-elf-gcc
AS = i386-elf-as
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra

OBJS = src/boot.o src/kernel.o

.PHONY: all clean iso-files

all: FrenchToastOS-bios.iso FrenchToastOS-efi.iso

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

FrenchToastOS-bios.iso: iso-files
	grub-mkrescue /usr/lib/grub/i386-pc -o FrenchToastOS-bios.iso isodir

FrenchToastOS-efi.iso: iso-files
	grub-mkrescue -o FrenchToastOS-efi.iso isodir

clean:
	rm -f $(OBJS) FrenchToastOS.bin FrenchToastOS-bios.iso FrenchToastOS-efi.iso
	rm -rf isodir
