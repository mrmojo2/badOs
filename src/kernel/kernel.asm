[BITS 32]
global _start
extern kernel_main

_start:
	; setting up segment registers to "select" to gdt_data entry i.e 0x10 offset
	mov ax,0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, 0x00200000
	mov esp, ebp
	
	;enabling the a20 address line (depends on the processor how to enable this)
	in al, 0x92
	or al, 2
	out 0x92, al
	
	call kernel_main
	;int 0
	sti
	jmp $
;for alignment
times 512-($ -  $$) db 0
