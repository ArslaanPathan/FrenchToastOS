/* Copyright (c) 2026 Arslaan Pathan
This software is licensed under the ARPL. See LICENSE for details. */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* check if compiler thinks we are targeting incorrect OS. */
#if defined(__linux__)
#error "you are not using a cross-compiler, this is bad. use an elf cross-compiler for ix86 targets, for example, i386-elf-gcc"
#endif

/* OS only works on 32bit ix86 */
#if !defined(__i386__)
#error "this operating system is only supported on ix86 targets. use an elf cross-compiler for ix86 targets, for example, i386-elf-gcc"
#endif

/* what in the dark magic? ok just dont touch one can hope */
struct multiboot_info {
	uint32_t flags;
	uint32_t mem_lower;
	uint32_t mem_upper;
	uint32_t boot_device;
	uint32_t cmdline;
	uint32_t mods_count;
	uint32_t mods_addr;
	uint32_t syms[4];
	uint32_t mmap_length;
	uint32_t mmap_addr;
	uint32_t drives_length;
	uint32_t drives_addr;
	uint32_t config_table;
	uint32_t boot_loader_name;
	uint32_t apm_table;
	uint32_t vbe_control_info;
	uint32_t vbe_mode_info;
	uint16_t vbe_mode;
	uint16_t vbe_interface_seg;
	uint16_t vbe_interface_off;
	uint16_t vbe_interface_len;
	uint64_t framebuffer_addr;
	uint32_t framebuffer_pitch;
	uint32_t framebuffer_width;
	uint32_t framebuffer_height;
	uint8_t  framebuffer_bpp;
	uint8_t  framebuffer_type;
	uint8_t  color_info[6];
} __attribute__((packed));

void kernel_main(struct multiboot_info *mbi) 
{
	// check if framebuffer info is available (bit 12)
	if (!(mbi->flags & (1 << 12))) {
		while(1) __asm__("hlt");
	}

	uint32_t *framebuffer = (uint32_t*)(uintptr_t)mbi->framebuffer_addr;
	uint32_t width = mbi->framebuffer_width;
	uint32_t height = mbi->framebuffer_height;
	uint32_t pitch = mbi->framebuffer_pitch;

	for (uint32_t y = 0; y < height; y++) {
		for (uint32_t x = 0; x < width; x++) {
		    framebuffer[y * (pitch / 4) + x] = 0x00FFFF00;
		}
	}

	while (1) {
		__asm__ __volatile__ ("hlt");
	}
}
