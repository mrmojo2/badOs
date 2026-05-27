#include "idt.h"
#include "memory.h"
#include "kernel.h"

#define KERNEL_TOTAL_INTERRUPTS 225

static idt_entry_t idt[KERNEL_TOTAL_INTERRUPTS];
static idtr_t 	   idtr;

void int_0(){
	 print("\nINTERRUPT 0 OCCURED\n");
}

void set_int(int i, void* isr_ptr){
	uint32_t addr = (uint32_t) isr_ptr;
	idt_entry_t* entry = &idt[i];
	entry->isr_low = addr & 0x0000ffff;
	entry->kernel_cs = 0x08;
	entry->reserved = 0;
	entry->attributes = 0b10001110;			//present, ring0, interrupt gate
	entry->isr_high = addr >> 16;	
}

void init_idt(){
	memset(idt,0,sizeof(idt));	//empty idt
	
	idtr.limit = sizeof(idt)-1;
	idtr.base = (uint32_t) idt;

	set_int(0,int_0);

	__asm__ ("lidt %0" :: "m"(idtr));	//load the idt using lidt instruction

}
