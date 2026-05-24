ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS{
	. = 1M;	 /* kernel will be loaded into memory 0x100000 */
	.text : {
		*(.text)
	}

	.rodata : {
		*(.rodata)
	}

	.bss : {
		*(COMMON)
		*(.bss)
	}
}
