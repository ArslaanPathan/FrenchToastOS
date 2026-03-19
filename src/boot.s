/* Copyright (c) 2026 Arslaan Pathan
This software is licensed under the ARPL. See LICENSE for details. */

/* Multiboot header dark magic, do not touch */
.set ALIGN, 1<<0
.set MEMINFO, 1<<1
.set FLAGS, ALIGN | MEMINFO
.set MAGIC, 0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot 
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Multiboot does not define the esp/stack, create the stack ourselves */
.section bss
/* Stack on x86 must be 16-byte aligned by the System V ABI standard */
.align 16
/* Create a symbol at the bottom, allocate 16KiB, then finally create a symbol at the top */
stack_bottom:
.skip 16384
stack_top:

/* _start is the entrypoint */
.section .text
.global _start
.type _start, @function
_start:
	/* we are in 32bit protected mode
	interrupts disabled, paging disabled
	kernel has full control over cpu */

	/* setup the stack, point to the top becausei t grows downwrad on x86 for som e reason */
	mov $stack_top, %esp

	/* here we need to init crucial processor state.
	load the gdt, enable pages, init isa extensions/floating point instructions and stuff
	for now just dont do anything we'll add that later(TM) */

	/* enter the high level kernel
	ABI says we need 16-byte alignment here, we aligned that before and pushed a multiple of 16 bits (zero) so we fine
	but i will realign for good measure anyway */
	.align 16 
	call kernel_main

	/* if nothing left then just infinite loop */
	/*
	1. disable interrupts with cli/clear interrupts 
	2. wait for next interrupt with hlt. because they disabled this will just lockup the ocmputer
	3. justincase it wakes up just jmp back to the hlt instruction
	*/
	cli
1:	hlt
	jmp 1b

/* set the size of the _start symbol to the current location (.) minus it's _start 
for debugging stuff */
.size _start, . - _start
