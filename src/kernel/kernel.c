#include "kernel.h"
#include "interrupts.h"
#include "graphics.h"


extern void int21_wrapper();

void kernel_main(){
	init_terminal();
	print("hello world\nWelcome to my Os\n");

		
	//initialize the idt
	init_idt();

	//remap the PICS
	remap_pic(0x20,0x28);
	
	__asm__ volatile("sti");
	
	set_int(0x21,int21_wrapper,0b10001110);	//present, ring0, interrupt gate

}

