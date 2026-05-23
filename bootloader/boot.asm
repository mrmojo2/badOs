ORG 0
BITS 16

;bios parameter block
BPB:
	jmp short code
	nop
times 33 db 0

code:
jmp 0x7c0:start	; bios will load the program to 0x7c00 in the actual memory but org is set to 0 so taking that into account
start:
	cli
	;setting up data and extra segment to match with actual location
	mov ax,0x7c0
	mov ds,ax
	mov es,ax
	
	;stack grows downwards so it wont override the bootloader code even though the stack pointer starts at the same physical address as the code
	mov ax,0x00
	mov ss,ax
	mov sp,0x7c00
	sti


	;CHS disk read
	mov ah,0x02	;disk read
	mov al,0x01	;number of sectors to be read
	mov ch,0x00	;cylinder no
	mov cl,0x02	;sector no
	mov dh,0x00	;head no
	mov bx,buffer	;data buffer
	int 0x13
	jc error

	mov si,buffer
	call printmsg
	jmp $

error:
	mov si, error_msg
	call printmsg
	jmp $



printmsg:
	mov bx,0
	.loop:
		lodsb
		cmp al,0
		je .loop_exit
		
		call printchar	
		jmp .loop

	.loop_exit:
	ret	
printchar:
	mov ah,0eh
	int 0x10
	ret

error_msg: db 'Error loading sector...',0

times 510-($-$$) db 0
dw 0xAA55

buffer:
