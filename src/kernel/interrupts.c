#include "interrupts.h"
#include "memory.h"
#include "graphics.h"

#define KERNEL_TOTAL_INTERRUPTS 512

extern void outb(uint8_t port, uint8_t data);
extern void default_irq_wrapper();

static idt_entry_t idt[KERNEL_TOTAL_INTERRUPTS];
static idtr_t 	   idtr;


void default_irq_handler(){
	PIC_sendEOI(0); 		//send to particular irq???
}

void int0_handler(){
	print("keyboard pressed\n");
	PIC_sendEOI(1);
}

//maps a function pointed by isr_ptr to interrupt i
void set_int(int i, void* isr_ptr,uint8_t attr){
	uint32_t addr = (uint32_t) isr_ptr;
	idt_entry_t* entry = &idt[i];
	entry->isr_low = addr & 0x0000ffff;
	entry->kernel_cs = 0x08;
	entry->reserved = 0;
	entry->attributes = attr;				
	entry->isr_high = addr >> 16;	
}

void init_idt(){
	memset(idt,0,sizeof(idt));	//empty idt
	
	idtr.limit = sizeof(idt)-1;
	idtr.base = (uint32_t) idt;

	__asm__ ("lidt %0" :: "m"(idtr));	//load the idt using lidt instruction

}

void remap_pic(uint8_t offset1, uint8_t offset2){
	outb(PIC1_COMMAND, 0x11);   // start master initialization
	outb(PIC2_COMMAND, 0x11);   // start slave initialization

	outb(PIC1_DATA, offset1);   // ICW2: master vector offset
	outb(PIC2_DATA, offset2);   // ICW2: slave vector offset

	outb(PIC1_DATA, 0x04);      // ICW3: master has slave at IRQ2 (bit 2 = 0b00000100)
	outb(PIC2_DATA, 0x02);      // ICW3: slave cascade identity (IRQ2)

	outb(PIC1_DATA, 0x01);      // ICW4: 8086 mode master
	outb(PIC2_DATA, 0x01);      // ICW4: 8086 mode slave
	
	//to prevent General Protection Faults set default isr that does nothing
	for(uint8_t i = 0x20; i < 0x30; i++){
		set_int(i,default_irq_wrapper,0x8E);		//(0x*e) -> Preset, ring 0, 32bit interrupt gate
	}	
}
void PIC_sendEOI(uint8_t irq){
	//due to cascade... when irq 8-15 have to release both master and slave by giving eoi
	if(irq >= 8)
		outb(PIC2_COMMAND,PIC_EOI_CMD);
	outb(PIC1_COMMAND,PIC_EOI_CMD);
}
