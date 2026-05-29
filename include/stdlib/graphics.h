#ifndef GRAPHICS_H
#define GRAPHICS_H

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

#include <stdint.h>

uint16_t get_char_code(char c, uint8_t color);
void init_terminal();
void putchar(int x, int y, char c, uint8_t color);
void print(const char* str);

extern uint16_t* VGA_TEXT_BUFFER;
#endif
