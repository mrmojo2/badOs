section .asm


extern int21_handler
extern default_irq_handler

global int21_wrapper
global default_irq_wrapper

int21_wrapper:
	push ebp
	mov ebp,esp
	
	call int21_handler

	pop ebp
	iret

default_irq_wrapper:
	push ebp
	mov ebp,esp
	
	call default_irq_handler

	pop ebp
	iret
