#ifndef IDT_H
#define IDT_H

#include <stdint.h>

#define PIC1 0x20
#define PIC2 0xA0
#define PIC1_COMMAND PIC1
#define PIC1_DATA    (PIC1+1)
#define PIC2_COMMAND PIC2
#define PIC2_DATA    (PIC1+2)
#define PIC_EOI_CMD  0x20



/*
 
Bits 63-48 : offset 16..31    (isr_high / offset_2)
Bits 47    : P                ─┐
Bits 46-45 : DPL              ─┤ type_attributes / attributes
Bits 44    : S (always 0)     ─┤
Bits 43-40 : Gate type        ─┘
Bits 39-32 : reserved / zero  (must be 0)
Bits 31-16 : segment selector (kernel_cs / selector)
Bits 15-0  : offset 0..15     (isr_low / offset_1)



*/   

typedef struct {
	uint16_t isr_low;	//lower 16 bits of ISR's address
	uint16_t kernel_cs;	//The GDT selector that the CPU will load into CS before calling the ISR
	uint8_t  reserved;	//set to zero
	uint8_t  attributes;	// Type and attributes ; Gate P DPL & S 
	uint16_t isr_high;	//upper 16 bits of ISR's address
}__attribute__((packed)) idt_entry_t;

typedef struct {
	uint16_t limit;		//size of idt -1	
	uint32_t base; 		//linear addr of idt

}__attribute__((packed)) idtr_t;


void init_idt();
void remap_pic(uint8_t offset1, uint8_t offset2);
void int0_handler();
void PIC_sendEOI(uint8_t irq);
void default_irq_handler();
void set_int(int i, void* isr_ptr,uint8_t attr);
#endif
