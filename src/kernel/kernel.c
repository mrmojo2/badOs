#include "kernel.h"


uint16_t* VGA_TEXT_BUFFER = 0;	//doesnt work on direct initialization idk why
int cur_x = 0;
int cur_y = 0;

void kernel_main(){
	init_terminal();
	char h[] = "hello world\nWelcome to my Os";
	print(h);
}

uint16_t get_char_code(char c, uint8_t color){
	return ((color << 8) | c);
}

void init_terminal(){
	VGA_TEXT_BUFFER = (uint16_t*) (0xB8000);
	for(int i=0; i < VGA_WIDTH * VGA_HEIGHT; i++){
		VGA_TEXT_BUFFER[i] = get_char_code(' ',0);
	}
}

void putchar(int x, int y, char c, uint8_t color){
	VGA_TEXT_BUFFER[(y*VGA_WIDTH)+x] = get_char_code(c,color);
}
void print(char* str){
	int i = 0;
	while(str[i]){
		char c = str[i];
		if(c == '\n'){
			cur_y++; 
			cur_x = 0 ; 
		}else{
			putchar(cur_x++,cur_y,c,0x0f);
		}
		i++;
	}
}

