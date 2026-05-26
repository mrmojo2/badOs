ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS{
	. = 1M;	 /* kernel will be loaded into memory 0x100000 */
	.text : ALIGN(4096){
		*(.text)
	}

	.rodata : ALIGN(4096){
		*(.rodata)
	}

	.data : ALIGN(4096){
		*(.data)
	}

	.bss : ALIGN(4096){
		*(COMMON)
		*(.bss)
	}
	.asm : ALIGN(4096){
		*(.asm)
	}

	/* order matters and the order in which the objects are passed to the linker is the order they will be kept in the sections
	 *
	 * the kernel.asm even though its asm will be in the text section because of ENTRY(_start) as it has to be the top of the code*/
}
