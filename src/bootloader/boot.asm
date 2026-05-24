ORG 0x7c00
BITS 16

;bios parameter block (some bios write in these block so have this empty space to prevent them from overriding code)
BPB:
	jmp short code
	nop
times 33 db 0

code:
jmp 0:start	
start:
	cli
	mov ax,0x00
	mov ds,ax
	mov es,ax
	
	mov ss,ax
	mov sp,0x7c00
	sti


	.protected_mode:
		cli
		lgdt [gdt_descriptor]
		mov eax,cr0
		or eax,0x1
		mov cr0,eax
		
		;in protected mode segment registers hold selectors and now cs needs to point to the entry in gdt(0x08 offset in gdt table) that has information about the code segemnt i.e gdt_code (idk tho)
		jmp 0x08:load32


;GDT taken form https://wiki.osdev.org/GDT_Tutorial#Filling_the_Table (Flat/Long Mode setup)
gdt_start:
;table offset 0x00
gdt_null:
	dd 0x0
	dd 0x0
;table offset 0x08
gdt_code:
	dw 0xffff	;limit
	db 0		;base
	db 0
			; base = 0 and limit = ffff tells that the code segment will occuply the entire 4gb space
	db 0x9a		; access byte (read and execute)
	db 0xcf		;flag stuff
	db 0
;table offset 0x10
gdt_data:
	dw 0xffff	;limit
	dw 0		;base
	db 0
			; here also base=0 limit =ffff which means that data segment will occupy entire 4gb space (this is why its called flat mode because cs and ds overlap)
	db 0x92		; access byte (read and write)
	db 0xcf		; flag stuff
	db 0
gdt_end:

gdt_descriptor:
	dw gdt_end-gdt_start-1	;size
	dd gdt_start		;offset

[BITS 32]
load32:
	; setting up segment registers to "select" to gdt_data entry i.e 0x10 offset
	mov ax,0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov ebp, 0x003fffff
	mov esp, ebp
	
	;enabling the a20 address line (depends on the processor how to enable this)
	in al, 0x92
	or al, 2
	out 0x92, al
	

	jmp $

times 510-($-$$) db 0
dw 0xAA55

buffer: 
