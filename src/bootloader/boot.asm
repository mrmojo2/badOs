ORG 0x7c00
BITS 16

;bios parameter block (some bios write in these block so have this empty space to prevent them from overriding code)
BPB:
	jmp short code
	nop
times 33 db 0

code:
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
	mov ecx,0x64		;no of sectors to load (this is arbitrarly chosen)
	mov edi, 0x00100000	;address to load them into (defined in linker)
	call ata_lba_read
	jmp 0x08:0x00100000	

; driver to read sectors in lba mode copied from https://wiki.osdev.org/ATA_read/write_sectors (and converted to 32bit registers by claude)
ata_lba_read:
	mov ebx, eax, ; Backup the LBA
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 1: Send drive select + LBA bits 24-27 to port 0x1F6
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	shr eax, 24
	or eax, 0xE0	;drive select
	mov dx, 0x1F6
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 2: send sector count to port 0x1F6
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, ecx
	mov dx, 0x1F2
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 3: send LBA bits 0-7 to port 0x1F3
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax, ebx ; Restore the backup LBA
	mov dx, 0x1F3
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 4: send LBA bits 8 to 15 to port 0x1F4
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov dx, 0x1F4
	mov eax, ebx 
	shr eax, 8
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 5: send LBA bits 16-23 to port 0x1F5
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov dx, 0x1F5
	mov eax, ebx ; Restore the backup LBA
	shr eax, 16
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 6: send read command (0x20) to port 0x1F5
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;	Step 7: Poll 0x1f7 status until the DRQ bit set and Read a Sector
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.next_sector:
		push ecx

	; checking drq bit
	.try_again:
		mov dx, 0x1f7
		in al, dx
		test al, 8
		jz .try_again

	; reading 256 word i.e 512 byte i.e a sector
		mov ecx, 256
		mov dx, 0x1F0
		rep insw
		pop ecx
		loop .next_sector
		ret

times 510-($-$$) db 0
dw 0xAA55
