/* Copyright (c) 2026 Arslaan Pathan
This software is licensed under the ARPL. See LICENSE for details. */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "font8x8_basic.h"

/* check if compiler thinks we are targeting incorrect OS. */
#if defined(__linux__)
#error "you are not using a cross-compiler, this is bad. use an elf cross-compiler for ix86 targets, for example, i386-elf-gcc"
#endif

/* OS only works on 32bit ix86 */
#if !defined(__i386__)
#error "this operating system is only supported on ix86 targets. use an elf cross-compiler for ix86 targets, for example, i386-elf-gcc"
#endif

static int term_col = 0;
static int term_row = 0;
static uint32_t *g_framebuffer = NULL;
static uint32_t g_width = 0;
static uint32_t g_height = 0;
static uint32_t g_default_color = 0xFFFFFF;

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

void draw_char(int x, int y, int c, uint32_t color, uint32_t *framebuffer, uint32_t width)
{
	char *glyph = font8x8_basic[(unsigned char)c];

	for (int row = 0; row < 8; row++) {
		for (int col = 0; col < 8; col++) {
			if (glyph[row] & (1 << col)) {
				framebuffer[(y + row) * width + (x + col)] = color;
			}
		}
	}
}

void draw_string(int x, int y, const char *str, uint32_t color, uint32_t *framebuffer, uint32_t width)
{
	while (*str) {
		draw_char(x, y, *str, color, framebuffer, width);
		x += 8;
		str++;
	}
}

void term_init(uint32_t *framebuffer, uint32_t width, uint32_t height)
{
	g_framebuffer = framebuffer;
	g_width = width;
	g_height = height;
	term_col = 0;
	term_row = 0;
}

void term_set_color(uint32_t color)
{
	g_default_color = color;
}

void term_printf(const char *str)
{
	while (*str) {
		if (*str == '\n') {
			term_col = 0;
			term_row++;
			str++;
			continue;
		}

		if ((term_col * 8) >= g_width) {
			term_col = 0;
			term_row++;
		}

		if ((term_row * 8) >= g_height) {
			term_row = 0; // just simple wrap around for now, scroll later
		}

		draw_char(term_col * 8, term_row * 8, *str, g_default_color, g_framebuffer, g_width);

		term_col++;
		str++;
	}
}

void kernel_main(struct multiboot_info *mbi) 
{
	// check if framebuffer info is available (bit 12)
	if (!(mbi->flags & (1 << 12))) {
		while(1) __asm__("hlt");
	}

	// get the framebuffer
	uint32_t *framebuffer = (uint32_t*)(uintptr_t)mbi->framebuffer_addr;
	uint32_t width = mbi->framebuffer_width;
	uint32_t height = mbi->framebuffer_height;

	// draw text to the framebuffer
	term_init(framebuffer, width, height);
	term_printf("welcome to ");
	term_set_color(0xFCD24D);
	term_printf("FrenchToastOS!\n");
	term_set_color(0xFFFFFF);
	term_printf("developed by ");
	term_set_color(0x967BB6);
	term_printf("Arslaan Pathan\n");
	term_set_color(0xFFFFFF);
	term_printf("---\n");
	term_printf("https://arslaancodes.com\n");

	// if theres nothing left to do, halt the cpu or else cooked
	// our boot.s already does this but better to be safe than sorry
	while (1) {
		__asm__ __volatile__ ("hlt");
	}
}
