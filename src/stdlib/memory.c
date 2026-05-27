#include "memory.h"

void* memset(void *ptr, int c, size_t size){
	unsigned char* p = (unsigned char* ) ptr;
	for(int i=0; i<size; i++){
		p[i] = (unsigned char) c;
	}
	return ptr;
}
