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


	.enter_protected_mode:
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
	dw 0		;base
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


;cant use bios from here (protected mode) so to read disks have to write our own driver
[BITS 32]
load32:
	mov eax,1		;sector to load from (bootloader at sector 0 kernel starts from sector 1)
	mov ecx,100		;no of sectors to load (this is arbitrarly chosen)
	mov edi, 0x00100000	;address to load them into (defined in linker)
	call ata_lba_read
	jmp 0x08:0x00100000	

; driver to read sectors in lba mode copied from https://wiki.osdev.org/ATA_read/write_sectors (and converted to 32bit registers by claude)
ata_lba_read:
	pushfd                  ; pushfq is 64-bit, pushfd is 32-bit equivalent
	and eax, 0x0FFFFFFF     ; mask to 28-bit LBA, using eax not rax
	push eax
	push ebx
	push ecx
	push edx
	push edi                ; edi not rdi — 32-bit destination pointer

	mov ebx, eax            ; save LBA in ebx
	mov edx, 0x01F6
	shr eax, 24
	or al, 11100000b
	out dx, al

	mov edx, 0x01F2
	mov al, cl
	out dx, al

	mov edx, 0x1F3
	mov eax, ebx
	out dx, al

	mov edx, 0x1F4
	mov eax, ebx
	shr eax, 8
	out dx, al

	mov edx, 0x1F5
	mov eax, ebx
	shr eax, 16
	out dx, al

	mov edx, 0x1F7
	mov al, 0x20
	out dx, al

.still_going:
	in al, dx
	test al, 8
	jz .still_going

	mov eax, 256            ; 256 words per sector
	xor bx, bx
	mov bl, cl
	mul bx
	mov ecx, eax            ; loop counter for insw, using ecx not rcx
	mov edx, 0x1F0
	rep insw                ; writes words to [edi], increments edi automatically

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	popfd                   ; popfq is 64-bit, popfd is 32-bit equivalent
	ret
times 510-($-$$) db 0
dw 0xAA55
