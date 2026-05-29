section .asm


extern int0_handler
extern default_irq_handler

global int0_wrapper
global default_irq_wrapper

int0_wrapper:
	push ebp
	mov ebp,esp
	
	call int0_handler

	pop ebp
	iret

default_irq_wrapper:
	push ebp
	mov ebp,esp
	
	call default_irq_handler

	pop ebp
	iret
