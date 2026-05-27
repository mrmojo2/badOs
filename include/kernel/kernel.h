#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

void kernel_main();
uint16_t get_char_code(char c, uint8_t color);
void init_terminal();
void putchar(int x, int y, char c, uint8_t color);
void print(const char* str);

extern uint16_t* VGA_TEXT_BUFFER;
#endif
